import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import '../constants/app_constants.dart';
import 'app_strings.dart';

/// Provider for instant runtime switching across English, Deutsch, and Arabic.
class LocaleProvider extends ChangeNotifier {
  final GetStorage _storage = GetStorage();
  late String _languageCode;

  LocaleProvider() {
    _languageCode =
        _storage.read<String>(AppConstants.storageKeyDisplayLanguage) ?? 'en';
  }

  String get languageCode => _languageCode;
  bool get isArabic => _languageCode == 'ar';
  bool get isGerman => _languageCode == 'de';
  bool get isEnglish => _languageCode == 'en';
  bool get isRtl => _languageCode == 'ar';
  TextDirection get textDirection =>
      isRtl ? TextDirection.rtl : TextDirection.ltr;

  void setLocale(String code) {
    if (code == _languageCode) return;
    if (code != 'en' && code != 'de' && code != 'ar') return;

    _languageCode = code;
    _storage.write(AppConstants.storageKeyDisplayLanguage, code);
    notifyListeners();
  }

  /// Helper to fetch localized string by key
  String tr(String key, [Map<String, String>? params]) {
    String text = AppStrings.get(key, _languageCode);
    if (params != null) {
      params.forEach((paramKey, paramValue) {
        text = text.replaceAll('{$paramKey}', paramValue);
      });
    }
    return text;
  }
}
