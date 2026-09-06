class Ingredient {
  final int? id;
  final String name;
  final double quantity;
  final String unit;
  final String purchaseDate;
  final String expiryDate;
  final int isOpened; // 0 = False, 1 = True
  final String category;

  Ingredient({
    this.id,
    required this.name,
    required this.quantity,
    required this.unit,
    required this.purchaseDate,
    required this.expiryDate,
    this.isOpened = 0,
    this.category = 'Other',
  });

  //Converting an Ingredient object INTO a Map to save to SQLite
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
 class Ingredient {
  final int? id;
  final String name;
  final double quantity;
  final String unit;
  final String purchaseDate;
  final String expiryDate;
  final int isOpened; // 0 = False, 1 = True
  final String category;

  Ingredient({
    this.id,
    required this.name,
    required this.quantity,
    required this.unit,
    required this.purchaseDate,
    required this.expiryDate,
    this.isOpened = 0,
    this.category = 'Other',
  });

  // Convert an Ingredient object INTO a Map to save to SQLite
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'quantity': quantity,
      'unit': unit,
      'purchase_date': purchaseDate,
      'expiry_date': expiryDate,
      'is_opened': isOpened,
      'category': category,
    };
  }

  // Take a Map from SQLite and transform it BACK into a clean Ingredient object
  factory Ingredient.fromMap(Map<String, dynamic> map) {
    return Ingredient(
      id: map['id'] as int?,
      name: map['name'] as String,
      quantity: (map['quantity'] as num).toDouble(),
      unit: map['unit'] as String,
      purchaseDate: map['purchase_date'] as String,
      expiryDate: map['expiry_date'] as String,
      isOpened: map['is_opened'] as int? ?? 0,
      category: map['category'] as String? ?? 'Other',
    );
  }
}
     'quantity': quantity,
      'unit': unit,
      'purchase_date': purchaseDate,
      'expiry_date': expiryDate,
      'is_opened': isOpened,
      'category': category,
    };
  }

  //Take a Map from SQLite and transform it BACK into a clean Ingredient object
  factory Ingredient.fromMap(Map<String, dynamic> map) {
    return Ingredient(
      id: map['id'] as int?,
      name: map['name'] as String,
      quantity: (map['quantity'] as num).toDouble(),
      unit: map['unit'] as String,
      purchaseDate: map['purchase_date'] as String,
      expiryDate: map['expiry_date'] as String,
      isOpened: map['is_opened'] as int? ?? 0,
      category: map['category'] as String? ?? 'Other',
    );
  }
}
