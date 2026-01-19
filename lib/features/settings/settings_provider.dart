import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  bool _dailyReminders = true;
  bool _soundEffects = true;
  bool _hapticFeedback = true;
  bool _isDarkMode = false;

  bool get dailyReminders => _dailyReminders;
  bool get soundEffects => _soundEffects;
  bool get hapticFeedback => _hapticFeedback;
  bool get isDarkMode => _isDarkMode;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _dailyReminders = prefs.getBool('dailyReminders') ?? true;
    _soundEffects = prefs.getBool('soundEffects') ?? true;
    _hapticFeedback = prefs.getBool('hapticFeedback') ?? true;
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    notifyListeners();
  }

  Future<void> setDailyReminders(bool value) async {
    _dailyReminders = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dailyReminders', value);
    notifyListeners();
  }

  Future<void> setSoundEffects(bool value) async {
    _soundEffects = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('soundEffects', value);
    notifyListeners();
  }

  Future<void> setHapticFeedback(bool value) async {
    _hapticFeedback = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hapticFeedback', value);
    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    _isDarkMode = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', value);
    notifyListeners();
  }
}
