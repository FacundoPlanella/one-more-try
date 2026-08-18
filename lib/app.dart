import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'core/constants/game_constants.dart';
import 'core/theme/app_theme.dart';
import 'l10n/generated/app_localizations.dart';
import 'presentation/controllers/app_controller.dart';
import 'presentation/screens/splash_screen.dart';
import 'services/ads_service.dart';
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
        // Si el banner nunca cargó (p.ej. arrancó sin conexión) o falló,
        // reintentar al volver a foreground — loadBanner() ya se
        // autoprotege contra cargas superpuestas (AdsService._loading).
        final ads = context.read<AdsService>();
        if (!ads.isReady) {
          // ignore: unawaited_futures
          ads.loadBanner();
        }
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
    final languageCode = app.ready ? app.save.languageCode : 'en';

    return MaterialApp(
      title: GameConstants.appName,
      debugShowCheckedModeBanner: false,
      // Único tema soportado — no hay claro/sistema para elegir.
      theme: AppTheme.dark(),
      themeMode: ThemeMode.dark,
      // El multiplicador global de `TextScaler` que vivía acá se sacó: con
      // `ResponsiveDimens.uiScale` (core/responsive/breakpoints.dart)
      // aplicado explícitamente por componente en las pantallas que lo
      // necesitan, tener ADEMÁS un multiplicador global hubiera escalado
      // esos mismos textos dos veces.
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
