import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PreferencesService {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Prefix keys with the user's UID to isolate user data
  static String get _userIdPrefix {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    return uid != null ? '${uid}_' : '';
  }

  // Session Getters
  static bool get isLoggedIn => FirebaseAuth.instance.currentUser != null;
  static String get userName => FirebaseAuth.instance.currentUser?.displayName ?? '';
  static String get userEmail => FirebaseAuth.instance.currentUser?.email ?? '';
  
  // Daily Goals Getters
  static int get goalSteps => _prefs?.getInt('${_userIdPrefix}goal_steps') ?? 10000;
  static int get goalCalories => _prefs?.getInt('${_userIdPrefix}goal_calories') ?? 2500;

  // Setters
  static Future<void> setLoginState({
    required bool isLoggedIn,
    String name = '',
    String email = '',
  }) async {
    // Firebase Auth handles state, keeping for compatibility
  }

  static Future<void> setGoals({
    required int steps,
    required int calories,
  }) async {
    await _prefs?.setInt('${_userIdPrefix}goal_steps', steps);
    await _prefs?.setInt('${_userIdPrefix}goal_calories', calories);
  }

  static Future<void> clearSession() async {
    // Firebase Auth handles state, keeping for compatibility
  }

  // Legacy registration stub for Mock Authentication
  static Future<void> registerUser({
    required String name,
    required String email,
    required String password,
  }) async {
    // No-op
  }

  static bool checkCredentials(String email, String password) {
    return false;
  }

  static String getRegisteredName() {
    return 'Demo User';
  }

  // Daily Metrics (Water & Steps) keyed by Date (YYYY-MM-DD)
  static int getWaterIntake(String dateStr) {
    return _prefs?.getInt('${_userIdPrefix}water_$dateStr') ?? 0;
  }

  static Future<void> setWaterIntake(String dateStr, int amount) async {
    await _prefs?.setInt('${_userIdPrefix}water_$dateStr', amount);
  }

  static int getStepCount(String dateStr) {
    return _prefs?.getInt('${_userIdPrefix}steps_$dateStr') ?? 0;
  }

  static Future<void> setStepCount(String dateStr, int count) async {
    await _prefs?.setInt('${_userIdPrefix}steps_$dateStr', count);
  }

  // Theme Management
  static String getThemeMode() {
    return _prefs?.getString('theme_mode') ?? 'system';
  }

  static Future<void> setThemeMode(String themeMode) async {
    await _prefs?.setString('theme_mode', themeMode);
  }
}
