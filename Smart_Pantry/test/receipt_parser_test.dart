import 'package:flutter_test/flutter_test.dart';
import 'package:smart_pantry/DATA/food_lexicon.dart';
import 'package:smart_pantry/SERVICES/receipt_parser.dart';

const _sample = '''
NAIVAS SUPERMARKET
TEL 0711 000000
MILK FRESH 500ML   65.00
2 x BREAD WHITE 400G   120.00
TOMATOES 1KG 80.00 A
OMO WASHING POWDER 1KG   350.00
TOILET PAPER 10PK   420.00
UNGA JOGOO 2KG 3 x 130.00   390.00
SUBTOTAL 1425.00
VAT 16% 0.00
TOTAL 1425.00
CASH 1500.00
CHANGE 75.00
THANK YOU
''';

void main() {
  group('ReceiptParser', () {
    final all = ReceiptParser.parse(_sample);
    final food = all.where((i) => i.kind == FoodClass.food).toList();
    final nonFood = all.where((i) => i.kind == FoodClass.nonFood).toList();

    test('keeps only the food lines as food', () {
      expect(food.map((i) => i.name).toList(), [
        'Milk Fresh 500ml',
        'Bread White 400g',
        'Tomatoes 1kg',
        'Unga Jogoo 2kg',
      ]);
    });

    test('separates detergent and toilet paper as non-food', () {
      expect(nonFood.map((i) => i.name).toList(),
          ['Omo Washing Powder 1kg', 'Toilet Paper 10pk']);
    });

    test('reads prices and quantities', () {
      expect(food[0].price, 65.0);
      expect(food[1].quantity, 2);
      expect(food[1].price, 120.0);
      expect(food[3].quantity, 3);
      expect(food[3].price, 390.0);
    });

    test('shop names are not treated as food', () {
      final shop = all.where((i) => i.name.toLowerCase().contains('naivas'));
      expect(shop.every((i) => i.kind != FoodClass.food), isTrue);
    });

    test('ignores totals, payment and contact lines', () {
      final names = all.map((i) => i.name.toLowerCase()).join(' | ');
      for (final junk in ['total', 'vat', 'cash', 'change', 'tel ', 'thank']) {
        expect(names.contains(junk), isFalse, reason: junk);
      }
    });

    test('empty or garbage text produces no items', () {
      expect(ReceiptParser.parse(''), isEmpty);
      expect(ReceiptParser.parse('12 34\n---\n9.99'), isEmpty);
    });
  });
}
