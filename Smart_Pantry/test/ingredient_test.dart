import 'package:flutter_test/flutter_test.dart';
import 'package:smart_pantry/DATA/ingredients.dart';
import 'package:smart_pantry/DATA/shelf_life.dart';

Ingredient _expiringIn(int days) => Ingredient(
      name: 'Test',
      quantity: 1,
      unit: 'pcs',
      expiryDate:
          Ingredient.formatDate(Ingredient.today().add(Duration(days: days))),
    );

void main() {
  group('Spoilage risk classification', () {
    test('expired items are high risk', () {
      final i = _expiringIn(-1);
      expect(i.isExpired, isTrue);
      expect(i.risk, RiskLevel.high);
      expect(i.riskIndex, 2);
    });

    test('0 to 2 days left is high risk', () {
      for (final d in [0, 1, 2]) {
        expect(_expiringIn(d).risk, RiskLevel.high, reason: '$d days');
      }
    });

    test('3 to 5 days left is moderate risk', () {
      for (final d in [3, 4, 5]) {
        expect(_expiringIn(d).risk, RiskLevel.moderate, reason: '$d days');
        expect(_expiringIn(d).riskIndex, 1);
      }
    });

    test('6 or more days left is low risk', () {
      expect(_expiringIn(6).risk, RiskLevel.low);
      expect(_expiringIn(30).riskIndex, 0);
    });

    test('daysLeft matches the date offset', () {
      expect(_expiringIn(4).daysLeft, 4);
      expect(_expiringIn(-3).daysLeft, -3);
    });
  });

  group('Date handling', () {
    test('parseDate accepts valid ISO dates', () {
      expect(Ingredient.parseDate('2026-11-05'), DateTime.utc(2026, 11, 5));
    });

    test('parseDate rejects impossible or malformed dates', () {
      expect(Ingredient.parseDate('2026-02-31'), isNull);
      expect(Ingredient.parseDate('05/11/2026'), isNull);
      expect(Ingredient.parseDate('abc'), isNull);
    });

    test('formatDate and parseDate round-trip', () {
      final d = DateTime.utc(2027, 1, 9);
      expect(Ingredient.parseDate(Ingredient.formatDate(d)), d);
    });
  });

  group('Map conversion', () {
    test('toMap/fromMap keeps all fields', () {
      const original = Ingredient(
        id: 7,
        name: 'Milk',
        quantity: 2.5,
        unit: 'L',
        expiryDate: '2026-11-05',
        location: 'Fridge',
        price: 130,
      );
      final copy = Ingredient.fromMap(original.toMap());
      expect(copy.id, 7);
      expect(copy.name, 'Milk');
      expect(copy.quantity, 2.5);
      expect(copy.unit, 'L');
      expect(copy.location, 'Fridge');
      expect(copy.price, 130);
    });
  });

  group('Shelf-life estimates', () {
    test('known items get typical shelf life', () {
      expect(ShelfLife.daysFor('Fresh Milk 500ml'), 7);
      expect(ShelfLife.daysFor('Tilapia'), 2);
    });

    test('unknown items fall back to the default', () {
      expect(ShelfLife.daysFor('Zzzz'), ShelfLife.defaultDays);
    });

    test('long-life goods default to the pantry', () {
      expect(ShelfLife.locationFor('Rice 2kg'), 'Pantry');
      expect(ShelfLife.locationFor('Milk'), 'Fridge');
    });
  });
}
