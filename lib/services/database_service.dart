import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/activity_model.dart';
import '../models/meal_model.dart';

class DatabaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static String? get _userId => FirebaseAuth.instance.currentUser?.uid;

  static CollectionReference<Map<String, dynamic>>? get _activitiesCollection {
    final uid = _userId;
    if (uid == null) return null;
    return _firestore.collection('users').doc(uid).collection('activities');
  }

  // Insert Activity
  static Future<String> insertActivity(ActivityModel activity) async {
    final col = _activitiesCollection;
    if (col == null) throw Exception("User not authenticated");

    final data = activity.toMap();
    // Remove 'id' field from document body as the document ID serves as the identifier
    data.remove('id');

    if (activity.id != null) {
      await col.doc(activity.id).set(data);
      return activity.id!;
    } else {
      final docRef = await col.add(data);
      return docRef.id;
    }
  }

  // Get All Activities
  static Future<List<ActivityModel>> getActivities() async {
    final col = _activitiesCollection;
    if (col == null) return [];

    try {
      final snapshot = await col.orderBy('date_time', descending: true).get();
      return snapshot.docs.map((doc) {
        return ActivityModel.fromMap(doc.data(), doc.id);
      }).toList();
    } catch (e) {
      // In case indices are still building or other firestore errors, fall back to unordered local list
      final snapshot = await col.get();
      final list = snapshot.docs.map((doc) {
        return ActivityModel.fromMap(doc.data(), doc.id);
      }).toList();
      list.sort((a, b) => b.dateTime.compareTo(a.dateTime));
      return list;
    }
  }

  // Delete Activity
  static Future<void> deleteActivity(String id) async {
    final col = _activitiesCollection;
    if (col == null) return;
    await col.doc(id).delete();
  }

  // Clear Database (e.g. for user logout or data reset)
  static Future<void> clearAllActivities() async {
    final col = _activitiesCollection;
    if (col == null) return;
    final snapshot = await col.get();
    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  // --- Meals CRUD ---

  static CollectionReference<Map<String, dynamic>>? get _mealsCollection {
    final uid = _userId;
    if (uid == null) return null;
    return _firestore.collection('users').doc(uid).collection('meals');
  }

  static Future<String> insertMeal(MealModel meal) async {
    final col = _mealsCollection;
    if (col == null) throw Exception("User not authenticated");

    final data = meal.toMap();
    data.remove('id');

    if (meal.id.isNotEmpty) {
      await col.doc(meal.id).set(data);
      return meal.id;
    } else {
      final docRef = await col.add(data);
      return docRef.id;
    }
  }

  static Future<List<MealModel>> getMeals() async {
    final col = _mealsCollection;
    if (col == null) return [];

    try {
      final snapshot = await col.orderBy('dateTime', descending: true).get();
      return snapshot.docs.map((doc) {
        return MealModel.fromMap(doc.data(), doc.id);
      }).toList();
    } catch (e) {
      final snapshot = await col.get();
      final list = snapshot.docs.map((doc) {
        return MealModel.fromMap(doc.data(), doc.id);
      }).toList();
      list.sort((a, b) => b.dateTime.compareTo(a.dateTime));
      return list;
    }
  }

  static Future<void> deleteMeal(String id) async {
    final col = _mealsCollection;
    if (col == null) return;
    await col.doc(id).delete();
  }
}
