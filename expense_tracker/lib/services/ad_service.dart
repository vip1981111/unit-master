import 'dart:io';

import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  // Test Ad IDs
  static const String _testBannerIdAndroid = 'ca-app-pub-3940256099942544/6300978111';
  static const String _testBannerIdIOS = 'ca-app-pub-3940256099942544/2934735716';
  static const String _testInterstitialIdAndroid = 'ca-app-pub-3940256099942544/1033173712';
  static const String _testInterstitialIdIOS = 'ca-app-pub-3940256099942544/4411468910';

  // Production Ad IDs - TODO: Replace with actual IDs
  static const String _prodBannerIdAndroid = 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';
  static const String _prodBannerIdIOS = 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';
  static const String _prodInterstitialIdAndroid = 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';
  static const String _prodInterstitialIdIOS = 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';

  // Use test ads in debug mode
  static const bool _useTestAds = true; // Set to false for production

  static String get bannerAdUnitId {
    if (_useTestAds) {
      return Platform.isAndroid ? _testBannerIdAndroid : _testBannerIdIOS;
    }
    return Platform.isAndroid ? _prodBannerIdAndroid : _prodBannerIdIOS;
  }

  static String get interstitialAdUnitId {
    if (_useTestAds) {
      return Platform.isAndroid ? _testInterstitialIdAndroid : _testInterstitialIdIOS;
    }
    return Platform.isAndroid ? _prodInterstitialIdAndroid : _prodInterstitialIdIOS;
  }

  InterstitialAd? _interstitialAd;
  bool _isInterstitialAdReady = false;
  int _interstitialLoadAttempts = 0;
  static const int _maxFailedLoadAttempts = 3;

  bool get isInterstitialReady => _isInterstitialAdReady;

  // Banner Ad
  BannerAd createBannerAd({
    required Function() onAdLoaded,
    required Function(LoadAdError) onAdFailedToLoad,
  }) {
    return BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) => onAdLoaded(),
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          onAdFailedToLoad(error);
        },
      ),
    );
  }

  // Interstitial Ad
  void loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialAdReady = true;
          _interstitialLoadAttempts = 0;

          _interstitialAd!.setImmersiveMode(true);
        },
        onAdFailedToLoad: (error) {
          _interstitialLoadAttempts++;
          _isInterstitialAdReady = false;

          if (_interstitialLoadAttempts < _maxFailedLoadAttempts) {
            loadInterstitialAd();
          }
        },
      ),
    );
  }

  void showInterstitialAd({Function()? onAdDismissed}) {
    if (!_isInterstitialAdReady || _interstitialAd == null) {
      onAdDismissed?.call();
      return;
    }

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _isInterstitialAdReady = false;
        onAdDismissed?.call();
        loadInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _isInterstitialAdReady = false;
        onAdDismissed?.call();
        loadInterstitialAd();
      },
    );

    _interstitialAd!.show();
  }

  void dispose() {
    _interstitialAd?.dispose();
  }
}
