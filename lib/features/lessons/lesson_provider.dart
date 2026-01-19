import 'package:flutter/material.dart';
import '../../core/services/firestore_service.dart';
import 'models/lesson.dart';

class LessonProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<Unit> _units = [];
  bool _isLoading = false;

  List<Unit> get units => _units;
  bool get isLoading => _isLoading;

  Future<void> seedData() async {
    _isLoading = true;
    notifyListeners();
    await _firestoreService.seedInitialData();
    await fetchUnits();
  }

  Future<void> fetchUnits() async {
    _isLoading = true;
    notifyListeners();

    try {
      final unitsSnapshot = await _firestoreService.getUnits();
      _units = [];
      
      for (var unitDoc in unitsSnapshot.docs) {
        final unitData = unitDoc.data() as Map<String, dynamic>;
        final unit = Unit.fromFirestore(unitDoc.id, unitData);
        
        // Fetch lessons for this unit
        final lessonsSnapshot = await _firestoreService.getLessons(unitDoc.id);
        final lessons = lessonsSnapshot.docs.map((doc) {
          return Lesson.fromFirestore(doc.id, doc.data() as Map<String, dynamic>);
        }).toList();

        _units.add(Unit(
          id: unit.id,
          title: unit.title,
          description: unit.description,
          order: unit.order,
          lessons: lessons,
        ));
      }
    } catch (e) {
      debugPrint('Error fetching units: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<List<Exercise>> fetchExercises(String unitId, String lessonId) async {
    try {
      final exercisesSnapshot = await _firestoreService.getExercises(unitId, lessonId);
      return exercisesSnapshot.docs.map((doc) {
        return Exercise.fromFirestore(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      debugPrint('Error fetching exercises: $e');
      return [];
    }
  }

  // Logic for locking/unlocking lessons could go here or in AuthProvider (based on user progress)
}
