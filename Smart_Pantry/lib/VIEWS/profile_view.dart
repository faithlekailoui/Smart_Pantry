import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_pantry/CONTROLLERS/pantry_controller.dart';
import 'package:smart_pantry/SERVICES/auth_service.dart';
import 'package:smart_pantry/VIEWS/activity_logs.dart';
import 'package:smart_pantry/VIEWS/login_view.dart';
import 'package:smart_pantry/VIEWS/welcome_view.dart';

class ProfileView extends ConsumerWidget {
  const ProfileView({super.key});

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  Future<void> _resetProfile(BuildContext context) async {
    final navigator = Navigator.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset profile?'),
        content: const Text(
            'This removes your name and PIN so you can set them up again. '
            'Your pantry items and history are kept.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Reset')),
        ],
      ),
    );
    if (confirmed != true) return;
    await AuthService.resetProfile();
    navigator.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const WelcomeView()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = ref.watch(userNameProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.green,
                    child: Text(_initials(name),
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name.isEmpty ? 'Household' : name,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        const Text('Data stays on this device',
                            style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.history),
                  title: const Text('Activity log'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const ActivityLogsView())),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.lock_outline),
                  title: const Text('Lock app'),
                  onTap: () => Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const LoginView(isSetup: false)),
                    (route) => false,
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.manage_accounts_outlined),
                  title: const Text('Reset profile and PIN'),
                  onTap: () => _resetProfile(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Center(
            child: Text('Sous-Chef AI · v1.1.0',
                style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }
}
