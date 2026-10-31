import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_pantry/DATA/database_helper.dart';
import 'package:smart_pantry/SERVICES/auth_service.dart';
import 'package:smart_pantry/VIEWS/login_view.dart';
import 'package:smart_pantry/VIEWS/welcome_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final clock = Stopwatch()..start();

  // Open + migrate the database BEFORE the first frame, so no screen ever
  // waits on it or sees a half-initialised database.
  late final bool hasProfile;
  try {
    await DatabaseHelper.instance.database;
    await DatabaseHelper.instance.refreshRiskLevels();
    hasProfile = await AuthService.hasProfile();
  } catch (e) {
    runApp(_StartupError(error: e));
    return;
  }

  debugPrint('Startup: database ready after ${clock.elapsedMilliseconds} ms');
  WidgetsBinding.instance.addPostFrameCallback((_) {
    debugPrint('Startup: first frame after ${clock.elapsedMilliseconds} ms');
  });

  runApp(ProviderScope(child: MyApp(hasProfile: hasProfile)));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.hasProfile});
  final bool hasProfile;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sous-Chef AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.green,
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      ),
      home: hasProfile ? const LoginView(isSetup: false) : const WelcomeView(),
    );
  }
}

class _StartupError extends StatelessWidget {
  const _StartupError({required this.error});
  final Object error;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Sous-Chef AI could not open its database.\n\n$error\n\n'
              'This build stores data in SQLite, which needs the Android/iOS app '
              '(it does not run in a web browser).',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
