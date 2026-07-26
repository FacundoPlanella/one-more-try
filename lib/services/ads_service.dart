import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../core/constants/game_constants.dart';

/// Solo banner inferior. Nunca interstitial / rewarded.
class AdsService extends ChangeNotifier {
  BannerAd? _banner;
  bool _initialized = false;
  bool _available = true;
  bool _loaded = false;

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

  String get _bannerId {
    if (!kIsWeb && Platform.isIOS) return GameConstants.iosBannerId;
    return GameConstants.androidBannerId;
  }

  Future<void> loadBanner() async {
    if (!_available || !_initialized) return;
    await disposeBanner();
    final ad = BannerAd(
      size: AdSize.banner,
      adUnitId: _bannerId,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          _loaded = true;
          notifyListeners();
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          if (identical(_banner, ad)) {
            _banner = null;
            _loaded = false;
          }
          notifyListeners();
        },
      ),
      request: const AdRequest(),
    );
    _banner = ad;
    _loaded = false;
    await ad.load();
  }

  /// Altura siempre reservada → cero layout jump (GDD §16).
  Widget bannerWidget() {
    final ad = _banner;
    return SizedBox(
      height: GameConstants.bannerReservedHeight,
      width: double.infinity,
      child: (ad != null && _loaded) ? AdWidget(ad: ad) : const SizedBox.shrink(),
    );
  }

  Future<void> disposeBanner() async {
    await _banner?.dispose();
    _banner = null;
    _loaded = false;
  }
}
