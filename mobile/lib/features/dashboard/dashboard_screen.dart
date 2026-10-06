import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/network/api_client.dart';
import '../../core/storage/secure_storage_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/theme_controller.dart';
import '../../core/widgets/app_logo.dart';
import '../../models/menu_item_model.dart';
import '../auth/auth_controller.dart';
import '../attendance/manual_attendance_screen.dart';
import '../catalog/projects_screen.dart';
import '../catalog/tribes_screen.dart';
import '../reports/reports_screen.dart';
import '../users/users_screen.dart';
import '../youth/youth_list_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, dynamic>? _summary;

  @override void initState() { super.initState(); _loadSummary(); }
  Future<void> _loadSummary() async {
    try {
      final api = ApiClient(SecureStorageService());
      final response = await api.dio.get('/api/reports/summary');
      if (mounted) setState(() => _summary = Map<String, dynamic>.from(response.data));
    } catch (_) {}
  }

  IconData _icon(String key) => switch (key) {
    'manual_attendance' => Icons.fact_check_rounded,
    'youth' => Icons.groups_rounded,
    'tribes' => Icons.diversity_3_rounded,
    'projects' => Icons.sports_soccer_rounded,
    'reports' => Icons.bar_chart_rounded,
    'users' => Icons.manage_accounts_rounded,
    _ => Icons.apps_rounded,
  };

  void _open(MenuItemModel item) {
    final Widget? screen = switch (item.key) {
      'manual_attendance' => const ManualAttendanceScreen(),
      'youth' => const YouthListScreen(),
      'tribes' => const TribesScreen(),
      'projects' => const ProjectsScreen(),
      'reports' => const ReportsScreen(),
      'users' => const UsersScreen(),
      _ => null,
    };
    if (screen != null) Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final theme = context.watch<ThemeController>();
    return Scaffold(
      appBar: AppBar(
        title: const AppLogo(height: 36),
        actions: [
          IconButton(tooltip: theme.isDark ? 'Modo claro' : 'Modo oscuro', onPressed: () => theme.toggle(), icon: Icon(theme.isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded)),
          PopupMenuButton<String>(onSelected: (v) async { if (v == 'logout') { await auth.logout(); if (context.mounted) Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false); } }, itemBuilder: (_) => const [PopupMenuItem(value: 'logout', child: Row(children: [Icon(Icons.logout_rounded), SizedBox(width: 10), Text('Cerrar sesión')]))]),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadSummary,
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            Text('¡Hola, ${auth.user?.fullName.split(' ').first ?? 'Coordinador'}!', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
            const Text('Juntos hacemos la diferencia.'),
            const SizedBox(height: 20),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 1.15, crossAxisSpacing: 12, mainAxisSpacing: 12),
              itemCount: auth.menu.length,
              itemBuilder: (_, index) {
                final item = auth.menu[index];
                return Card(child: InkWell(borderRadius: BorderRadius.circular(18), onTap: () => _open(item), child: Padding(padding: const EdgeInsets.all(16), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(_icon(item.key), size: 34, color: AppColors.red), const SizedBox(height: 10), Text(item.label, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w800))]))));
              },
            ),
            const SizedBox(height: 18),
            Card(child: Padding(padding: const EdgeInsets.all(18), child: Row(children: [const CircleAvatar(backgroundColor: Color(0xFFE9EEF8), child: Icon(Icons.groups_rounded, color: AppColors.navy)), const SizedBox(width: 14), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Asistencias de hoy', style: TextStyle(fontWeight: FontWeight.w700)), Text('${_summary?['today_attendance'] ?? '—'} jóvenes registrados', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900))]))]))),
            const SizedBox(height: 14),
            Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: AppColors.red, borderRadius: BorderRadius.circular(18)), child: const Text('“Jóvenes con propósito, transformando realidades”', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800))),
          ],
        ),
      ),
    );
  }
}
