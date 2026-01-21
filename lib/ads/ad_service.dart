import 'dart:ui';

import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'ad_ids.dart';

class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  BannerAd? _bannerAd;
  RewardedAd? _rewardedAd;

  // ───────── INIT ─────────
  static Future<void> init() async {
    await MobileAds.instance.initialize();
  }

  // ───────── BANNER ─────────
  BannerAd? loadBanner() {
    _bannerAd ??= BannerAd(
      adUnitId: AdIds.banner,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          _bannerAd = null;
        },
      ),
    )..load();

    return _bannerAd;
  }

  void disposeBanner() {
    _bannerAd?.dispose();
    _bannerAd = null;
  }

  // ───────── REWARDED ─────────
  void loadRewarded() {
    RewardedAd.load(
      adUnitId: AdIds.rewarded,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) => _rewardedAd = ad,
        onAdFailedToLoad: (_) => _rewardedAd = null,
      ),
    );
  }

  void showRewarded({required VoidCallback onReward}) {
    if (_rewardedAd == null) return;

    _rewardedAd!.show(
      onUserEarnedReward: (_, __) => onReward(),
    );

    _rewardedAd = null;
    loadRewarded(); // preload next
  }
}
