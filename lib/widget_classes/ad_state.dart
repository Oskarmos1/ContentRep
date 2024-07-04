import 'dart:io';

import 'package:google_mobile_ads/google_mobile_ads.dart';

//actual id: ca-app-pub-7471100637488619/7198587992

class AdMobService {
  static String? get bannerAdUnitId {
    if (Platform.isAndroid) {
      //return 'ca-app-pub-7471100637488619/7081617044';
      return 'ca-app-pub-3940256099942544/9257395921';
    } else if (Platform.isIOS) {
      return 'IOS NOT DONE';
    } else {
      return 'Not recognised';
    }
  }

  static final BannerAdListener bannerListener = BannerAdListener(
      onAdLoaded: (ad) => print("LOADED"),
      onAdFailedToLoad: (ad, error) {
        ad.dispose();
        print("FAILED TO LOAD $error");
      },
      onAdOpened: (ad) => print("OPENED"),
      onAdClosed: (ad) => print("CLOSED"));
}
