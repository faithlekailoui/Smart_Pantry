import 'package:flutter/material.dart';
import 'package:smart_pantry/DATA/ingredients.dart';

Color riskColor(RiskLevel r) => switch (r) {
      RiskLevel.high => Colors.red.shade600,
      RiskLevel.moderate => Colors.orange.shade700,
      RiskLevel.low => Colors.green.shade600,
    };

String riskName(RiskLevel r) => switch (r) {
      RiskLevel.high => 'High risk',
      RiskLevel.moderate => 'Moderate',
      RiskLevel.low => 'Low risk',
    };

IconData locationIcon(String location) => switch (location) {
      'Freezer' => Icons.ac_unit,
      'Pantry' => Icons.inventory_2_outlined,
      _ => Icons.kitchen,
    };

/// Coloured pill showing days left. Always has text (and an icon), so risk is
/// never communicated by colour alone.
class RiskBadge extends StatelessWidget {
  const RiskBadge({super.key, required this.item});
  final Ingredient item;

  @override
  Widget build(BuildContext context) {
    final color = riskColor(item.risk);
    final icon = switch (item.risk) {
      RiskLevel.high => Icons.warning_amber_rounded,
      RiskLevel.moderate => Icons.schedule,
      RiskLevel.low => Icons.check_circle_outline,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            item.shortLabel,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

void showSnack(ScaffoldMessengerState messenger, String text) {
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(text)));
}
