import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdMobService {
  RewardedAd? _rewardedAd;
  bool _isLoadingAd = false;

  // Official Google AdMob Test Rewarded Ad Unit IDs
  static String get rewardedAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/5224354917';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/1712485313';
    }
    return 'ca-app-pub-3940256099942544/5224354917';
  }

  void initialize() {
    try {
      MobileAds.instance.initialize();
      loadRewardedAd();
    } catch (e) {
      debugPrint('[AdMobService] Error initializing MobileAds: $e');
    }
  }

  void loadRewardedAd() {
    if (_isLoadingAd || _rewardedAd != null) return;
    _isLoadingAd = true;

    try {
      RewardedAd.load(
        adUnitId: rewardedAdUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            debugPrint('[AdMobService] Rewarded ad loaded successfully');
            _rewardedAd = ad;
            _isLoadingAd = false;
          },
          onAdFailedToLoad: (error) {
            debugPrint('[AdMobService] Failed to load rewarded ad: $error');
            _rewardedAd = null;
            _isLoadingAd = false;
          },
        ),
      );
    } catch (e) {
      debugPrint('[AdMobService] Exception during RewardedAd.load: $e');
      _isLoadingAd = false;
    }
  }

  void showRewardedAd({
    required VoidCallback onRewardEarned,
    required VoidCallback onDismissed,
    required VoidCallback onAdNotReady,
  }) {
    if (_rewardedAd == null) {
      debugPrint('[AdMobService] Rewarded ad not ready, invoking graceful fallback');
      loadRewardedAd();
      onAdNotReady();
      return;
    }

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedAd = null;
        loadRewardedAd();
        onDismissed();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('[AdMobService] Failed to show rewarded ad: $error');
        ad.dispose();
        _rewardedAd = null;
        loadRewardedAd();
        onAdNotReady();
      },
    );

    _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        debugPrint('[AdMobService] User earned reward: ${reward.amount} ${reward.type}');
        onRewardEarned();
      },
    );
  }
}
