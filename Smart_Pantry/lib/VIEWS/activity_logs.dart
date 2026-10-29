import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_pantry/CONTROLLERS/pantry_controller.dart';
import 'package:smart_pantry/DATA/database_helper.dart';

class LogTile extends StatelessWidget {
  const LogTile({super.key, required this.log});
  final ActivityLog log;

  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (log.action) {
      'ADDED' => (Icons.add_circle, Colors.green),
      'USED' => (Icons.remove_circle, Colors.orange),
      'FINISHED' => (Icons.check_circle, Colors.green),
      'DISCARDED' => (Icons.delete, Colors.red),
      'EDITED' => (Icons.edit, Colors.blue),
      _ => (Icons.history, Colors.grey),
    };
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        radius: 16,
        backgroundColor: color,
        child: Icon(icon, size: 18, color: Colors.white),
      ),
      title: Text(log.details),
      subtitle: Text(log.timestamp.replaceFirst('T', '  ')),
    );
  }
}

class ActivityLogsView extends ConsumerWidget {
  const ActivityLogsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logs = ref.watch(allLogsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Activity log')),
      body: logs.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Could not load the log.\n$e')),
        data: (list) => list.isEmpty
            ? const Center(
                child: Text('No activity yet.', style: TextStyle(color: Colors.grey)))
            : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: list.length,
                itemBuilder: (_, i) => LogTile(log: list[i]),
              ),
      ),
    );
  }
}
