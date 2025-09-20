import 'package:flutter/material.dart';

class LanguageProvider extends ChangeNotifier {
  bool _isPunjabi = false;

  bool get isPunjabi => _isPunjabi;

  /// Toggle between English and Punjabi
  void toggleLanguage() {
    _isPunjabi = !_isPunjabi;
    notifyListeners();
  }

  /// Get text based on selected language
  String getText(String english, String punjabi) {
    return _isPunjabi ? punjabi : english;
  }
}
