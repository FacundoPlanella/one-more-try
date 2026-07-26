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

  // Init en paralelo: el splash espera `ready`.
  // ignore: unawaited_futures
  () async {
    await audio.init();
    await ads.initialize();
    await ads.loadBanner();
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
