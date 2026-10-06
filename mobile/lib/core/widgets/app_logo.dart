import 'package:flutter/material.dart';

import '../config/app_config.dart';
import '../theme/app_colors.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.height = 70, this.lightOnDark = false});
  final double height;
  final bool lightOnDark;

  @override
  Widget build(BuildContext context) {
    final source = lightOnDark && AppConfig.logoOnDark.isNotEmpty ? AppConfig.logoOnDark : AppConfig.logo;
    if (source.isEmpty) return _fallback();

    final isRemote = source.startsWith('http://') || source.startsWith('https://');
    return isRemote
        ? Image.network(source, height: height, fit: BoxFit.contain, errorBuilder: (_, __, ___) => _fallback())
        : Image.asset(source, height: height, fit: BoxFit.contain, errorBuilder: (_, __, ___) => _fallback());
  }

  // Used when no logo is configured or it fails to load: icon + app name.
  Widget _fallback() {
    final color = lightOnDark ? Colors.white : AppColors.navy;
    return SizedBox(
      height: height,
      child: FittedBox(
        fit: BoxFit.contain,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.how_to_reg_rounded, color: lightOnDark ? Colors.white : AppColors.red, size: 40),
            const SizedBox(width: 10),
            Text(AppConfig.appName, style: TextStyle(color: color, fontSize: 28, fontWeight: FontWeight.w800)),
          ],
        ),
      ),
    );
  }
}
