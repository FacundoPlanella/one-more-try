import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:one_more_try/core/responsive/breakpoints.dart';
import 'package:one_more_try/core/theme/app_theme.dart';
import 'package:one_more_try/l10n/generated/app_localizations.dart';
import 'package:one_more_try/presentation/widgets/common_widgets.dart';
import 'package:one_more_try/services/ads_service.dart';
import 'package:provider/provider.dart';

double _expectedUiScale(Size logical, double dpr) {
  final physicalShort =
      (logical.width < logical.height ? logical.width : logical.height) * dpr;
  return (physicalShort / ResponsiveDimens.designShortSidePx)
      .clamp(0.80, 1.45)
      .toDouble();
}

void main() {
  Future<void> pumpAt(
    WidgetTester tester, {
    required Size logical,
    required double dpr,
    required Widget child,
    String locale = 'es',
    double textScale = 1.0,
  }) async {
    tester.view.physicalSize = Size(logical.width * dpr, logical.height * dpr);
    tester.view.devicePixelRatio = dpr;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AdsService(),
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
          builder: (context, widget) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(textScale),
            ),
            child: widget!,
          ),
          home: Scaffold(body: child),
        ),
      ),
    );
    await tester.pump();
  }

  group('Breakpoints por ancho lógico', () {
    testWidgets('720x1280 @2 → celular, escala 0.80 (piso)', (tester) async {
      const logical = Size(360, 640);
      await pumpAt(
        tester,
        logical: logical,
        dpr: 2,
        child: const _DimensProbe(),
      );
      final captured = _DimensProbe.lastOf!;
      expect(captured.deviceClass, DeviceClass.phone);
      expect(captured.uiScale, closeTo(_expectedUiScale(logical, 2), 0.01));
      expect(captured.uiScale, 0.80);
      expect(captured.logicalWidth, 360);
      expect(captured.devicePixelRatio, 2.0);
    });

    testWidgets('1080x1920 @3 → celular, escala 1.0', (tester) async {
      const logical = Size(360, 640);
      await pumpAt(
        tester,
        logical: logical,
        dpr: 3,
        child: const _DimensProbe(),
      );
      final captured = _DimensProbe.lastOf!;
      expect(captured.deviceClass, DeviceClass.phone);
      expect(captured.uiScale, closeTo(_expectedUiScale(logical, 3), 0.01));
      expect(captured.uiScale, 1.0);
    });

    testWidgets('1080x2400 @2.75 → celular, escala 1.0', (tester) async {
      const logical = Size(392.727272, 872.727272);
      await pumpAt(
        tester,
        logical: logical,
        dpr: 2.75,
        child: const _DimensProbe(),
      );
      final captured = _DimensProbe.lastOf!;
      expect(captured.deviceClass, DeviceClass.phone);
      expect(captured.uiScale, closeTo(_expectedUiScale(logical, 2.75), 0.01));
    });

    testWidgets('1600x2560 @2 → tablet, escala por lado corto físico', (
      tester,
    ) async {
      const logical = Size(800, 1280);
      await pumpAt(
        tester,
        logical: logical,
        dpr: 2,
        child: const _DimensProbe(),
      );
      final captured = _DimensProbe.lastOf!;
      expect(captured.deviceClass, DeviceClass.tablet);
      expect(captured.uiScale, closeTo(_expectedUiScale(logical, 2), 0.01));
      expect(captured.uiScale, 1.45);
    });

    testWidgets('2048x2732 @2 → tablet grande, escala acotada a 1.45', (
      tester,
    ) async {
      const logical = Size(1024, 1366);
      await pumpAt(
        tester,
        logical: logical,
        dpr: 2,
        child: const _DimensProbe(),
      );
      final captured = _DimensProbe.lastOf!;
      expect(captured.deviceClass, DeviceClass.largeTablet);
      expect(captured.uiScale, closeTo(_expectedUiScale(logical, 2), 0.01));
      expect(captured.uiScale, 1.45);
    });

    testWidgets('las medidas de layout acompañan a la escala', (tester) async {
      await pumpAt(
        tester,
        logical: const Size(360, 640),
        dpr: 3,
        child: const _DimensProbe(),
      );
      final phone = _DimensProbe.lastOf!;

      await pumpAt(
        tester,
        logical: const Size(1024, 1366),
        dpr: 2,
        child: const _DimensProbe(),
      );
      final tablet = _DimensProbe.lastOf!;

      expect(tablet.headerHeight, greaterThan(phone.headerHeight));
      expect(tablet.buttonHeight, greaterThan(phone.buttonHeight));
      expect(tablet.spacing, greaterThan(phone.spacing));
      expect(tablet.navFontSize, greaterThan(phone.navFontSize));
      expect(tablet.gameSpriteScale, 2.0);
      expect(phone.gameSpriteScale, 1.0);
    });

    testWidgets('una pantalla grande no reduce la UI por debajo del piso', (
      tester,
    ) async {
      const logical = Size(1400, 2000);
      await pumpAt(
        tester,
        logical: logical,
        dpr: 1,
        child: const _DimensProbe(),
      );
      final captured = _DimensProbe.lastOf!;
      expect(captured.uiScale, closeTo(_expectedUiScale(logical, 1), 0.01));
      expect(captured.uiScale, greaterThanOrEqualTo(1.0));
    });

    testWidgets('viewport ancho con DPR 1 respeta el techo de escala', (
      tester,
    ) async {
      const logical = Size(2048, 2732);
      await pumpAt(
        tester,
        logical: logical,
        dpr: 1,
        child: const _DimensProbe(),
      );
      final captured = _DimensProbe.lastOf!;
      expect(captured.deviceClass, DeviceClass.largeTablet);
      expect(captured.uiScale, 1.45);
    });

    testWidgets('el área jugable crece con el ancho lógico', (tester) async {
      await pumpAt(
        tester,
        logical: const Size(360, 640),
        dpr: 2,
        child: const _DimensProbe(),
      );
      final phone = _DimensProbe.lastOf!;
      expect(phone.playableMaxWidth, double.infinity);

      await pumpAt(
        tester,
        logical: const Size(800, 1280),
        dpr: 2,
        child: const _DimensProbe(),
      );
      final tablet = _DimensProbe.lastOf!;

      await pumpAt(
        tester,
        logical: const Size(1024, 1366),
        dpr: 2,
        child: const _DimensProbe(),
      );
      final largeTablet = _DimensProbe.lastOf!;

      expect(tablet.playableMaxWidth, greaterThan(800 * 0.5));
      expect(largeTablet.playableMaxWidth, greaterThan(tablet.playableMaxWidth));
      expect(largeTablet.playableMaxWidth, greaterThan(1024 * 0.5));
    });
  });

  group('Botón Jugar — tamaño lógico, no nativo PNG', () {
    testWidgets('celular: ancho 55–72% y alto ≥ 64', (tester) async {
      await pumpAt(
        tester,
        logical: const Size(360, 640),
        dpr: 2,
        child: const Center(
          child: PrimaryButton(label: 'Jugar', onPressed: _noop),
        ),
      );
      final size = tester.getSize(
        find.descendant(
          of: find.byType(PrimaryButton),
          matching: find.byType(GestureDetector),
        ),
      );
      expect(size.width, inInclusiveRange(360 * 0.92 * 0.55, 360 * 0.92 * 0.72));
      expect(size.height, greaterThanOrEqualTo(64));
    });

    testWidgets('tablet 800dp: ancho 55–72% del contenido y alto ≥ 96', (
      tester,
    ) async {
      await pumpAt(
        tester,
        logical: const Size(800, 1280),
        dpr: 2,
        child: const Center(
          child: PrimaryButton(label: 'Jugar', onPressed: _noop),
        ),
      );
      final size = tester.getSize(
        find.descendant(
          of: find.byType(PrimaryButton),
          matching: find.byType(GestureDetector),
        ),
      );
      final content = 800 * 0.90;
      expect(size.width, inInclusiveRange(content * 0.55, content * 0.72));
      expect(size.height, inInclusiveRange(90, 110));
    });

    testWidgets('tablet grande: alto ≥ 96 y no usa 1774px nativos', (
      tester,
    ) async {
      await pumpAt(
        tester,
        logical: const Size(1024, 1366),
        dpr: 2,
        child: const Center(
          child: PrimaryButton(label: 'Jugar', onPressed: _noop),
        ),
      );
      final size = tester.getSize(
        find.descendant(
          of: find.byType(PrimaryButton),
          matching: find.byType(GestureDetector),
        ),
      );
      expect(size.width, lessThan(1774));
      expect(size.height, lessThan(887));
      expect(size.height, inInclusiveRange(90, 110));
      expect(size.width, greaterThan(400));
    });
  });

  group('Logo — 48–68% del ancho útil', () {
    testWidgets('celular', (tester) async {
      await pumpAt(
        tester,
        logical: const Size(360, 640),
        dpr: 2,
        child: const Center(child: BrandLogo()),
      );
      final size = tester.getSize(find.byType(BrandLogo));
      final content = 360 * 0.92;
      expect(size.width, inInclusiveRange(content * 0.48, content * 0.68));
    });

    testWidgets('tablet', (tester) async {
      await pumpAt(
        tester,
        logical: const Size(800, 1280),
        dpr: 2,
        child: const Center(child: BrandLogo()),
      );
      final size = tester.getSize(find.byType(BrandLogo));
      expect(size.width, inInclusiveRange(720 * 0.48, 720 * 0.68));
    });
  });

  group('Banner reserva espacio solo si está visible', () {
    testWidgets('sin anuncio cargado la franja mide 0', (tester) async {
      final ads = AdsService();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: ads.bannerWidget(active: true)),
        ),
      );
      expect(tester.getSize(find.byType(SizedBox)), const Size(0, 0));
    });
  });

  group('Paneles emergentes escalan en tablet', () {
    Future<double> panelTitleFontSize(
      WidgetTester tester, {
      required Size logical,
    }) async {
      await pumpAt(
        tester,
        logical: logical,
        dpr: 2,
        child: const ConfirmationPanel(
          title: 'Confirmar',
          description: 'Descripción de la acción a confirmar.',
          confirmLabel: 'Sí',
          cancelLabel: 'No',
        ),
      );
      final title = tester.widget<Text>(find.text('Confirmar'));
      return title.style!.fontSize!;
    }

    testWidgets('el título crece con el ancho lógico', (tester) async {
      final phone = await panelTitleFontSize(
        tester,
        logical: const Size(360, 640),
      );
      final tablet = await panelTitleFontSize(
        tester,
        logical: const Size(800, 1280),
      );
      final largeTablet = await panelTitleFontSize(
        tester,
        logical: const Size(1024, 1366),
      );
      expect(tablet, greaterThan(phone));
      expect(largeTablet, greaterThanOrEqualTo(tablet));
    });

    testWidgets('en celular conserva la tipografía de diseño', (tester) async {
      final phone = await panelTitleFontSize(
        tester,
        logical: const Size(360, 640),
      );
      expect(phone, 19);
    });
  });

  group('idiomas y fuente grande', () {
    for (final locale in ['es', 'en', 'pt', 'zh']) {
      testWidgets('PrimaryButton locale=$locale', (tester) async {
        await pumpAt(
          tester,
          logical: const Size(800, 1280),
          dpr: 2,
          locale: locale,
          child: const Center(
            child: PrimaryButton(label: 'Play', onPressed: _noop),
          ),
        );
        expect(tester.takeException(), isNull);
        final size = tester.getSize(
          find.descendant(
            of: find.byType(PrimaryButton),
            matching: find.byType(GestureDetector),
          ),
        );
        expect(size.height, inInclusiveRange(90, 110));
      });
    }

    testWidgets('fuente grande no rompe el botón', (tester) async {
      await pumpAt(
        tester,
        logical: const Size(800, 1280),
        dpr: 2,
        textScale: 1.3,
        child: const Center(
          child: PrimaryButton(label: 'Jugar', onPressed: _noop),
        ),
      );
      expect(tester.takeException(), isNull);
      final size = tester.getSize(
        find.descendant(
          of: find.byType(PrimaryButton),
          matching: find.byType(GestureDetector),
        ),
      );
      expect(size.height, inInclusiveRange(90, 110));
    });
  });
}

void _noop() {}

class _DimensProbe extends StatelessWidget {
  const _DimensProbe();

  static ResponsiveDimens? lastOf;

  @override
  Widget build(BuildContext context) {
    lastOf = context.responsive;
    return const SizedBox.shrink();
  }
}
