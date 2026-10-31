import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smart_pantry/CONTROLLERS/pantry_controller.dart';
import 'package:smart_pantry/DATA/food_lexicon.dart';
import 'package:smart_pantry/DATA/ingredients.dart';
import 'package:smart_pantry/DATA/shelf_life.dart';
import 'package:smart_pantry/SERVICES/receipt_parser.dart';
import 'package:smart_pantry/VIEWS/common_widgets.dart';
import 'package:smart_pantry/VIEWS/expiry_scan_helper.dart';

/// One editable row on the review screen.
class _Draft {
  _Draft({
    required this.include,
    required this.kind,
    required String nameText,
    required double qtyValue,
    required this.expiry,
    required this.location,
    required this.price,
  })  : name = TextEditingController(text: nameText),
        qty = TextEditingController(text: Ingredient.formatQty(qtyValue));

  bool include;
  final FoodClass kind;
  final TextEditingController name;
  final TextEditingController qty;
  DateTime expiry;
  String location;
  final double price;

  void dispose() {
    name.dispose();
    qty.dispose();
  }
}

/// Real receipt scanning: on-device ML Kit OCR reads the photo, the parser
/// separates food from non-food, and the user reviews the food items (and can
/// scan each package's expiry date) before anything is saved.
class ScanReceiptView extends ConsumerStatefulWidget {
  const ScanReceiptView({super.key});

  @override
  ConsumerState<ScanReceiptView> createState() => _ScanReceiptViewState();
}

class _ScanReceiptViewState extends ConsumerState<ScanReceiptView> {
  XFile? _image;
  bool _busy = false;
  bool _scanned = false;
  String? _error;
  String _rawText = '';
  List<_Draft> _drafts = [];
  List<String> _skipped = [];

  List<_Draft> get _foodDrafts =>
      _drafts.where((d) => d.kind == FoodClass.food).toList();
  List<_Draft> get _unsureDrafts =>
      _drafts.where((d) => d.kind == FoodClass.unsure).toList();

  @override
  void dispose() {
    for (final d in _drafts) {
      d.dispose();
    }
    super.dispose();
  }

  Future<void> _scan(ImageSource source) async {
    if (kIsWeb) {
      setState(() => _error =
          'Receipt scanning runs on the Android/iOS app. It is not available in a web browser.');
      return;
    }

    final XFile? picked;
    try {
      picked = await ImagePicker()
          .pickImage(source: source, maxWidth: 2200, imageQuality: 92);
    } catch (e) {
      setState(() => _error = 'Could not open the image picker: $e');
      return;
    }
    if (picked == null) return;

    for (final d in _drafts) {
      d.dispose();
    }
    setState(() {
      _image = picked;
      _busy = true;
      _scanned = false;
      _error = null;
      _rawText = '';
      _drafts = [];
      _skipped = [];
    });

    final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
    try {
      final result = await recognizer.processImage(InputImage.fromFilePath(picked.path));
      final parsed = ReceiptParser.parse(result.text);
      final today = Ingredient.today();

      final drafts = <_Draft>[];
      final skipped = <String>[];
      for (final p in parsed) {
        if (p.kind == FoodClass.nonFood) {
          skipped.add(p.name);
          continue;
        }
        drafts.add(_Draft(
          include: p.kind == FoodClass.food, // "not sure" lines start unticked
          kind: p.kind,
          nameText: p.name,
          qtyValue: p.quantity,
          expiry: today.add(Duration(days: ShelfLife.daysFor(p.name))),
          location: ShelfLife.locationFor(p.name),
          price: p.price,
        ));
      }

      if (!mounted) {
        for (final d in drafts) {
          d.dispose();
        }
        return;
      }
      setState(() {
        _rawText = result.text;
        _drafts = drafts;
        _skipped = skipped;
        _scanned = true;
        _busy = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = 'Could not read this image: $e';
      });
    } finally {
      await recognizer.close();
    }
  }

  Future<void> _pickDate(_Draft d) async {
    final today = Ingredient.today();
    final first = DateTime(today.year - 1, today.month, today.day);
    final last = DateTime(today.year + 5, today.month, today.day);
    var initial = DateTime(d.expiry.year, d.expiry.month, d.expiry.day);
    if (initial.isBefore(first)) initial = first;
    if (initial.isAfter(last)) initial = last;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first,
      lastDate: last,
    );
    if (picked == null) return;
    setState(() => d.expiry = DateTime.utc(picked.year, picked.month, picked.day));
  }

  Future<void> _scanLabel(_Draft d) async {
    final date = await scanExpiryDate(context);
    if (date == null || !mounted) return;
    setState(() => d.expiry = date);
  }

  int get _selected => _drafts.where((d) => d.include).length;

  Future<void> _addSelected() async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    final items = <Ingredient>[];
    for (final d in _drafts.where((d) => d.include)) {
      final name = d.name.text.trim();
      if (name.isEmpty) continue;
      items.add(Ingredient(
        name: name,
        quantity: double.tryParse(d.qty.text.trim().replaceAll(',', '.')) ?? 1,
        unit: 'pcs',
        expiryDate: Ingredient.formatDate(d.expiry),
        location: d.location,
        price: d.price,
      ));
    }
    if (items.isEmpty) return;

    try {
      await ref.read(pantryProvider.notifier).addAll(items);
      navigator.pop();
      showSnack(messenger, 'Added ${items.length} item${items.length == 1 ? '' : 's'} to your pantry.');
    } catch (e) {
      showSnack(messenger, 'Could not save: $e');
    }
  }

  Widget _row(_Draft d) => _DraftRow(
        draft: d,
        onChanged: () => setState(() {}),
        onPickDate: () => _pickDate(d),
        onScanLabel: () => _scanLabel(d),
      );

  @override
  Widget build(BuildContext context) {
    final food = _foodDrafts;
    final unsure = _unsureDrafts;

    return Scaffold(
      appBar: AppBar(title: const Text('Scan receipt')),
      bottomNavigationBar: _drafts.isEmpty
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                  onPressed: _selected == 0 ? null : _addSelected,
                  icon: const Icon(Icons.playlist_add_check),
                  label: Text('Add $_selected to pantry'),
                ),
              ),
            ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: _busy ? null : () => _scan(ImageSource.camera),
                  icon: const Icon(Icons.photo_camera_outlined),
                  label: const Text('Take photo'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _busy ? null : () => _scan(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library_outlined),
                  label: const Text('From gallery'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_image != null && !kIsWeb)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(File(_image!.path), height: 150, fit: BoxFit.cover),
            ),
          if (_busy)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(_error!, style: const TextStyle(color: Colors.red)),
            ),
          if (_scanned && _drafts.isEmpty && !_busy)
            const Padding(
              padding: EdgeInsets.only(top: 16),
              child: Text(
                'No food items were found. Try a sharper, well-lit, flat photo of the receipt, '
                'or add the items manually.',
              ),
            ),
          if (_drafts.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text('Review before adding',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(
              'Only food is ticked. Receipts do not print expiry dates, so dates are estimated from the '
              'item name. Tap the date to change it, or tap the scan icon and photograph the expiry date on the package.',
              style: TextStyle(color: Colors.grey.shade700),
            ),
            if (food.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text('Food found (${food.length})',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              for (final d in food) _row(d),
            ],
            if (unsure.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text('Not sure (${unsure.length}) - tick only the ones that are food',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              for (final d in unsure) _row(d),
            ],
          ],
          if (_scanned && _skipped.isNotEmpty)
            ExpansionTile(
              title: Text('Skipped as not food (${_skipped.length})'),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(_skipped.join('\n'),
                        style: TextStyle(color: Colors.grey.shade700)),
                  ),
                ),
              ],
            ),
          if (_scanned)
            ExpansionTile(
              title: const Text('Recognised text'),
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: SelectableText(_rawText),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _DraftRow extends StatelessWidget {
  const _DraftRow({
    required this.draft,
    required this.onChanged,
    required this.onPickDate,
    required this.onScanLabel,
  });
  final _Draft draft;
  final VoidCallback onChanged;
  final VoidCallback onPickDate;
  final VoidCallback onScanLabel;

  @override
  Widget build(BuildContext context) {
    final days = Ingredient.daysUntil(draft.expiry);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(4, 8, 8, 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(
              value: draft.include,
              onChanged: (v) {
                draft.include = v ?? false;
                onChanged();
              },
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: draft.name,
                    decoration: const InputDecoration(
                        isDense: true, labelText: 'Item name'),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      SizedBox(
                        width: 70,
                        child: TextField(
                          controller: draft.qty,
                          keyboardType:
                              const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(
                              isDense: true, labelText: 'Qty'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: onPickDate,
                          icon: const Icon(Icons.calendar_month, size: 18),
                          label: Text(
                            '${Ingredient.formatDate(draft.expiry)} · ${days}d',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Scan the expiry date on the package',
                        icon: const Icon(Icons.document_scanner_outlined),
                        onPressed: onScanLabel,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
