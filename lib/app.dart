import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/constants/game_constants.dart';
import 'core/theme/app_theme.dart';
import 'presentation/controllers/app_controller.dart';
import 'presentation/screens/splash_screen.dart';

class OneMoreTryApp extends StatelessWidget {
  const OneMoreTryApp({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppController>();
    final mode = app.ready ? app.save.themeMode : 'dark';

    ThemeMode themeMode;
    switch (mode) {
      case 'light':
        themeMode = ThemeMode.light;
      case 'system':
        themeMode = ThemeMode.system;
      default:
        themeMode = ThemeMode.dark;
    }

    return MaterialApp(
      title: GameConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      home: const SplashScreen(),
    );
  }
}
