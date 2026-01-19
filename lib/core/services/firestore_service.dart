import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- Units ---

  Future<QuerySnapshot> getUnits(String language) async {
    return await _db
        .collection('units')
        .where('language', isEqualTo: language)
        .where('version', isEqualTo: 4)
        .get();
  }

  Future<QuerySnapshot> getLessons(String unitId) async {
    return await _db.collection('units').doc(unitId).collection('lessons').orderBy('order').get();
  }

  Future<QuerySnapshot> getExercises(String unitId, String lessonId) async {
    return await _db.collection('units').doc(unitId).collection('lessons').doc(lessonId).collection('exercises').get();
  }

  // --- User Profile ---

  Future<DocumentSnapshot> getUserProfile(String uid) async {
    return await _db.collection('users').doc(uid).get();
  }

  Future<void> createUserProfile(String uid, Map<String, dynamic> profile) async {
    await _db.collection('users').doc(uid).set(profile);
  }

  Future<void> updateUserProfile(String uid, Map<String, dynamic> updates) async {
    await _db.collection('users').doc(uid).update(updates);
  }

  // --- Progress Tracking ---
  
  Future<void> updateLessonCompletion(String uid, String lessonId) async {
    await _db.collection('users').doc(uid).collection('completedLessons').doc(lessonId).set({
      'completedAt': FieldValue.serverTimestamp(),
    });
  }

  // --- Seed Data ---
  Future<int> seedInitialData() async {
    debugPrint('Starting Firestore Seed (Version 4)...');
    int seededCount = 0;
    final languages = {
      'amharic': {
        'name': 'Amharic', 
        'prefix': 'am',
        'basic': [
            {'q': 'Hello', 'a': 'Selam', 'opts': ['Selam', 'Ciao', 'Jambo']},
            {'q': 'Thank you', 'a': 'Ameseginalehu', 'opts': ['Ameseginalehu', 'Yikerta', 'Eshi']},
            {'q': 'Yes', 'a': 'Awo', 'opts': ['Awo', 'Aydelem', 'Min']},
            {'q': 'No', 'a': 'Aydelem', 'opts': ['Aydelem', 'Awo', 'Eshi']},
            {'q': 'Water', 'a': 'Wuha', 'opts': ['Wuha', 'Buna', 'Injera']},
            {'q': 'Coffee', 'a': 'Buna', 'opts': ['Buna', 'Shay', 'Wetet']},
            {'q': 'House', 'a': 'Bet', 'opts': ['Bet', 'Mekina', 'Menged']},
            {'q': 'Good morning', 'a': 'Endemen walu', 'opts': ['Endemen walu', 'Dehna hunu', 'Selam']},
            {'q': 'Goodbye', 'a': 'Ciao', 'opts': ['Ciao', 'Selam', 'Eshi']},
            {'q': 'Please', 'a': 'Ebakih', 'opts': ['Ebakih', 'Ameseginalehu', 'Eshi']},
        ],
        'intermediate': [
            {'q': 'I am hungry', 'a': 'Erbeognal', 'opts': ['Erbeognal', 'Temtoognal', 'Dekomognal']},
            {'q': 'Where is the hotel?', 'a': 'Hotelu yet new?', 'opts': ['Hotelu yet new?', 'Souqu yet new?', 'Mengedu yet new?']},
            {'q': 'How much is this?', 'a': 'Yihe sint new?', 'opts': ['Yihe sint new?', 'Min new?', 'Endet new?']},
            {'q': 'I would like coffee', 'a': 'Buna ifeligalehu', 'opts': ['Buna ifeligalehu', 'Wuha ifeligalehu', 'Shay ifeligalehu']},
            {'q': 'I speak a little', 'a': 'Tinish inageralehu', 'opts': ['Tinish inageralehu', 'Bezu inageralehu', 'Alnagerum']},
            {'q': 'What is your name?', 'a': 'Simeh man new?', 'opts': ['Simeh man new?', 'Yet neh?', 'Min liredah?']},
            {'q': 'I am from Ethiopia', 'a': 'Ke Ethiopia negn', 'opts': ['Ke Ethiopia negn', 'Ke America negn', 'Ke London negn?']},
            {'q': 'Excuse me', 'a': 'Yikerta', 'opts': ['Yikerta', 'Selam', 'Ameseginalehu']},
            {'q': 'I am tired', 'a': 'Dekomognal', 'opts': ['Dekomognal', 'Erbeognal', 'Temtoognal']},
            {'q': 'I am lost', 'a': 'Tefitognal', 'opts': ['Tefitognal', 'Dehina negn', 'Mekina ifeligalehu']},
        ],
        'advanced': [
            {'q': 'Ordering coffee with milk', 'a': 'Buna bewetet ifeligalehu', 'opts': ['Buna bewetet ifeligalehu', 'Buna qibe ifeligalehu', 'Wetet bicha ifeligalehu']},
            {'q': 'Asking for the bill', 'a': 'Hisab sitali?', 'opts': ['Hisab sitali?', 'Selam sitali?', 'Wuha sitali?']},
            {'q': 'Complimenting food', 'a': 'Megbu be-tam mafit new', 'opts': ['Megbu be-tam mafit new', 'Megbu tiru aydelem', 'Injera yet new?']},
            {'q': 'Negotiating price', 'a': 'Yihe waga tiku new', 'opts': ['Yihe waga tiku new', 'Wagaw rekesh new', 'Wagaw ayqeferum']},
            {'q': 'Expressing happiness', 'a': 'Siletewaweqin des biloognal', 'opts': ['Siletewaweqin des biloognal', 'Izoosh', 'Mari']},
            {'q': 'Asking for directions', 'a': 'Mengeduyet yet eyyehon new?', 'opts': ['Mengeduyet yet eyyehon new?', 'Mekina yet new?', 'Mengedu rejim new?']},
            {'q': 'Explaining health', 'a': 'Rasēn ammognal', 'opts': ['Rasēn ammognal', 'Temtoognal', 'Dehina negn']},
            {'q': 'Expressing love', 'a': 'Ewedihalehu', 'opts': ['Ewedihalehu', 'Eltelachihum', 'Ebakih']},
            {'q': 'Confirming a plan', 'a': 'Nage minagegalin', 'opts': ['Nage minagegalin', 'Dehna hun', 'Ebakih itebegegn']},
            {'q': 'Saying goodnight', 'a': 'Dehna eder', 'opts': ['Dehna eder', 'Endemen walk', 'Selam hun']},
        ]
      },
      'afaan oromo': {
        'name': 'Afaan Oromo', 
        'prefix': 'ao', 
        'basic': [
            {'q': 'Hello', 'a': 'Akkam', 'opts': ['Akkam', 'Nagaa', 'Fayyaa']},
            {'q': 'Thank you', 'a': 'Galatoomi', 'opts': ['Galatoomi', 'Dhiifama', 'Tole']},
            {'q': 'Yes', 'a': 'Eeyyee', 'opts': ['Eeyyee', 'Lakkii', 'Miti']},
            {'q': 'No', 'a': 'Lakkii', 'opts': ['Lakkii', 'Eeyyee', 'Hayyee']},
            {'q': 'Water', 'a': 'Bishaan', 'opts': ['Bishaan', 'Buna', 'Aanan']},
            {'q': 'Coffee', 'a': 'Buna', 'opts': ['Buna', 'Shaayi', 'Daakuu']},
            {'q': 'House', 'a': 'Mana', 'opts': ['Mana', 'Konkolaataa', 'Karaa']},
            {'q': 'Good morning', 'a': 'Akkam bultan', 'opts': ['Akkam bultan', 'Nagaa', 'Fayyaa']},
            {'q': 'Goodbye', 'a': 'Nagaatti', 'opts': ['Nagaatti', 'Akkam', 'Tole']},
            {'q': 'Please', 'a': 'Maaloo', 'opts': ['Maaloo', 'Galatoomi', 'Hayyee']},
        ],
        'intermediate': [
            {'q': 'I am hungry', 'a': 'Beela’eera', 'opts': ['Beela’eera', 'Dheebodheera', 'Dadhabeera']},
            {'q': 'Where is the hotel?', 'a': 'Hoteelli eessa?', 'opts': ['Hoteelli eessa?', 'Gabaan eessa?', 'Karaan eessa?']},
            {'q': 'How much is this?', 'a': 'Kun meeqa?', 'opts': ['Kun meeqa?', 'Maali kun?', 'Akkam kun?']},
            {'q': 'I would like coffee', 'a': 'Buna barbaada', 'opts': ['Buna barbaada', 'Bishaan barbaada', 'Shaayi barbaada']},
            {'q': 'I speak a little', 'a': 'Xinnoon dubbadha', 'opts': ['Xinnoon dubbadha', 'Baayee dubbadha', 'Hin dubbadhu']},
            {'q': 'What is your name?', 'a': 'Maqaan kee eenyu?', 'opts': ['Maqaan kee eenyu?', 'Eessa dhaqxa?', 'Maali si gargaaru?']},
            {'q': 'I am from Oromia', 'a': 'Oromiyaa irraayi', 'opts': ['Oromiyaa irraayi', 'Finfinnee irraayi', 'Dirree Dhawaa irraayi']},
            {'q': 'Excuse me', 'a': 'Dhiifama', 'opts': ['Dhiifama', 'Akkam', 'Galatoomi']},
            {'q': 'I am tired', 'a': 'Dadhabeera', 'opts': ['Dadhabeera', 'Beela’eera', 'Dheebodheera']},
            {'q': 'I am lost', 'a': 'Baddeera', 'opts': ['Baddeera', 'Fayyaa dha', 'Konkolaataa barbaada']},
        ],
        'advanced': [
            {'q': 'Ordering coffee with milk', 'a': 'Buna aanan qabu barbaada', 'opts': ['Buna aanan qabu barbaada', 'Buna qofaa barbaada', 'Aanan bifa barbaada']},
            {'q': 'Asking for the bill', 'a': 'Kaffaltii naaf kenni', 'opts': ['Kaffaltii naaf kenni', 'Nagaa naaf kenni', 'Bishaan naaf kenni']},
            {'q': 'Complimenting food', 'a': 'Nyaanni kun baayee mi’aawa', 'opts': ['Nyaanni kun baayee mi’aawa', 'Nyaanni kun gaarii miti', 'Injeraan eessa?']},
            {'q': 'Negotiating price', 'a': 'Gatiin kun baayee qaalii dha', 'opts': ['Gatiin kun baayee qaalii dha', 'Gatiin kun rakashaa dha', 'Gatiin kun hin jijjiiramu']},
            {'q': 'Expressing happiness', 'a': 'Wal arguun keenya na gammachiise', 'opts': ['Wal arguun keenya na gammachiise', 'Obsi', 'Sin jaalladha']},
            {'q': 'Asking for directions', 'a': 'Karaan kun eessa geessa?', 'opts': ['Karaan kun eessa geessa?', 'Konkolaataan eessa?', 'Karaan kun fagoo dha?']},
            {'q': 'Explaining health', 'a': 'Mataa na dhukkuba', 'opts': ['Mataa na dhukkuba', 'Beela’eera', 'Fayyaa dha']},
            {'q': 'Expressing love', 'a': 'Sin jaalladha', 'opts': ['Sin jaalladha', 'Sin jibba', 'Maaloo']},
            {'q': 'Confirming a plan', 'a': 'Bor wal argina', 'opts': ['Bor wal argina', 'Nagaatti buli', 'Maaloo na eegi']},
            {'q': 'Saying goodnight', 'a': 'Nagaatti buli', 'opts': ['Nagaatti buli', 'Akkam bulitan', 'Nagaa hun']},
        ]
      },
      'tigregna': {
        'name': 'Tigregna', 
        'prefix': 'ti', 
        'basic': [
            {'q': 'Hello', 'a': 'Selam', 'opts': ['Selam', 'Kemey', 'Dehan']},
            {'q': 'Thank you', 'a': 'Yekenyeley', 'opts': ['Yekenyeley', 'Yiqreta', 'Haray']},
            {'q': 'Yes', 'a': 'Uwe', 'opts': ['Uwe', 'Aykonan', 'Entay']},
            {'q': 'No', 'a': 'Aykonan', 'opts': ['Aykonan', 'Uwe', 'Haray']},
            {'q': 'Water', 'a': 'May', 'opts': ['May', 'Bun', 'Injera']},
            {'q': 'Coffee', 'a': 'Bun', 'opts': ['Bun', 'Shahi', 'Tsebhi']},
            {'q': 'House', 'a': 'Geza', 'opts': ['Geza', 'Mekina', 'Mengedi']},
            {'q': 'Good morning', 'a': 'Kemey Hadirkum', 'opts': ['Kemey Hadirkum', 'Dehan', 'Selam']},
            {'q': 'Goodbye', 'a': 'Dehan kun', 'opts': ['Dehan kun', 'Selam', 'Haray']},
            {'q': 'Please', 'a': 'Bejakha', 'opts': ['Bejakha', 'Yekenyeley', 'Haray']},
        ],
        'intermediate': [
            {'q': 'I am hungry', 'a': 'Temyey', 'opts': ['Temyey', 'Tsemiyey', 'Dikhimey']},
            {'q': 'Where is the hotel?', 'a': 'Hotelu abey alo?', 'opts': ['Hotelu abey alo?', 'Dukan abey alo?', 'Mengedi abey alo?']},
            {'q': 'How much is this?', 'a': 'Eze sintay eyu?', 'opts': ['Eze sintay eyu?', 'Intay eyu?', 'Kemey eyu?']},
            {'q': 'I would like coffee', 'a': 'Bun kidele eyye', 'opts': ['Bun kidele eyye', 'May kidele eyye', 'Shahi kidele eyye']},
            {'q': 'I speak a little', 'a': 'Qurub yizereb eyye', 'opts': ['Qurub yizereb eyye', 'Bezu yizereb eyye', 'Ayzerebn eyye']},
            {'q': 'What is your name?', 'a': 'Simka man eyu?', 'opts': ['Simka man eyu?', 'Abey aleka?', 'Entay liredaka?']},
            {'q': 'I am from Eritrea', 'a': 'Ke Ertra eyye', 'opts': ['Ke Ertra eyye', 'Ke Ethiopia eyye', 'Ke America eyye']},
            {'q': 'Excuse me', 'a': 'Yiqreta', 'opts': ['Yiqreta', 'Selam', 'Yekenyeley']},
            {'q': 'I am tired', 'a': 'Dikhimey', 'opts': ['Dikhimey', 'Temyey', 'Tsemiyey']},
            {'q': 'I am lost', 'a': 'Tefiey', 'opts': ['Tefiey', 'Dehan eyye', 'Mekina kidele eyye']},
        ],
        'advanced': [
            {'q': 'Ordering coffee with milk', 'a': 'Bun bimali kidele eyye', 'opts': ['Bun bimali kidele eyye', 'Bun bicha kidele eyye', 'May bicha kidele eyye']},
            {'q': 'Asking for the bill', 'a': 'Hisab habeni?', 'opts': ['Hisab habeni?', 'Selam habeni?', 'May habeni?']},
            {'q': 'Complimenting food', 'a': 'Eze megbē be-tam maut new', 'opts': ['Eze megbē be-tam maut new', 'Eze megbē tsuwa aykonen', 'Injera abey alo?']},
            {'q': 'Negotiating price', 'a': 'Eze waga qaalī eyu', 'opts': ['Eze waga qaalī eyu', 'Wagaw rekhash eyu', 'Wagaw ayqeferun']},
            {'q': 'Expressing happiness', 'a': 'Siletewaweqin des biloogney', 'opts': ['Siletewaweqin des biloogney', 'Izoosh', 'Mari']},
            {'q': 'Asking for directions', 'a': 'Eze mengedi abey yiwasid?', 'opts': ['Eze mengedi abey yiwasid?', 'Mekina abey alo?', 'Mengedi rejim eyu?']},
            {'q': 'Explaining health', 'a': 'Rasey amimony', 'opts': ['Rasey amimony', 'Temyey', 'Dehan eyye']},
            {'q': 'Expressing love', 'a': 'Ewedekhalehu', 'opts': ['Ewedekhalehu', 'Eltelachihum', 'Bejakha']},
            {'q': 'Confirming a plan', 'a': 'Nige minreakab', 'opts': ['Nige minreakab', 'Dehan kun', 'Bejakha itebegegn']},
            {'q': 'Saying goodnight', 'a': 'Dehan eder', 'opts': ['Dehan eder', 'Kemey hadirka', 'Selam hun']},
        ]
      },
    };

    try {
      for (var langEntry in languages.entries) {
        final batch = _db.batch();
        final langKey = langEntry.key;
        final langVal = langEntry.value;
        final prefix = langVal['prefix'] as String;
        debugPrint('Seeding $langKey...');

        final basicContent = langVal['basic'] as List<Map<String, dynamic>>;
        final intermediateContent = langVal['intermediate'] as List<Map<String, dynamic>>;
        final advancedContent = langVal['advanced'] as List<Map<String, dynamic>>;

        // --- BASIC SECTION (1 Unit, 1 Lesson, 10 Exercises) ---
        final unitIdBasic = '${prefix}_basic_u1';
        final unitRefBasic = _db.collection('units').doc(unitIdBasic);
        batch.set(unitRefBasic, {
          'title': 'Basic',
          'description': 'Basic Foundations',
          'order': 1,
          'language': langKey,
          'section': 'Basic',
          'version': 4,
        });

        final lessonIdBasic = '${prefix}_basic_l1';
        final lessonRefBasic = unitRefBasic.collection('lessons').doc(lessonIdBasic);
        batch.set(lessonRefBasic, {
          'id': lessonIdBasic,
          'title': 'Basic Assessment',
          'order': 1,
          'isLocked': false,
        });
        _seedExercises(batch, lessonRefBasic, basicContent, 'basic');

        // --- INTERMEDIATE SECTION (1 Unit, 1 Lesson, 10 Exercises) ---
        final unitIdInt = '${prefix}_int_u1';
        final unitRefInt = _db.collection('units').doc(unitIdInt);
        batch.set(unitRefInt, {
          'title': 'Intermediate',
          'description': 'Intermediate Concepts',
          'order': 2,
          'language': langKey,
          'section': 'Intermediate',
          'version': 4,
        });

        final lessonIdInt = '${prefix}_int_l1';
        final lessonRefInt = unitRefInt.collection('lessons').doc(lessonIdInt);
        batch.set(lessonRefInt, {
          'id': lessonIdInt,
          'title': 'Intermediate Assessment',
          'order': 1,
          'isLocked': true,
        });
        _seedExercises(batch, lessonRefInt, intermediateContent, 'intermediate');

        // --- ADVANCED SECTION (1 Unit, 1 Lesson, 10 Exercises) ---
        final unitIdAdv = '${prefix}_adv_u1';
        final unitRefAdv = _db.collection('units').doc(unitIdAdv);
        batch.set(unitRefAdv, {
          'title': 'Advanced',
          'description': 'Advanced Fluency',
          'order': 3,
          'language': langKey,
          'section': 'Advanced',
          'version': 4,
        });

        final lessonIdAdv = '${prefix}_adv_l1';
        final lessonRefAdv = unitRefAdv.collection('lessons').doc(lessonIdAdv);
        batch.set(lessonRefAdv, {
          'id': lessonIdAdv,
          'title': 'Advanced Mastery',
          'order': 1,
          'isLocked': true,
        });
        _seedExercises(batch, lessonRefAdv, advancedContent, 'advanced');

        await batch.commit();
        seededCount++;
        debugPrint('Successfully seeded $langKey');
      }
      return seededCount;
    } catch (e) {
      debugPrint('Error during seedInitialData: $e');
      rethrow;
    }
  }

  void _seedExercises(WriteBatch batch, DocumentReference lessonRef, List<Map<String, dynamic>> content, String levelType) {
    for (int ex = 1; ex <= 10; ex++) {
      final exRef = lessonRef.collection('exercises').doc('ex$ex');
      final item = content[(ex - 1) % content.length];
      
      String q = '';
      String a = '';
      List<String> opts = [];
      String type = 'multipleChoice';

      if (levelType == 'basic') {
        q = 'How do you say "${item['q']}"?';
        a = item['a'];
        opts = List<String>.from(item['opts']);
        opts.shuffle();
      } else if (levelType == 'intermediate') {
        if (ex % 3 == 0) {
          q = 'Speak this: ${item['a']}';
          a = item['a'];
          type = 'voice';
        } else {
          q = 'Complete: I want ____ (${item['q']})';
          a = item['a'];
          opts = List<String>.from(item['opts']);
          opts.shuffle();
          type = 'multipleChoice';
        }
      } else {
        if (ex % 2 == 0) {
          q = 'Translate: "${item['a']}" means...';
          a = item['q'];
          opts = List<String>.from(item['opts']);
          opts.shuffle();
          type = 'multipleChoice';
        } else {
          q = 'Scenario: ${item['q']} (Speak your response)';
          a = item['a'];
          type = 'aiScenario';
        }
      }

      batch.set(exRef, {
        'type': type,
        'question': q,
        'options': opts,
        'correctAnswer': a,
        'instruction': 'Question $ex of 10',
      });
    }
  }
}
