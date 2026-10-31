// lib/SERVICES/expiry_scanner.dart
//
// Reads the expiry date from a photo of a product label, on the device, using
// ML Kit text recognition plus ExpiryDateParser.
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smart_pantry/SERVICES/expiry_date_parser.dart';

class ExpiryScanResult {
  final DateTime? date;
  final String text;
  const ExpiryScanResult(this.date, this.text);
}

class ExpiryScanner {
  ExpiryScanner._();

  /// Returns null if the user cancelled the camera/gallery.
  static Future<ExpiryScanResult?> scan(ImageSource source) async {
    final picked = await ImagePicker()
        .pickImage(source: source, maxWidth: 2200, imageQuality: 92);
    if (picked == null) return null;
    final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
    try {
      final result =
          await recognizer.processImage(InputImage.fromFilePath(picked.path));
      return ExpiryScanResult(ExpiryDateParser.parse(result.text), result.text);
    } finally {
      await recognizer.close();
    }
  }
}
