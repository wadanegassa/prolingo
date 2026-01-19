import 'package:flutter/material.dart';
import '../../core/services/firestore_service.dart';
import 'models/lesson.dart';

class LessonProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<Unit> _units = [];
  bool _isLoading = false;

  List<Unit> get units => _units;
  bool get isLoading => _isLoading;

  List<Unit> getUnitsBySection(String section) {
    return _units.where((u) => u.section == section).toList();
  }


  Future<int> seedData(String language) async {
    _isLoading = true;
    notifyListeners();
    try {
      final count = await _firestoreService.seedInitialData();
      await fetchUnits(language);
      return count;
    } catch (e) {
      debugPrint('Error seeding data: $e');
      _isLoading = false;
      notifyListeners();
      return 0;
    }
  }

  Future<void> fetchUnits(String language) async {
    _isLoading = true;
    notifyListeners();

    try {
      final unitsSnapshot = await _firestoreService.getUnits(language);
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
          section: unit.section,
          lessons: lessons,
        ));
      }
      
      // Sort units locally to avoid requiring composite indexes in Firestore
      _units.sort((a, b) => a.order.compareTo(b.order));
    } catch (e) {
      debugPrint('Error fetching units: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<List<Exercise>> fetchExercises(String unitId, String lessonId) async {
    try {
      final exercisesSnapshot = await _firestoreService.getExercises(unitId, lessonId);
      final exercises = exercisesSnapshot.docs.map((doc) {
        return Exercise.fromFirestore(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
      
      // Sort by document ID (ex1, ex2, ..., ex10)
      exercises.sort((a, b) => a.id.compareTo(b.id));
      
      return exercises;
    } catch (e) {
      debugPrint('Error fetching exercises: $e');
      return [];
    }
  }

  // Logic for locking/unlocking lessons could go here or in AuthProvider (based on user progress)
}
