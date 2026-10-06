import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'core/network/api_client.dart';
import 'core/storage/secure_storage_service.dart';
import 'core/theme/theme_controller.dart';
import 'features/auth/auth_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storage = SecureStorageService();
  final apiClient = ApiClient(storage);
  final themeController = ThemeController();
  await themeController.load();
  final authController = AuthController(apiClient, storage);
  await authController.restoreSession();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: themeController),
        ChangeNotifierProvider.value(value: authController),
      ],
      child: const CommunityAttendanceApp(),
    ),
  );
}
