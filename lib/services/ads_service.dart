import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../core/constants/game_constants.dart';

/// Solo banner inferior. Nunca interstitial / rewarded.
class AdsService extends ChangeNotifier {
  BannerAd? _banner;
  Widget? _adWidget;
  AdSize? _adSize;
  bool _initialized = false;
  bool _available = true;
  bool _loaded = false;
  // Evita cargas superpuestas (p.ej. un retry al volver de background
  // mientras el load inicial todavía está en vuelo) que crearían dos
  // BannerAd/callbacks compitiendo por _banner/_adWidget.
  bool _loading = false;

  bool get isReady => _banner != null && _loaded;

  Future<void> initialize() async {
    if (kIsWeb) {
      _available = false;
      return;
    }
    try {
      await MobileAds.instance.initialize();
      _initialized = true;
    } catch (_) {
      _available = false;
    }
  }

  // Rama `main`: release usa IDs de producción (Play Store). Debug usa
  // IDs de test de Google para no generar tráfico inválido al desarrollar.
  // `--dart-define=ADS_PROD=true|false` fuerza el modo si hace falta.
  // La rama `test` no tiene IDs de producción: ahí los release siguen
  // en test (tracks internal/closed de Play Console).
  static bool get _useProdAds {
    if (const bool.hasEnvironment('ADS_PROD')) {
      return const bool.fromEnvironment('ADS_PROD');
    }
    return kReleaseMode;
  }

  String get _bannerId {
    final isIOS = !kIsWeb && Platform.isIOS;
    if (_useProdAds) {
      return isIOS
          ? GameConstants.iosBannerIdProd
          : GameConstants.androidBannerIdProd;
    }
    return isIOS ? GameConstants.iosBannerId : GameConstants.androidBannerId;
  }

  Future<void> loadBanner() async {
    if (!_available || !_initialized || _loading) return;
    // Release sin ID de producción configurado: no servir el banner de
    // test en producción ni crashear por adUnitId vacío/inválido.
    if (_bannerId.isEmpty) {
      _available = false;
      return;
    }
    _loading = true;
    try {
      await disposeBanner();
      final ad = BannerAd(
        size: AdSize.banner,
        adUnitId: _bannerId,
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            // El callback puede llegar tarde para un ad ya reemplazado por
            // disposeBanner()/otra carga — ignorarlo evita pisar el banner
            // vigente con uno obsoleto (mismo guard que onAdFailedToLoad).
            if (!identical(_banner, ad)) {
              ad.dispose();
              return;
            }
            _loaded = true;
            _adSize = (ad as BannerAd).size;
            // Una sola instancia de AdWidget — no recrear en cada build.
            _adWidget = AdWidget(ad: ad);
            notifyListeners();
          },
          onAdFailedToLoad: (ad, error) {
            ad.dispose();
            if (identical(_banner, ad)) {
              _banner = null;
              _adWidget = null;
              _adSize = null;
              _loaded = false;
              notifyListeners();
            }
          },
        ),
        request: const AdRequest(),
      );
      _banner = ad;
      _loaded = false;
      _adWidget = null;
      await ad.load();
    } catch (_) {
      // Falla de plataforma (canal nativo, config inválida, sin red al
      // despachar el request): no debe propagar y bloquear el arranque
      // de la app (ver AppController.init en main.dart).
      await disposeBanner();
    } finally {
      _loading = false;
    }
  }

  /// Altura reservada solo cuando el banner está cargado y visible.
  /// [active] debe ser true solo en la ruta visible (evita AdWidget duplicado).
  ///
  /// El `AdWidget` nativo se dibuja a su tamaño real (`AdSize.banner`, fijo en
  /// 320×50dp) y no se estira para llenar el contenedor — si se lo deja en
  /// una caja de ancho infinito, la superficie nativa deja a los costados
  /// (y, según el dispositivo, también abajo) un margen sin pintar que se ve
  /// como una franja vacía/gris. Centrarlo con su tamaño exacto evita eso en
  /// cualquier ancho de pantalla.
  Widget bannerWidget({bool active = true}) {
    final size = _adSize;
    final showAd = active && _loaded && _adWidget != null && size != null;
    if (!showAd) return const SizedBox.shrink();
    return SizedBox(
      height: GameConstants.bannerReservedHeight,
      width: double.infinity,
      child: Center(
        child: SizedBox(
          width: size.width.toDouble(),
          height: size.height.toDouble(),
          child: _adWidget!,
        ),
      ),
    );
  }

  Future<void> disposeBanner() async {
    await _banner?.dispose();
    _banner = null;
    _adWidget = null;
    _adSize = null;
    _loaded = false;
  }
}
