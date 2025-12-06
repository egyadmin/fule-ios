import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  static const String _languageKey = 'language_code';
  
  Locale _locale = const Locale('ar'); // Default to Arabic
  
  Locale get locale => _locale;
  bool get isArabic => _locale.languageCode == 'ar';
  bool get isEnglish => _locale.languageCode == 'en';

  LanguageProvider() {
    _loadSavedLanguage();
  }

  Future<void> _loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString(_languageKey) ?? 'ar';
    _locale = Locale(languageCode);
    notifyListeners();
  }

  Future<void> setLanguage(String languageCode) async {
    if (_locale.languageCode == languageCode) return;
    
    _locale = Locale(languageCode);
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, languageCode);
    
    notifyListeners();
  }

  Future<void> toggleLanguage() async {
    final newLanguage = isArabic ? 'en' : 'ar';
    await setLanguage(newLanguage);
  }

  String get currentLanguageName => isArabic ? 'العربية' : 'English';
  String get oppositeLanguageName => isArabic ? 'English' : 'العربية';
}
