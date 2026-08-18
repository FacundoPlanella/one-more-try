import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:one_more_try/core/theme/app_theme.dart';
import 'package:one_more_try/l10n/generated/app_localizations.dart';
import 'package:one_more_try/presentation/widgets/common_widgets.dart';

/// Verifica los contadores de puntaje y recompensa de la pantalla de
/// resultados (result_screen.dart): el marco de madera debe conservar
/// exactamente el mismo tamaño sin importar la cantidad de dígitos, y el
/// ícono nunca debe moverse ni deformarse.
void main() {
  // Mismos valores que usa result_screen.dart.
  const scoreWidth = 240.0;
  const scoreFontSize = 48.0;
  const scoreAspect = 2172 / 724;
  const scoreExpectedHeight = scoreWidth / scoreAspect;

  const rewardWidth = 140.0;
  const rewardFontSize = 16.0;
  const rewardExpectedHeight = rewardWidth / scoreAspect;

  const testValues = [
    0,
    6,
    99,
    100,
    999,
    1000,
    9999,
    10000,
    99999,
    999999,
    1000000,
    9999999,
  ];

  Future<void> pumpApp(
    WidgetTester tester, {
    required String languageCode,
    required Widget child,
    double textScale = 1.0,
    Size surfaceSize = const Size(1080, 1920),
  }) async {
    tester.view.physicalSize = surfaceSize;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        locale: Locale(languageCode),
        theme: AppTheme.dark(),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, widget) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(textScale)),
          child: widget!,
        ),
        home: Scaffold(
          body: Center(
            child: Material(type: MaterialType.transparency, child: child),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('PointsCounter (marco de puntaje)', () {
    for (final locale in ['es', 'en']) {
      for (final value in testValues) {
        testWidgets('locale=$locale value=$value mantiene el marco fijo', (
          tester,
        ) async {
          await pumpApp(
            tester,
            languageCode: locale,
            child: PointsCounter(value: value, width: scoreWidth, fontSize: scoreFontSize),
          );

          expect(tester.takeException(), isNull);

          final plateSize = tester.getSize(find.byType(PointsCounter));
          expect(plateSize.width, scoreWidth);
          expect(plateSize.height, closeTo(scoreExpectedHeight, 0.01));

          final iconSize = tester.getSize(
            find.image(AssetImage('assets/images/ui/icono_puntos.png')),
          );
          expect(iconSize.width, 26.0);
          expect(iconSize.height, 26.0);

          final text = tester.widget<Text>(find.byType(Text));
          final expected = value == 0
              ? '0'
              : NumberFormat.decimalPattern(locale).format(value);
          expect(text.data, expected);
          expect(text.maxLines, 1);
          expect(text.softWrap, isFalse);
        });
      }
    }

    testWidgets('fuente grande del sistema no rompe el marco', (
      tester,
    ) async {
      await pumpApp(
        tester,
        languageCode: 'es',
        textScale: 2.0,
        child: const PointsCounter(
          value: 9999999,
          width: scoreWidth,
          fontSize: scoreFontSize,
        ),
      );
      expect(tester.takeException(), isNull);
      final plateSize = tester.getSize(find.byType(PointsCounter));
      expect(plateSize.width, scoreWidth);
      expect(plateSize.height, closeTo(scoreExpectedHeight, 0.01));
    });

    testWidgets('720x1280 y pantallas alargadas no rompen el marco', (
      tester,
    ) async {
      await pumpApp(
        tester,
        languageCode: 'es',
        surfaceSize: const Size(720, 1280),
        child: const PointsCounter(
          value: 9999999,
          width: scoreWidth,
          fontSize: scoreFontSize,
        ),
      );
      expect(tester.takeException(), isNull);
      final plateSize = tester.getSize(find.byType(PointsCounter));
      expect(plateSize.width, scoreWidth);
      expect(plateSize.height, closeTo(scoreExpectedHeight, 0.01));
    });
  });

  group('CoinLabel (marco de recompensa)', () {
    for (final locale in ['es', 'en']) {
      for (final value in testValues) {
        testWidgets('locale=$locale value=$value mantiene el marco fijo', (
          tester,
        ) async {
          await pumpApp(
            tester,
            languageCode: locale,
            child: CoinLabel(
              amount: value,
              prefix: '+',
              iconSize: 16,
              width: rewardWidth,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: rewardFontSize,
              ),
            ),
          );

          expect(tester.takeException(), isNull);

          final plateSize = tester.getSize(find.byType(CoinLabel));
          expect(plateSize.width, rewardWidth);
          expect(plateSize.height, closeTo(rewardExpectedHeight, 0.01));

          final iconSize = tester.getSize(
            find.image(AssetImage('assets/images/ui/icono_moneda.png')),
          );
          expect(iconSize.width, 16.0);
          expect(iconSize.height, 16.0);

          final text = tester.widget<Text>(find.byType(Text));
          final expected = '+${NumberFormat.decimalPattern(locale).format(value)}';
          expect(text.data, expected);
          expect(text.maxLines, 1);
          expect(text.softWrap, isFalse);
        });
      }
    }

    testWidgets('fuente grande del sistema no rompe el marco', (
      tester,
    ) async {
      await pumpApp(
        tester,
        languageCode: 'es',
        textScale: 2.0,
        child: CoinLabel(
          amount: 9999999,
          prefix: '+',
          iconSize: 16,
          width: rewardWidth,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: rewardFontSize,
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      final plateSize = tester.getSize(find.byType(CoinLabel));
      expect(plateSize.width, rewardWidth);
      expect(plateSize.height, closeTo(rewardExpectedHeight, 0.01));
    });

    testWidgets('720x1280 y pantallas alargadas no rompen el marco', (
      tester,
    ) async {
      await pumpApp(
        tester,
        languageCode: 'es',
        surfaceSize: const Size(720, 1280),
        child: CoinLabel(
          amount: 9999999,
          prefix: '+',
          iconSize: 16,
          width: rewardWidth,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: rewardFontSize,
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      final plateSize = tester.getSize(find.byType(CoinLabel));
      expect(plateSize.width, rewardWidth);
      expect(plateSize.height, closeTo(rewardExpectedHeight, 0.01));
    });
  });
}
