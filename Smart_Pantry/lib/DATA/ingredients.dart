// lib/DATA/ingredients.dart

/// Spoilage risk. The index matches the documentation's integer scale:
/// 0 = Low, 1 = Moderate, 2 = High.
enum RiskLevel { low, moderate, high }

class Ingredient {
  /// Days-left thresholds used everywhere (UI, database refresh, AI prompt).
  static const int highRiskDays = 2; // expired, or 0-2 days left
  static const int moderateRiskDays = 5; // 3-5 days left

  static const List<String> locations = ['Fridge', 'Freezer', 'Pantry'];
  static const List<String> units = [
    'pcs', 'kg', 'g', 'L', 'ml', 'pack', 'box', 'bunch', 'dozen',
  ];

  final int? id;
  final String name;
  final double quantity;
  final String unit;
  final String expiryDate; // ISO-8601 date: YYYY-MM-DD
  final String location; // Fridge | Freezer | Pantry
  final double price; // KES, optional (0 = unknown)
  final String addedAt;

  const Ingredient({
    this.id,
    required this.name,
    required this.quantity,
    required this.unit,
    required this.expiryDate,
    this.location = 'Fridge',
    this.price = 0,
    this.addedAt = '',
  });

  // ---------- date helpers (all dates are handled as UTC midnight) ----------

  static DateTime today() {
    final n = DateTime.now();
    return DateTime.utc(n.year, n.month, n.day);
  }

  /// Parses a strict YYYY-MM-DD string. Returns null for anything invalid,
  /// including impossible dates such as 2026-02-31.
  static DateTime? parseDate(String s) {
    final m = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(s.trim());
    if (m == null) return null;
    final y = int.parse(m.group(1)!);
    final mo = int.parse(m.group(2)!);
    final d = int.parse(m.group(3)!);
    final dt = DateTime.utc(y, mo, d);
    if (dt.year != y || dt.month != mo || dt.day != d) return null;
    return dt;
  }

  static String formatDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  static int daysUntil(DateTime expiry) => expiry.difference(today()).inDays;

  static RiskLevel riskForDays(int daysLeft) {
    if (daysLeft <= highRiskDays) return RiskLevel.high;
    if (daysLeft <= moderateRiskDays) return RiskLevel.moderate;
    return RiskLevel.low;
  }

  static String labelForDays(int d) {
    if (d < -1) return 'Expired ${-d} days ago';
    if (d == -1) return 'Expired yesterday';
    if (d == 0) return 'Expires today';
    if (d == 1) return 'Expires tomorrow';
    return 'Expires in $d days';
  }

  static String formatQty(double v) =>
      v == v.roundToDouble() ? v.toInt().toString() : v.toString();

  // ---------- derived values (never stale, computed from today's date) ----------

  DateTime? get expiry => parseDate(expiryDate);

  /// Days until expiry; negative when already expired. An unreadable date is
  /// treated as "today" so the item is flagged rather than silently hidden.
  int get daysLeft {
    final e = expiry;
    return e == null ? 0 : daysUntil(e);
  }

  bool get isExpired => daysLeft < 0;
  RiskLevel get risk => riskForDays(daysLeft);
  int get riskIndex => risk.index;
  String get expiryLabel => labelForDays(daysLeft);

  String get shortLabel {
    final d = daysLeft;
    if (d < 0) return 'Expired';
    if (d == 0) return 'Today';
    if (d == 1) return '1 day';
    return '$d days';
  }

  String get quantityLabel => '${formatQty(quantity)} $unit';

  Ingredient copyWith({
    int? id,
    String? name,
    double? quantity,
    String? unit,
    String? expiryDate,
    String? location,
    double? price,
    String? addedAt,
  }) {
    return Ingredient(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      expiryDate: expiryDate ?? this.expiryDate,
      location: location ?? this.location,
      price: price ?? this.price,
      addedAt: addedAt ?? this.addedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'quantity': quantity,
      'unit': unit,
      'expiry_date': expiryDate,
      'risk_level': riskIndex,
      'location': location,
      'price': price,
      'added_at': addedAt,
    };
  }

  factory Ingredient.fromMap(Map<String, dynamic> map) {
    return Ingredient(
      id: map['id'] as int?,
      name: map['name'] as String,
      quantity: (map['quantity'] as num).toDouble(),
      unit: map['unit'] as String,
      expiryDate: map['expiry_date'] as String,
      location: map['location'] as String? ?? 'Fridge',
      price: (map['price'] as num?)?.toDouble() ?? 0,
      addedAt: map['added_at'] as String? ?? '',
    );
  }
}
