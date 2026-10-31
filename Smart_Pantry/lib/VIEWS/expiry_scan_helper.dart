import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smart_pantry/DATA/ingredients.dart';
import 'package:smart_pantry/SERVICES/expiry_scanner.dart';
import 'package:smart_pantry/VIEWS/common_widgets.dart';

/// Lets the user photograph a product label and returns the expiry date that
/// was read, or null if none was found (a message explains why).
Future<DateTime?> scanExpiryDate(BuildContext context) async {
  final messenger = ScaffoldMessenger.of(context);
  if (kIsWeb) {
    showSnack(messenger, 'Label scanning works on the Android app only.');
    return null;
  }
  final source = await showModalBottomSheet<ImageSource>(
    context: context,
    showDragHandle: true,
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const ListTile(
            title: Text('Scan the expiry date',
                style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('Photograph the part of the package that shows EXP or BEST BEFORE.'),
          ),
          ListTile(
            leading: const Icon(Icons.photo_camera_outlined),
            title: const Text('Take photo'),
            onTap: () => Navigator.pop(ctx, ImageSource.camera),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library_outlined),
            title: const Text('Choose from gallery'),
            onTap: () => Navigator.pop(ctx, ImageSource.gallery),
          ),
        ],
      ),
    ),
  );
  if (source == null) return null;

  showSnack(messenger, 'Reading the label...');
  try {
    final result = await ExpiryScanner.scan(source);
    if (result == null) return null;
    final date = result.date;
    if (date == null) {
      showSnack(messenger,
          'No expiry date found. Try a closer, sharper photo of the date, or pick it by hand.');
      return null;
    }
    showSnack(messenger, 'Found expiry date ${Ingredient.formatDate(date)}');
    return date;
  } catch (e) {
    showSnack(messenger, 'Could not read the label: $e');
    return null;
  }
}
