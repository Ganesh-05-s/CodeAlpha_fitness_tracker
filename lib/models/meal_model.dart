class MealModel {
  final String id;
  final String name;
  final int calories;
  final int carbs;
  final int protein;
  final int fat;
  final String type; // 'Breakfast', 'Lunch', 'Dinner', 'Snack'
  final DateTime dateTime;

  MealModel({
    this.id = '',
    required this.name,
    required this.calories,
    required this.carbs,
    required this.protein,
    required this.fat,
    required this.type,
    required this.dateTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'calories': calories,
      'carbs': carbs,
      'protein': protein,
      'fat': fat,
      'type': type,
      'dateTime': dateTime.toIso8601String(),
    };
  }

  factory MealModel.fromMap(Map<String, dynamic> map, String docId) {
    return MealModel(
      id: docId,
      name: map['name'] ?? 'Unknown',
      calories: map['calories']?.toInt() ?? 0,
      carbs: map['carbs']?.toInt() ?? 0,
      protein: map['protein']?.toInt() ?? 0,
      fat: map['fat']?.toInt() ?? 0,
      type: map['type'] ?? 'Snack',
      dateTime: map['dateTime'] != null 
          ? DateTime.parse(map['dateTime']) 
          : DateTime.now(),
    );
  }
}
