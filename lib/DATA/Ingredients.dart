class Ingredient {
  final int? id;
  final String name;
  final double quantity;
  final String unit;
  final String expiryDate;

  Ingredient({
    this.id,
    required this.name,
    required this.quantity,
    required this.unit,
    required this.expiryDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'unit': unit,
      'expiry_date': expiryDate,
    };
  }

  factory Ingredient.fromMap(Map<String, dynamic> map) {
    return Ingredient(
      id: map['id'],
      name: map['name'],
      quantity: (map['quantity'] as num).toDouble(),
      unit: map['unit'],
      expiryDate: map['expiry_date'],
    );
  }
}
