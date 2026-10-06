import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:community_attendance/core/config/app_config.dart';
import 'package:community_attendance/core/widgets/app_logo.dart';

void main() {
  testWidgets('AppLogo falls back to the app name when no logo is configured', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: AppLogo())));

    expect(find.text(AppConfig.appName), findsOneWidget);
  });
}
