import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/activity_model.dart';
import '../services/database_service.dart';
import '../services/preferences_service.dart';

class ActivityProvider extends ChangeNotifier {
  List<ActivityModel> _activities = [];
  bool _isLoading = false;

  int _todayWater = 0;
  int _todaySteps = 0;
  int _stepsGoal = 10000;
  int _caloriesGoal = 2500;

  List<ActivityModel> get activities => _activities;
  bool get isLoading => _isLoading;

  int get todayWater => _todayWater;
  int get todaySteps => _todaySteps;
  int get stepsGoal => _stepsGoal;
  int get caloriesGoal => _caloriesGoal;

  // Constructor
  ActivityProvider() {
    // Listen to real-time auth changes to reload user-specific metrics and data
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        loadAllData();
      } else {
        _activities = [];
        _todayWater = 0;
        _todaySteps = 0;
        notifyListeners();
      }
    });
  }

  String get _todayDateStr => DateFormat('yyyy-MM-dd').format(DateTime.now());

  Future<void> loadAllData() async {
    _isLoading = true;
    notifyListeners();

    // Load goals from SharedPreferences (defaults: 10000 steps, 2500 kcal)
    _stepsGoal = PreferencesService.goalSteps;
    _caloriesGoal = PreferencesService.goalCalories;

    // Load today's real water and steps (0 if user hasn't logged any)
    _todayWater = PreferencesService.getWaterIntake(_todayDateStr);
    _todaySteps = PreferencesService.getStepCount(_todayDateStr);

    // Load only the user's own activities from Firestore — no seeding
    _activities = await DatabaseService.getActivities();

    _isLoading = false;
    notifyListeners();
  }

  // Activity CRUD
  Future<void> addActivity({
    required String type,
    required int duration,
    required int calories,
    required DateTime dateTime,
  }) async {
    final activity = ActivityModel(
      activityType: type,
      duration: duration,
      calories: calories,
      dateTime: dateTime,
    );

    await DatabaseService.insertActivity(activity);
    _activities = await DatabaseService.getActivities();
    notifyListeners();
  }

  Future<void> deleteActivity(String id) async {
    await DatabaseService.deleteActivity(id);
    _activities = await DatabaseService.getActivities();
    notifyListeners();
  }

  // Increment metrics
  Future<void> addWater(int amountMl) async {
    _todayWater += amountMl;
    await PreferencesService.setWaterIntake(_todayDateStr, _todayWater);
    notifyListeners();
  }

  Future<void> addSteps(int stepsCount) async {
    _todaySteps += stepsCount;
    await PreferencesService.setStepCount(_todayDateStr, _todaySteps);
    notifyListeners();
  }

  // Update Goals
  Future<void> updateGoals(int steps, int calories) async {
    _stepsGoal = steps;
    _caloriesGoal = calories;
    await PreferencesService.setGoals(steps: steps, calories: calories);
    notifyListeners();
  }

  // Helper values for Dashboard
  int get todayCaloriesBurned {
    int total = 0;
    final today = DateTime.now();
    for (var act in _activities) {
      if (act.dateTime.year == today.year &&
          act.dateTime.month == today.month &&
          act.dateTime.day == today.day) {
        total += act.calories;
      }
    }
    return total;
  }

  int get todayWorkoutMinutes {
    int total = 0;
    final today = DateTime.now();
    for (var act in _activities) {
      if (act.dateTime.year == today.year &&
          act.dateTime.month == today.month &&
          act.dateTime.day == today.day) {
        total += act.duration;
      }
    }
    return total;
  }

  // Get active days stats for chart (Last 7 days)
  List<DailyChartData> getWeeklyChartData() {
    final List<DailyChartData> list = [];
    final now = DateTime.now();
    for (int i = 6; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));
      final dateStr = DateFormat('yyyy-MM-dd').format(day);
      final dayName = DateFormat('E').format(day); // e.g. Mon, Tue

      // Calories from workouts on this day
      int workoutCalories = 0;
      for (var act in _activities) {
        if (act.dateTime.year == day.year &&
            act.dateTime.month == day.month &&
            act.dateTime.day == day.day) {
          workoutCalories += act.calories;
        }
      }

      // We can also assume a baseline of active steps calories: steps * 0.04
      final steps = i == 0 ? _todaySteps : PreferencesService.getStepCount(dateStr);
      final stepsCalories = (steps * 0.04).round();

      list.add(DailyChartData(
        dayName: dayName,
        date: day,
        workoutCalories: workoutCalories,
        stepsCalories: stepsCalories,
        totalCalories: workoutCalories + stepsCalories,
      ));
    }
    return list;
  }

  Future<void> clearAllUserData() async {
    await DatabaseService.clearAllActivities();
    _activities.clear();
    
    // Clear today's metrics
    _todayWater = 0;
    _todaySteps = 0;
    
    notifyListeners();
  }
}

class DailyChartData {
  final String dayName;
  final DateTime date;
  final int workoutCalories;
  final int stepsCalories;
  final int totalCalories;

  DailyChartData({
    required this.dayName,
    required this.date,
    required this.workoutCalories,
    required this.stepsCalories,
    required this.totalCalories,
  });
}
