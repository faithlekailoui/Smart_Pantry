// lib/SERVICES/receipt_parser.dart
//
// Turns raw OCR text from a till receipt into candidate pantry items. Pure
// Dart (no Flutter/ML Kit imports) so it can be unit-tested. OCR is never
// perfect, so the UI always shows a review screen before anything is saved.

class ParsedReceiptItem {
  final String name;
  final double quantity;
  final double price;
  final bool hasPrice;
  const ParsedReceiptItem({
    required this.name,
    required this.quantity,
    required this.price,
    required this.hasPrice,
  });
}

class ReceiptParser {
  ReceiptParser._();

  // Lines containing these whole words are headers/totals/payment info.
  static final RegExp _skip = RegExp(
    r'\b(sub\s*total|total|vat|tax|change|cash|mpesa|m-pesa|paybill|card|visa|'
    r'tendered|receipt|invoice|tel|phone|pin|thank|welcome|served|cashier|till|'
    r'balance|amount|description|qty|price|branch|store|kra|etims|date|time|'
    r'barcode|discount|points|loyalty|customer|payment|paid|order|ref)\b',
    caseSensitive: false,
  );

  // Trailing price such as "65.00", "1,250.00" or "80.00 A" (tax code letter).
  static final RegExp _price =
      RegExp(r'(\d{1,3}(?:,\d{3})+|\d+)\.\d{2}\s*[A-Za-z]?\s*$');

  // Leading quantity such as "2 x " or "3X ".
  static final RegExp _leadingQty = RegExp(r'^\s*(\d+(?:\.\d+)?)\s*[xX*]\s+');

  static List<ParsedReceiptItem> parse(String raw) {
    final items = <ParsedReceiptItem>[];

    for (var line in raw.split(RegExp(r'\r?\n'))) {
      line = line.trim();
      if (line.length < 3) continue;

      final lower = line.toLowerCase();
      if (lower.contains('www.') || lower.contains('.com') || lower.contains('@')) {
        continue;
      }
      if (_skip.hasMatch(line)) continue;

      var price = 0.0;
      var hasPrice = false;
      final pm = _price.firstMatch(line);
      if (pm != null) {
        final digits =
            pm.group(0)!.replaceAll(RegExp(r'[A-Za-z\s]'), '').replaceAll(',', '');
        price = double.tryParse(digits) ?? 0;
        hasPrice = true;
        line = line.substring(0, pm.start).trim();
      }

      var qty = 1.0;
      final qm = _leadingQty.firstMatch(line);
      if (qm != null) {
        qty = double.tryParse(qm.group(1)!) ?? 1.0;
        line = line.substring(qm.end).trim();
      }

      line = line
          .replaceAll(RegExp(r'^\s*\d{1,3}[.)]\s*'), '') // "1. " list numbers
          .replaceAll(RegExp(r'\b\d{5,}\b'), ' ') // barcodes / PLU codes
          .replaceAll(RegExp(r"[^A-Za-z0-9%\s\-&'/.]"), ' ')
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim();

      if (!RegExp(r'[A-Za-z]{3,}').hasMatch(line) || line.length > 60) continue;

      items.add(ParsedReceiptItem(
        name: _titleCase(line),
        quantity: qty <= 0 ? 1.0 : qty,
        price: price,
        hasPrice: hasPrice,
      ));
    }
    return items;
  }

  static String _titleCase(String s) => s
      .split(' ')
      .where((w) => w.isNotEmpty)
      .map((w) => w[0].toUpperCase() + w.substring(1).toLowerCase())
      .join(' ');
}
