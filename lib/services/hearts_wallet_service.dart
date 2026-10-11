import 'package:flutter/foundation.dart';
import 'package:get_storage/get_storage.dart';
import '../core/constants/app_constants.dart';

/// Service managing the Hearts power system, user streak, and unlocked curriculum levels.
class HeartsWalletService extends ChangeNotifier {
  final GetStorage _storage = GetStorage();

  late int _hearts;
  late int _streakDays;
  DateTime? _lastStreakDate;
  late String _cefrLevel;
  late String _learningGoal;
  late int _totalSpeakingTurns;
  late int _totalAdsWatched;
  late double _speechSpeed;
  final Set<int> _unlockedLevels = {1};
  final Set<int> _completedLevels = {};
  int _activeRecallSuccessCount = 0;

  int get hearts => _hearts;
  int get streakDays => _streakDays;
  DateTime? get lastStreakDate => _lastStreakDate;
  String get cefrLevel => _cefrLevel;
  String get learningGoal => _learningGoal;
  int get totalSpeakingTurns => _totalSpeakingTurns;
  int get totalAdsWatched => _totalAdsWatched;
  double get speechSpeed => _speechSpeed;
  Set<int> get unlockedLevels => Set.unmodifiable(_unlockedLevels);
  Set<int> get completedLevels => Set.unmodifiable(_completedLevels);
  int get activeRecallSuccessCount => _activeRecallSuccessCount;

  bool get hasHearts => _hearts >= AppConstants.heartCostPerSpeakingTurn;
  bool isLevelUnlocked(int level) => _unlockedLevels.contains(level);
  bool isLevelCompleted(int level) => _completedLevels.contains(level);

  HeartsWalletService() {
    _loadState();
    _evaluateDailyStreak();
  }

  void _loadState() {
    final hasAppliedStarter =
        _storage.read<bool>('greta_starter_applied_v1') ?? false;

    if (!hasAppliedStarter) {
      _hearts = AppConstants.initialStarterHearts; // 15 free hearts
      _storage.write('greta_starter_applied_v1', true);
      _storage.write(AppConstants.storageKeyHearts, _hearts);
    } else {
      _hearts = _storage.read<int>(AppConstants.storageKeyHearts) ??
          AppConstants.initialStarterHearts;
    }

    _streakDays = _storage.read<int>(AppConstants.storageKeyStreak) ?? 1;

    final storedDate =
        _storage.read<String>(AppConstants.storageKeyLastStreakDate);
    if (storedDate != null) {
      _lastStreakDate = DateTime.tryParse(storedDate);
    }

    _cefrLevel = _storage.read<String>(AppConstants.storageKeyCefrLevel) ?? 'A1';
    _learningGoal = _storage.read<String>(AppConstants.storageKeySelectedGoal) ??
        'Daily Conversation ☕';
    _totalSpeakingTurns =
        _storage.read<int>(AppConstants.storageKeyTotalSpeakingTurns) ?? 0;
    _totalAdsWatched =
        _storage.read<int>(AppConstants.storageKeyTotalAdsWatched) ?? 0;
    _speechSpeed =
        _storage.read<double>(AppConstants.storageKeySpeechSpeed) ?? 1.0;

    final rawUnlocked =
        _storage.read<List<dynamic>>(AppConstants.storageKeyUnlockedLevels);
    if (rawUnlocked != null) {
      for (final l in rawUnlocked) {
        if (l is int) _unlockedLevels.add(l);
      }
    } else {
      _unlockedLevels.add(1);
    }

    final rawCompleted =
        _storage.read<List<dynamic>>(AppConstants.storageKeyCompletedLevels);
    if (rawCompleted != null) {
      for (final l in rawCompleted) {
        if (l is int) _completedLevels.add(l);
      }
    }
  }

  void _saveState() {
    _storage.write(AppConstants.storageKeyHearts, _hearts);
    _storage.write(AppConstants.storageKeyStreak, _streakDays);
    if (_lastStreakDate != null) {
      _storage.write(
        AppConstants.storageKeyLastStreakDate,
        _lastStreakDate!.toIso8601String(),
      );
    }
    _storage.write(AppConstants.storageKeyCefrLevel, _cefrLevel);
    _storage.write(AppConstants.storageKeySelectedGoal, _learningGoal);
    _storage.write(
      AppConstants.storageKeyTotalSpeakingTurns,
      _totalSpeakingTurns,
    );
    _storage.write(
      AppConstants.storageKeyTotalAdsWatched,
      _totalAdsWatched,
    );
    _storage.write(AppConstants.storageKeySpeechSpeed, _speechSpeed);
    _storage.write(
      AppConstants.storageKeyUnlockedLevels,
      _unlockedLevels.toList(),
    );
    _storage.write(
      AppConstants.storageKeyCompletedLevels,
      _completedLevels.toList(),
    );
  }

  void _evaluateDailyStreak() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (_lastStreakDate == null) {
      _lastStreakDate = today;
      _saveState();
      return;
    }

    final lastDateOnly = DateTime(
      _lastStreakDate!.year,
      _lastStreakDate!.month,
      _lastStreakDate!.day,
    );

    final differenceInDays = today.difference(lastDateOnly).inDays;

    if (differenceInDays == 1) {
      _streakDays += 1;
      _hearts += AppConstants.dailyStreakHearts;
      _lastStreakDate = today;
      _saveState();
      notifyListeners();
    } else if (differenceInDays > 1) {
      _streakDays = 1;
      _hearts += AppConstants.dailyStreakHearts;
      _lastStreakDate = today;
      _saveState();
      notifyListeners();
    }
  }

  /// Deducts 1 Heart for a speaking turn.
  bool deductSpeakingTurnHeart() {
    if (_hearts >= AppConstants.heartCostPerSpeakingTurn) {
      _hearts -= AppConstants.heartCostPerSpeakingTurn;
      _totalSpeakingTurns += 1;
      _saveState();
      notifyListeners();
      return true;
    }
    return false;
  }

  /// Deducts hearts to attempt or unlock a level.
  bool deductLevelHeart({int amount = AppConstants.heartCostPerLevelAttempt}) {
    if (_hearts >= amount) {
      _hearts -= amount;
      _saveState();
      notifyListeners();
      return true;
    }
    return false;
  }

  /// Grants +15 hearts from watching a rewarded ad.
  void grantAdRewardHearts({int amount = AppConstants.rewardedAdHeartsRefill}) {
    _hearts += amount;
    _totalAdsWatched += 1;
    _activeRecallSuccessCount += 1;
    _saveState();
    notifyListeners();
  }

  /// Unlocks a curriculum level.
  void unlockLevel(int level) {
    if (!_unlockedLevels.contains(level)) {
      _unlockedLevels.add(level);
      _saveState();
      notifyListeners();
    }
  }

  /// Marks a curriculum level as completed and unlocks the next level.
  void completeLevel(int level) {
    _completedLevels.add(level);
    if (level < 600) {
      _unlockedLevels.add(level + 1);
    }
    _saveState();
    notifyListeners();
  }

  void setCefrLevel(String level) {
    if (_cefrLevel != level) {
      _cefrLevel = level;
      _saveState();
      notifyListeners();
    }
  }

  void setLearningGoal(String goal) {
    if (_learningGoal != goal) {
      _learningGoal = goal;
      _saveState();
      notifyListeners();
    }
  }

  void setSpeechSpeed(double speed) {
    if (_speechSpeed != speed) {
      _speechSpeed = speed;
      _saveState();
      notifyListeners();
    }
  }

  /// Resets all local progress for fresh start or compliance.
  void resetAllProgress() {
    _hearts = AppConstants.initialStarterHearts;
    _streakDays = 1;
    _lastStreakDate = DateTime.now();
    _cefrLevel = 'A1';
    _learningGoal = 'Daily Conversation ☕';
    _totalSpeakingTurns = 0;
    _totalAdsWatched = 0;
    _speechSpeed = 1.0;
    _unlockedLevels.clear();
    _unlockedLevels.add(1);
    _completedLevels.clear();
    _activeRecallSuccessCount = 0;
    _storage.erase();
    _saveState();
    notifyListeners();
  }
}
