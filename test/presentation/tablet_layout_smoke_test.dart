import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:one_more_try/core/theme/app_theme.dart';
import 'package:one_more_try/data/save_repository.dart';
import 'package:one_more_try/domain/progression/progression_service.dart';
import 'package:one_more_try/l10n/generated/app_localizations.dart';
import 'package:one_more_try/presentation/controllers/app_controller.dart';
import 'package:one_more_try/presentation/screens/credits_screen.dart';
import 'package:one_more_try/presentation/screens/home_screen.dart';
import 'package:one_more_try/presentation/screens/medals_screen.dart';
import 'package:one_more_try/presentation/screens/result_screen.dart';
import 'package:one_more_try/presentation/screens/settings_screen.dart';
import 'package:one_more_try/presentation/screens/shop_screen.dart';
import 'package:one_more_try/presentation/screens/skins_screen.dart';
import 'package:one_more_try/presentation/screens/splash_screen.dart';
import 'package:one_more_try/presentation/screens/stats_screen.dart';
import 'package:one_more_try/services/ads_service.dart';
import 'package:one_more_try/services/audio_service.dart';
import 'package:one_more_try/services/haptics_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Al agrandar toda la interfaz en tablet (tipografías, botones, tarjetas y
/// paddings escalan con el ancho lógico), el riesgo concreto es que algo deje de
/// entrar. Este smoke test dibuja cada pantalla en las resoluciones objetivo, en
/// los cuatro idiomas y con la fuente del sistema agrandada, y falla si Flutter
/// reporta un desborde o cualquier otra excepción de layout.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    for (final channel in const [
      MethodChannel('xyz.luan/audioplayers'),
      MethodChannel('xyz.luan/audioplayers.global'),
    ]) {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async => null);
    }
  });

  Future<AppController> buildController() async {
    SharedPreferences.setMockInitialValues({});
    final controller = AppController(
      saveRepository: SaveRepository(await SharedPreferences.getInstance()),
      audio: _SilentAudioService(),
      haptics: HapticsService(),
    );
    await controller.init();
    // Datos suficientes para que las listas no queden vacías.
    controller.save.bestScore = 12345;
    controller.save.coins = 98765;
    controller.save.totalGames = 321;
    return controller;
  }

  /// Devuelve la primera excepción de layout, o null si la pantalla dibujó
  /// bien.
  Future<Object?> pumpScreen(
    WidgetTester tester, {
    required Widget screen,
    required Size logical,
    required double dpr,
    required String locale,
    double textScale = 1.0,
  }) async {
    tester.view.physicalSize = Size(logical.width * dpr, logical.height * dpr);
    tester.view.devicePixelRatio = dpr;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final controller = await buildController();
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: controller),
          ChangeNotifierProvider(create: (_) => AdsService()),
        ],
        child: MaterialApp(
          locale: Locale(locale),
          theme: AppTheme.dark(),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(textScale),
            ),
            child: child!,
          ),
          home: screen,
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 350));
    final error = tester.takeException();
    // El splash y los créditos de arranque navegan con timers encadenados
    // (900 ms + 2800 ms) y cada pantalla programa el suyo recién cuando se
    // construye, así que hace falta avanzar el reloj varias veces: si queda un
    // timer pendiente, el framework hace fallar el test. Las pantallas
    // siguientes de la cadena quedan revisadas también.
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(seconds: 2));
    }
    return error ?? tester.takeException();
  }

  const apply = ProgressionApplyResult(
    newBest: true,
    newMedals: [],
    newSkins: [],
    newTitle: null,
    dailyJustCompleted: false,
  );

  final screens = <String, Widget Function()>{
    'inicio': () => const HomeScreen(),
    'resultados': () =>
        const ResultScreen(score: 12345, coins: 678, apply: apply),
    'estadísticas': () => const StatsScreen(),
    'skins': () => const SkinsScreen(),
    'tienda': () => const ShopScreen(),
    'medallas': () => const MedalsScreen(),
    'créditos': () => const CreditsScreen(),
    'ajustes': () => const SettingsScreen(),
    'splash': () => const SplashScreen(),
  };

  // Resoluciones objetivo del diseño responsivo (lógicas + DPR típico).
  const viewports = <String, (Size, double)>{
    '720x1280 @2': (Size(360, 640), 2),
    '1080x1920 @3': (Size(360, 640), 3),
    '1440x2560 @2.5': (Size(576, 1024), 2.5),
    '1600x2560 @2': (Size(800, 1280), 2),
    '2048x2732 @2': (Size(1024, 1366), 2),
    '2048x2732 @1': (Size(2048, 2732), 1),
  };

  viewports.forEach((viewportName, viewport) {
    group(viewportName, () {
      screens.forEach((screenName, build) {
        testWidgets('$screenName dibuja sin desbordes', (tester) async {
          final error = await pumpScreen(
            tester,
            screen: build(),
            logical: viewport.$1,
            dpr: viewport.$2,
            locale: 'es',
          );
          expect(error, isNull);
        });
      });
    });
  });

  group('idiomas y fuente grande en 2048x2732', () {
    for (final locale in ['es', 'en', 'pt', 'zh']) {
      testWidgets('inicio en $locale', (tester) async {
        final error = await pumpScreen(
          tester,
          screen: const HomeScreen(),
          logical: const Size(1024, 1366),
          dpr: 2,
          locale: locale,
        );
        expect(error, isNull);
      });
    }

    testWidgets('fuente grande del sistema', (tester) async {
      final error = await pumpScreen(
        tester,
        screen: const HomeScreen(),
        logical: const Size(1024, 1366),
        dpr: 2,
        locale: 'es',
        textScale: 1.3,
      );
      expect(error, isNull);
    });
  });
}

class _SilentAudioService extends AudioService {
  @override
  Future<void> applySettings({
    required bool music,
    required bool sfx,
  }) async {
    musicEnabled = music;
    sfxEnabled = sfx;
  }
}
