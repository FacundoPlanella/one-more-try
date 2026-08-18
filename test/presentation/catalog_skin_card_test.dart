import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:one_more_try/core/responsive/breakpoints.dart';
import 'package:one_more_try/core/theme/app_theme.dart';
import 'package:one_more_try/data/save_repository.dart';
import 'package:one_more_try/l10n/generated/app_localizations.dart';
import 'package:one_more_try/presentation/controllers/app_controller.dart';
import 'package:one_more_try/presentation/screens/shop_screen.dart';
import 'package:one_more_try/presentation/screens/skins_screen.dart';
import 'package:one_more_try/presentation/widgets/catalog_skin_card.dart';
import 'package:one_more_try/services/ads_service.dart';
import 'package:one_more_try/services/audio_service.dart';
import 'package:one_more_try/services/haptics_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Verifica métricas de tarjetas Skins/Tienda en las resoluciones objetivo.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<AppController> buildController() async {
    SharedPreferences.setMockInitialValues({});
    final controller = AppController(
      saveRepository: SaveRepository(await SharedPreferences.getInstance()),
      audio: _SilentAudio(),
      haptics: HapticsService(),
    );
    await controller.init();
    controller.save.bestScore = 500;
    controller.save.coins = 99999;
    return controller;
  }

  Future<void> pumpScreen(
    WidgetTester tester, {
    required Widget screen,
    required Size logical,
    required double dpr,
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
          locale: const Locale('es'),
          theme: AppTheme.dark(),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: screen,
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 350));
  }

  const viewports = <String, (Size, double)>{
    '720x1280': (Size(360, 640), 2),
    '1080x1920': (Size(360, 640), 3),
    '1440x2560': (Size(576, 1024), 2.5),
    '1600x2560': (Size(800, 1280), 2),
    '2048x2732': (Size(1024, 1366), 2),
  };

  for (final entry in viewports.entries) {
    group('${entry.key} — tarjetas de catálogo', () {
      testWidgets('Skins sin desbordes y con alto mínimo', (tester) async {
        await pumpScreen(
          tester,
          screen: const SkinsScreen(),
          logical: entry.value.$1,
          dpr: entry.value.$2,
        );
        expect(tester.takeException(), isNull);

        final card = tester.getSize(find.byType(CatalogSkinCard).first);
        expect(card.height, greaterThan(100));
        expect(card.width, greaterThan(280));
        expect(card.height / card.width, closeTo(724 / 2172, 0.02));
      });

      testWidgets('Tienda sin desbordes y botón Comprar visible', (tester) async {
        await pumpScreen(
          tester,
          screen: const ShopScreen(),
          logical: entry.value.$1,
          dpr: entry.value.$2,
        );
        expect(tester.takeException(), isNull);
        expect(find.text('Comprar'), findsWidgets);

        final card = tester.getSize(find.byType(CatalogSkinCard).first);
        expect(card.height, greaterThan(100));
        expect(card.height / card.width, closeTo(724 / 2172, 0.02));
      });
    });
  }
}

class _SilentAudio extends AudioService {
  @override
  Future<void> applySettings({required bool music, required bool sfx}) async {
    musicEnabled = music;
    sfxEnabled = sfx;
  }
}
