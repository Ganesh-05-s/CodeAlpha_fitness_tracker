class ActivityModel {
  final String? id;
  final String activityType;
  final int duration; // in minutes
  final int calories; // kcal burned
  final DateTime dateTime;

  ActivityModel({
    this.id,
    required this.activityType,
    required this.duration,
    required this.calories,
    required this.dateTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'activity_type': activityType,
      'duration': duration,
      'calories': calories,
      'date_time': dateTime.toIso8601String(),
    };
  }

  factory ActivityModel.fromMap(Map<String, dynamic> map, [String? docId]) {
    return ActivityModel(
      id: docId ?? map['id'] as String?,
      activityType: map['activity_type'] as String,
      duration: map['duration'] as int,
      calories: map['calories'] as int,
      dateTime: DateTime.parse(map['date_time'] as String),
    );
  }

  // Copy with helper
  ActivityModel copyWith({
    String? id,
    String? activityType,
    int? duration,
    int? calories,
    DateTime? dateTime,
  }) {
    return ActivityModel(
      id: id ?? this.id,
      activityType: activityType ?? this.activityType,
      duration: duration ?? this.duration,
      calories: calories ?? this.calories,
      dateTime: dateTime ?? this.dateTime,
    );
  }
}
