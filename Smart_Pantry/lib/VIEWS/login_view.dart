import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_pantry/CONTROLLERS/pantry_controller.dart';
import 'package:smart_pantry/SERVICES/auth_service.dart';
import 'package:smart_pantry/VIEWS/main_navigation_view.dart';
import 'package:smart_pantry/VIEWS/welcome_view.dart';

/// Household PIN screen. isSetup = true creates the profile (first run);
/// isSetup = false asks for the existing PIN.
class LoginView extends ConsumerStatefulWidget {
  const LoginView({super.key, required this.isSetup});
  final bool isSetup;

  @override
  ConsumerState<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends ConsumerState<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _pinController = TextEditingController();
  final _confirmController = TextEditingController();
  String _savedName = '';
  String? _error;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    if (!widget.isSetup) {
      AuthService.displayName().then((n) {
        if (mounted) setState(() => _savedName = n);
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _pinController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      if (widget.isSetup) {
        await AuthService.createProfile(
            name: _nameController.text, pin: _pinController.text);
        ref.read(userNameProvider.notifier).state = _nameController.text.trim();
      } else {
        final ok = await AuthService.verify(_pinController.text);
        if (!ok) {
          if (!mounted) return;
          setState(() {
            _busy = false;
            _error = 'Incorrect PIN. Please try again.';
            _pinController.clear();
          });
          return;
        }
        ref.read(userNameProvider.notifier).state = await AuthService.displayName();
      }
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainNavigationView()),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = 'Something went wrong: $e';
      });
    }
  }

  Future<void> _forgotPin() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset PIN?'),
        content: const Text(
            'This removes the household profile and PIN so you can create a new one. '
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
    if (!mounted) return;
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => const WelcomeView()));
  }

  String? _pinValidator(String? v) {
    if (v == null || v.length != 4) return 'Enter a 4-digit PIN';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final pinFormatters = [
      FilteringTextInputFormatter.digitsOnly,
      LengthLimitingTextInputFormatter(4),
    ];

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.eco, size: 70, color: Colors.green),
                  const SizedBox(height: 12),
                  const Text('Sous-Chef AI',
                      style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.green)),
                  const SizedBox(height: 4),
                  Text(
                    widget.isSetup
                        ? 'Create your household profile'
                        : (_savedName.isEmpty
                            ? 'Enter your PIN'
                            : 'Welcome back, $_savedName'),
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 28),
                  if (widget.isSetup) ...[
                    TextFormField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Your name or household name',
                        prefixIcon: Icon(Icons.home_outlined),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Please enter a name'
                          : null,
                    ),
                    const SizedBox(height: 16),
                  ],
                  TextFormField(
                    controller: _pinController,
                    obscureText: true,
                    keyboardType: TextInputType.number,
                    inputFormatters: pinFormatters,
                    decoration: InputDecoration(
                      labelText: widget.isSetup ? 'Choose a 4-digit PIN' : 'PIN',
                      prefixIcon: const Icon(Icons.lock_outline),
                    ),
                    validator: _pinValidator,
                    onFieldSubmitted: (_) => widget.isSetup ? null : _submit(),
                  ),
                  if (widget.isSetup) ...[
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _confirmController,
                      obscureText: true,
                      keyboardType: TextInputType.number,
                      inputFormatters: pinFormatters,
                      decoration: const InputDecoration(
                        labelText: 'Confirm PIN',
                        prefixIcon: Icon(Icons.lock_outline),
                      ),
                      validator: (v) =>
                          v != _pinController.text ? 'PINs do not match' : null,
                    ),
                  ],
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(_error!, style: const TextStyle(color: Colors.red)),
                  ],
                  const SizedBox(height: 24),
                  FilledButton(
                    style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(50)),
                    onPressed: _busy ? null : _submit,
                    child: _busy
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : Text(widget.isSetup ? 'Create profile' : 'Unlock',
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                  if (!widget.isSetup)
                    TextButton(
                        onPressed: _forgotPin,
                        child: const Text('Forgot PIN?')),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
