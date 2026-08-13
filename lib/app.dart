import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'core/constants/game_constants.dart';
import 'core/theme/app_theme.dart';
import 'l10n/generated/app_localizations.dart';
import 'presentation/controllers/app_controller.dart';
import 'presentation/screens/splash_screen.dart';
import 'services/audio_service.dart';

class OneMoreTryApp extends StatefulWidget {
  const OneMoreTryApp({super.key});

  @override
  State<OneMoreTryApp> createState() => _OneMoreTryAppState();
}

class _OneMoreTryAppState extends State<OneMoreTryApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final audio = context.read<AudioService>();
    switch (state) {
      case AppLifecycleState.resumed:
        audio.playMusic();
      // "inactive" es transitorio (diálogos del sistema, banners de ads,
      // notificaciones) y no significa que el usuario salió de la app —
      // pausar ahí puede cortar la música apenas arranca en algunos
      // dispositivos. Solo pausamos cuando la app deja de ser visible.
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
      case AppLifecycleState.detached:
        audio.stopMusic();
      case AppLifecycleState.inactive:
        break;
    }
  }

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

    final languageCode = app.ready ? app.save.languageCode : 'en';

    return MaterialApp(
      title: GameConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      locale: Locale(languageCode),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: const SplashScreen(),
    );
  }
}
