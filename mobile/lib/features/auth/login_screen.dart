import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_logo.dart';
import '../../core/widgets/primary_button.dart';
import 'auth_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _username = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    return Scaffold(
      appBar: AppBar(leading: const BackButton()),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 14),
            const AppLogo(height: 82),
            const SizedBox(height: 28),
            Text('Iniciar sesión', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800, color: AppColors.navy)),
            const SizedBox(height: 8),
            const Text('Acceso para coordinadores y administradores.'),
            const SizedBox(height: 28),
            TextField(controller: _username, decoration: const InputDecoration(labelText: 'Usuario', prefixIcon: Icon(Icons.person_outline_rounded))),
            const SizedBox(height: 14),
            TextField(
              controller: _password,
              obscureText: _obscure,
              decoration: InputDecoration(
                labelText: 'Contraseña',
                prefixIcon: const Icon(Icons.lock_outline_rounded),
                suffixIcon: IconButton(onPressed: () => setState(() => _obscure = !_obscure), icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined)),
              ),
            ),
            if (auth.error != null) ...[
              const SizedBox(height: 12),
              Text(auth.error!, style: const TextStyle(color: AppColors.red, fontWeight: FontWeight.w600)),
            ],
            const SizedBox(height: 22),
            PrimaryButton(label: 'Ingresar', icon: Icons.login_rounded, loading: auth.isLoading, onPressed: () async {
              final ok = await auth.login(_username.text, _password.text);
              if (ok && context.mounted) Navigator.pushNamedAndRemoveUntil(context, '/dashboard', (_) => false);
            }),
            const SizedBox(height: 18),
            const Center(child: Text('Si olvidaste tu contraseña, solicita a un super administrador que la restablezca.', textAlign: TextAlign.center)),
          ],
        ),
      ),
    );
  }
}
