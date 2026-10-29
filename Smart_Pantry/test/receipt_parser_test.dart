import 'package:flutter_test/flutter_test.dart';
import 'package:smart_pantry/SERVICES/receipt_parser.dart';

const _sample = '''
NAIVAS SUPERMARKET
TEL 0711 000000
MILK FRESH 500ML   65.00
2 x BREAD WHITE 400G   120.00
TOMATOES 1KG 80.00 A
SUBTOTAL 265.00
VAT 16% 0.00
TOTAL 265.00
CASH 300.00
CHANGE 35.00
THANK YOU
''';

void main() {
  group('ReceiptParser', () {
    final all = ReceiptParser.parse(_sample);
    final priced = all.where((i) => i.hasPrice).toList();

    test('extracts the priced product lines', () {
      expect(priced.map((i) => i.name).toList(),
          ['Milk Fresh 500ml', 'Bread White 400g', 'Tomatoes 1kg']);
    });

    test('reads prices and leading quantities', () {
      expect(priced[0].price, 65.0);
      expect(priced[1].quantity, 2);
      expect(priced[1].price, 120.0);
      expect(priced[2].price, 80.0);
    });

    test('ignores totals, payment and contact lines', () {
      final names = all.map((i) => i.name.toLowerCase()).join(' | ');
      for (final junk in ['total', 'vat', 'cash', 'change', 'tel', 'thank']) {
        expect(names.contains(junk), isFalse, reason: junk);
      }
    });

    test('empty or garbage text produces no items', () {
      expect(ReceiptParser.parse(''), isEmpty);
      expect(ReceiptParser.parse('12 34\n---\n9.99'), isEmpty);
    });
  });
}
