import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'data/save_repository.dart';
import 'presentation/controllers/app_controller.dart';
import 'services/ads_service.dart';
import 'services/audio_service.dart';
import 'services/haptics_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  // La app apunta a targetSdk con edge-to-edge forzado por el SO: sin esto,
  // Android pinta la barra de estado/navegación con su estilo por defecto
  // en vez de fundirla con el tema oscuro, dejando una franja visualmente
  // ajena al fondo de la app. Los widgets ya resuelven el espacio real vía
  // SafeArea; esto solo hace que las barras del sistema se vean coherentes
  // con el único tema (oscuro) que soporta la app.
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
      systemNavigationBarDividerColor: Colors.transparent,
    ),
  );

  final prefs = await SharedPreferences.getInstance();
  final saveRepository = SaveRepository(prefs);
  final audio = AudioService();
  final haptics = HapticsService();
  final ads = AdsService();

  final appController = AppController(
    saveRepository: saveRepository,
    audio: audio,
    haptics: haptics,
  );

  // Init en paralelo: el splash espera `ready`. El banner se carga sin
  // bloquear esa cadena — si initialize()/loadBanner() tardan o fallan a
  // nivel de canal nativo, appController.init() debe seguir corriendo o
  // el splash queda girando para siempre (SplashScreen._go() no tiene
  // timeout, solo espera `app.ready`).
  // ignore: unawaited_futures
  () async {
    await audio.init();
    // ignore: unawaited_futures
    ads.initialize().then((_) => ads.loadBanner());
    await appController.init();
    await audio.playMusic();
  }();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: appController),
        ChangeNotifierProvider.value(value: ads),
        Provider.value(value: audio),
        Provider.value(value: haptics),
      ],
      child: const OneMoreTryApp(),
    ),
  );
}
