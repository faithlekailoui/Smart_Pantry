import 'package:flutter_test/flutter_test.dart';
import 'package:smart_pantry/DATA/food_lexicon.dart';

void main() {
  group('FoodLexicon.classify', () {
    test('recognises Kenyan foods and brands', () {
      for (final f in [
        'Brookside Fresh Milk 500ml', 'Unga Jogoo 2kg', 'Sukuma Wiki', 'Royco Mchuzi Mix',
        'Elianto Cooking Oil 1L', 'Maharagwe 1kg', 'Kenchic Chicken Drumsticks', 'Omena 250g',
        'Basmati Rice 2kg', 'Smokies 10pk', 'Matoke', 'Eggs Tray 30', 'Spaghetti 500g',
      ]) {
        expect(FoodLexicon.classify(f), FoodClass.food, reason: f);
      }
    });

    test('recognises non-food items', () {
      for (final f in [
        'OMO Washing Powder 1kg', 'Toilet Paper 10pk', 'Colgate Toothpaste', 'Sunlight Soap Bar',
        'Harpic Toilet Cleaner', 'Dettol Handwash', 'Carrier Bag', 'Pampers Diapers',
        'Hair Oil', 'Cooking Gas Refill', 'Kitchen Roll', 'Ariel Detergent',
      ]) {
        expect(FoodLexicon.classify(f), FoodClass.nonFood, reason: f);
      }
    });

    test('tea bags are food, not a bag', () {
      expect(FoodLexicon.classify('Tea Bags 100'), FoodClass.food);
    });

    test('unknown items are left as unsure', () {
      expect(FoodLexicon.classify('Xyz Item'), FoodClass.unsure);
    });
  });

  group('FoodLexicon.tagsFor', () {
    test('maize flour is flour, not maize kernels', () {
      final t = FoodLexicon.tagsFor('Maize Flour');
      expect(t.contains('flour_maize'), isTrue);
      expect(t.contains('maize_kernels'), isFalse);
    });

    test('green beans are not dry beans', () {
      final t = FoodLexicon.tagsFor('Green Beans');
      expect(t.contains('green_beans'), isTrue);
      expect(t.contains('beans'), isFalse);
    });

    test('juice is not a fruit', () {
      expect(FoodLexicon.tagsFor('Passion Fruit Juice').contains('fruit'), isFalse);
      expect(FoodLexicon.tagsFor('Strawberries').contains('fruit'), isTrue);
    });

    test('tomato sauce is not fresh tomato', () {
      final t = FoodLexicon.tagsFor('Tomato Sauce');
      expect(t.contains('tomato'), isFalse);
      expect(t.contains('tomato_paste'), isTrue);
    });
  });
}
