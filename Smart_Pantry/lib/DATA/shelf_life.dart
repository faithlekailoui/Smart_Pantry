// lib/DATA/shelf_life.dart
//
// Receipts do not print expiry dates, so scanned/typed items get an ESTIMATED
// shelf life from the item name. These are rough, typical refrigerated/room
// storage figures to save typing - the user can always change the date, and
// they are not food-safety guarantees.

class ShelfLife {
  ShelfLife._();

  static const int defaultDays = 7;

  // Order matters: more specific keywords first.
  static const Map<String, int> _days = {
    'ice cream': 180, 'frozen': 90,
    'milk': 7, 'yoghurt': 10, 'yogurt': 10, 'cream': 7, 'cheese': 21,
    'butter': 30, 'margarine': 45, 'egg': 21,
    'chicken': 3, 'beef': 3, 'mince': 2, 'meat': 3, 'sausage': 5, 'pork': 3,
    'goat': 3, 'fish': 2, 'tilapia': 2, 'omena': 2,
    'bread': 4, 'chapati': 3, 'mandazi': 2, 'cake': 4,
    'tomato': 6, 'onion': 30, 'potato': 21, 'cabbage': 10, 'spinach': 4,
    'sukuma': 4, 'kale': 4, 'carrot': 14, 'capsicum': 7, 'cucumber': 7,
    'lettuce': 5, 'garlic': 45, 'ginger': 21, 'coriander': 5, 'dhania': 5,
    'banana': 5, 'apple': 14, 'orange': 14, 'mango': 5, 'avocado': 4,
    'grape': 7, 'strawberr': 4, 'blueberr': 5, 'kiwi': 7, 'watermelon': 7,
    'pineapple': 5, 'lemon': 14, 'pawpaw': 5, 'papaya': 5,
    'juice': 7,
    'cooking oil': 365, 'oil': 365, 'rice': 365, 'flour': 180, 'unga': 180,
    'sugar': 365, 'salt': 730, 'pasta': 365, 'spaghetti': 365, 'beans': 365,
    'lentil': 365, 'maize': 270, 'tea': 365, 'coffee': 365, 'biscuit': 120,
  };

  static int daysFor(String name) {
    final n = name.toLowerCase();
    for (final e in _days.entries) {
      if (n.contains(e.key)) return e.value;
    }
    return defaultDays;
  }

  /// Long-life goods default to the pantry shelf, frozen goods to the freezer.
  static String locationFor(String name) {
    final n = name.toLowerCase();
    if (n.contains('frozen') || n.contains('ice cream')) return 'Freezer';
    return daysFor(name) >= 60 ? 'Pantry' : 'Fridge';
  }
}
