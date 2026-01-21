import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'ad_service.dart';

class AppBannerAd extends StatefulWidget {
  const AppBannerAd({super.key});

  @override
  State<AppBannerAd> createState() => _AppBannerAdState();
}

class _AppBannerAdState extends State<AppBannerAd> {
  BannerAd? _ad;

  @override
  void initState() {
    super.initState();
    _ad = AdService().loadBanner();
  }

  @override
  void dispose() {
    AdService().disposeBanner();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_ad == null) return const SizedBox.shrink();

    return SizedBox(
      height: _ad!.size.height.toDouble(),
      width: _ad!.size.width.toDouble(),
      child: AdWidget(ad: _ad!),
    );
  }
}
