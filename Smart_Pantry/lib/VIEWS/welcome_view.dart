import 'package:flutter/material.dart';
import 'package:smart_pantry/VIEWS/login_view.dart';

/// First-run intro. Shown only until a household profile has been created.
class WelcomeView extends StatelessWidget {
  const WelcomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade800,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.eco, size: 90, color: Colors.white),
              const SizedBox(height: 16),
              const Text(
                'Sous-Chef AI',
                style: TextStyle(
                    fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const Text(
                'Smart Kitchen & Zero Waste',
                style: TextStyle(fontSize: 16, color: Colors.white70),
              ),
              const SizedBox(height: 48),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.green.shade800,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const LoginView(isSetup: true)),
                  );
                },
                child: const Text('Get Started',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
