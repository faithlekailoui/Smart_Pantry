// lib/DATA/ingredients.dart
class Ingredient {
  final int? id;
  final String name;
  final double quantity;
  final String unit;
  final String expiryDate;
  final int riskLevel;
  final String location; // 'Fridge', 'Freezer', 'Pantry'

  Ingredient({
    this.id,
    required this.name,
    required this.quantity,
    required this.unit,
    required this.expiryDate,
    this.riskLevel = 0,
    this.location = 'Fridge',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'unit': unit,
      'expiry_date': expiryDate,
      'risk_level': riskLevel,
      'location': location,
    };
  }

  factory Ingredient.fromMap(Map<String, dynamic> map) {
    return Ingredient(
      id: map['id'] as int?,
      name: map['name'] as String,
      quantity: (map['quantity'] as num).toDouble(),
      unit: map['unit'] as String,
      expiryDate: map['expiry_date'] as String,
      riskLevel: map['risk_level'] as int? ?? 0,
      location: map['location'] as String? ?? 'Fridge',
    );
  }
}