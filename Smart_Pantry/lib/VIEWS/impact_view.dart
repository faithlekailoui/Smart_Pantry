import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_pantry/CONTROLLERS/pantry_controller.dart';
import 'package:smart_pantry/DATA/database_helper.dart';
import 'package:smart_pantry/VIEWS/activity_logs.dart';

String _pct(double? v) => v == null ? '-' : '${v.toStringAsFixed(1)}%';
String _kes(double v) => 'KES ${v.toStringAsFixed(0)}';

/// Household impact: every number here is computed from the activity log.
class ImpactView extends ConsumerWidget {
  const ImpactView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(statsProvider);
    final logs = ref.watch(recentLogsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Your impact')),
      body: stats.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Could not load statistics.\n$e')),
        data: (s) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _DiversionCard(stats: s),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _StatTile(label: 'Items tracked', value: '${s.tracked}', icon: Icons.inventory_2_outlined)),
                const SizedBox(width: 12),
                Expanded(child: _StatTile(label: 'Used up', value: '${s.finished}', icon: Icons.check_circle_outline, color: Colors.green)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _StatTile(label: 'Thrown away', value: '${s.discarded}', icon: Icons.delete_outline, color: Colors.red)),
                const SizedBox(width: 12),
                Expanded(child: _StatTile(label: 'Waste rate', value: _pct(s.wastePercent), icon: Icons.percent, color: Colors.orange)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _StatTile(label: 'Value used', value: _kes(s.valueRescued), icon: Icons.savings_outlined, color: Colors.green)),
                const SizedBox(width: 12),
                Expanded(child: _StatTile(label: 'Value wasted', value: _kes(s.valueWasted), icon: Icons.money_off, color: Colors.red)),
              ],
            ),
            if (s.valueRescued == 0 && s.valueWasted == 0)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'Add the price when you log an item to see money saved and wasted.',
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Text('Recent activity',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const Spacer(),
                TextButton(
                  onPressed: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const ActivityLogsView())),
                  child: const Text('See all'),
                ),
              ],
            ),
            logs.when(
              loading: () => const SizedBox.shrink(),
              error: (e, _) => Text('Could not load activity: $e'),
              data: (list) => list.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text('Nothing yet - add your first item.',
                          style: TextStyle(color: Colors.grey)),
                    )
                  : Column(children: [for (final l in list) LogTile(log: l)]),
            ),
          ],
        ),
      ),
    );
  }
}

class _DiversionCard extends StatelessWidget {
  const _DiversionCard({required this.stats});
  final PantryStats stats;

  @override
  Widget build(BuildContext context) {
    final rate = stats.diversionRate;
    return Card(
      color: Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            SizedBox(
              width: 88,
              height: 88,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 88,
                    height: 88,
                    child: CircularProgressIndicator(
                      value: rate == null ? 0 : rate / 100,
                      strokeWidth: 9,
                      backgroundColor: Colors.green.shade100,
                      color: Colors.green.shade700,
                    ),
                  ),
                  Text(_pct(rate),
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Landfill diversion rate',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(
                    rate == null
                        ? 'Appears once you mark items as used up or thrown away.'
                        : '${stats.finished} of ${stats.resolved} finished items were eaten, not binned.',
                    style: TextStyle(color: Colors.grey.shade800),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.value,
    required this.icon,
    this.color,
  });
  final String label;
  final String value;
  final IconData icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color ?? Colors.grey.shade700),
            const SizedBox(height: 8),
            Text(value,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Text(label, style: TextStyle(color: Colors.grey.shade700)),
          ],
        ),
      ),
    );
  }
}
