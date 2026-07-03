import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/meal_model.dart';
import '../services/database_service.dart';

class MealProvider extends ChangeNotifier {
  List<MealModel> _meals = [];
  bool _isLoading = false;

  int _calorieBudget = 2400; // Default budget

  List<MealModel> get meals => _meals;
  bool get isLoading => _isLoading;

  int get calorieBudget => _calorieBudget;

  int get todayCaloriesEaten {
    int total = 0;
    final today = DateTime.now();
    for (var meal in _meals) {
      if (meal.dateTime.year == today.year &&
          meal.dateTime.month == today.month &&
          meal.dateTime.day == today.day) {
        total += meal.calories;
      }
    }
    return total;
  }

  int get todayCarbsEaten {
    return _sumNutrient((m) => m.carbs);
  }

  int get todayProteinEaten {
    return _sumNutrient((m) => m.protein);
  }

  int get todayFatEaten {
    return _sumNutrient((m) => m.fat);
  }

  int _sumNutrient(int Function(MealModel) nutrientSelector) {
    int total = 0;
    final today = DateTime.now();
    for (var meal in _meals) {
      if (meal.dateTime.year == today.year &&
          meal.dateTime.month == today.month &&
          meal.dateTime.day == today.day) {
        total += nutrientSelector(meal);
      }
    }
    return total;
  }

  // Get meals by type for today
  List<MealModel> getMealsByType(String type) {
    final today = DateTime.now();
    return _meals.where((meal) => 
      meal.type == type &&
      meal.dateTime.year == today.year &&
      meal.dateTime.month == today.month &&
      meal.dateTime.day == today.day
    ).toList();
  }

  MealProvider() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        loadMeals();
      } else {
        _meals = [];
        notifyListeners();
      }
    });
  }

  Future<void> loadMeals() async {
    _isLoading = true;
    notifyListeners();

    _meals = await DatabaseService.getMeals();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addMeal({
    required String name,
    required int calories,
    required int carbs,
    required int protein,
    required int fat,
    required String type,
    required DateTime dateTime,
  }) async {
    final meal = MealModel(
      name: name,
      calories: calories,
      carbs: carbs,
      protein: protein,
      fat: fat,
      type: type,
      dateTime: dateTime,
    );

    await DatabaseService.insertMeal(meal);
    _meals = await DatabaseService.getMeals();
    notifyListeners();
  }

  Future<void> deleteMeal(String id) async {
    await DatabaseService.deleteMeal(id);
    _meals = await DatabaseService.getMeals();
    notifyListeners();
  }
}
