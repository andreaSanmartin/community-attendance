import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/config/app_config.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/theme_controller.dart';
import '../../core/widgets/app_logo.dart';

class PublicHomeScreen extends StatelessWidget {
  const PublicHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeController>();
    return Scaffold(
      backgroundColor: AppColors.navy,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(right: 12, top: 8, child: IconButton(
              tooltip: theme.isDark ? 'Usar modo claro' : 'Usar modo oscuro',
              onPressed: () => theme.toggle(),
              icon: Icon(theme.isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded, color: Colors.white),
            )),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 42, 24, 24),
              child: Column(
                children: [
                  const Spacer(),
                  const AppLogo(height: 150, lightOnDark: true),
                  if (AppConfig.tagline.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(AppConfig.tagline.toUpperCase(), textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70, letterSpacing: 1.8, fontWeight: FontWeight.w700)),
                  ],
                  const Spacer(),
                  SizedBox(width: double.infinity, height: 68, child: FilledButton.icon(
                    onPressed: () => Navigator.pushNamed(context, '/scanner'),
                    style: FilledButton.styleFrom(backgroundColor: AppColors.red, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
                    icon: const Icon(Icons.qr_code_scanner_rounded, size: 30),
                    label: const Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Escanear código', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17)), Text('Registrar asistencia', style: TextStyle(fontSize: 12))]),
                  )),
                  const SizedBox(height: 14),
                  SizedBox(width: double.infinity, height: 68, child: OutlinedButton.icon(
                    onPressed: () => Navigator.pushNamed(context, '/login'),
                    style: OutlinedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AppColors.navy, side: BorderSide.none, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
                    icon: const Icon(Icons.person_rounded, size: 28),
                    label: const Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Iniciar sesión', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17)), Text('Coordinadores y administradores', style: TextStyle(fontSize: 12))]),
                  )),
                  const Spacer(),
                  if (AppConfig.slogan.isNotEmpty)
                    Text('“${AppConfig.slogan}”', textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
