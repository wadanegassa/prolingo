import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- User Profile Operations ---

  Future<void> createUserProfile(String uid, Map<String, dynamic> data) async {
    await _db.collection('users').doc(uid).set(data);
  }

  Future<DocumentSnapshot> getUserProfile(String uid) async {
    return await _db.collection('users').doc(uid).get();
  }

  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    await _db.collection('users').doc(uid).update(data);
  }

  Stream<DocumentSnapshot> streamUserProfile(String uid) {
    return _db.collection('users').doc(uid).snapshots();
  }

  // --- Lessons & Exercises Operations ---

  Future<QuerySnapshot> getUnits() async {
    return await _db.collection('units').orderBy('order').get();
  }

  Future<QuerySnapshot> getLessons(String unitId) async {
    return await _db.collection('units').doc(unitId).collection('lessons').orderBy('order').get();
  }

  Future<QuerySnapshot> getExercises(String unitId, String lessonId) async {
    return await _db.collection('units').doc(unitId).collection('lessons').doc(lessonId).collection('exercises').get();
  }

  // --- Progress Tracking ---
  
  Future<void> updateLessonCompletion(String uid, String lessonId) async {
    await _db.collection('users').doc(uid).collection('completedLessons').doc(lessonId).set({
      'completedAt': FieldValue.serverTimestamp(),
    });
  }

  // --- Seed Data ---
  Future<void> seedInitialData() async {
    // Check if data already exists
    final snapshot = await _db.collection('units').get();
    if (snapshot.docs.isNotEmpty) return;

    final batch = _db.batch();

    // Unit 1: Basics
    final unit1Ref = _db.collection('units').doc('unit1');
    batch.set(unit1Ref, {
      'title': 'The Basics',
      'description': 'Learn your first 10 words in Amharic',
      'order': 1,
    });

    // Lesson 1: Greetings
    final lesson1Ref = unit1Ref.collection('lessons').doc('lesson1');
    batch.set(lesson1Ref, {
      'title': 'Greetings',
      'order': 1,
      'isLocked': false,
    });

    // Exercises for Lesson 1
    final exercise1Ref = lesson1Ref.collection('exercises').doc('ex1');
    batch.set(exercise1Ref, {
      'type': 'multipleChoice',
      'question': 'How do you say "Hello" in Amharic?',
      'options': ['Selam', 'Ameseginalehu', 'Ciao'],
      'correctAnswer': 'Selam',
      'instruction': 'Common greeting',
    });

    final exercise2Ref = lesson1Ref.collection('exercises').doc('ex2');
    batch.set(exercise2Ref, {
      'type': 'translate',
      'question': 'Selam',
      'amharicText': 'ሰላም',
      'correctAnswer': 'Hello',
      'instruction': 'Translate to English',
    });

    final exercise3Ref = lesson1Ref.collection('exercises').doc('ex3');
    batch.set(exercise3Ref, {
      'type': 'match',
      'instruction': 'Match the pairs',
      'matchPairs': {
        'Selam': 'Hello',
        'Ameseginalehu': 'Thank you',
        'Dehna': 'Good/Fine'
      }
    });

    await batch.commit();
  }
}
