import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/services/auth_service.dart';
import '../core/services/firestore_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  User? _user;
  Map<String, dynamic>? _userProfile;
  bool _isLoading = false;
  int _hearts = 5; // Default hearts

  User? get user => _user;
  Map<String, dynamic>? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;
  int get hearts => _hearts;

  AuthProvider() {
    _authService.user.listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    _user = firebaseUser;
    if (firebaseUser != null) {
      await _fetchUserProfile(firebaseUser.uid);
    } else {
      _userProfile = null;
      _hearts = 5;
    }
    notifyListeners();
  }

  Future<void> _fetchUserProfile(String uid) async {
    final doc = await _firestoreService.getUserProfile(uid);
    if (doc.exists) {
      _userProfile = doc.data() as Map<String, dynamic>?;
      _hearts = _userProfile?['hearts'] ?? 5;
    }
  }
  
  Future<void> login(String email, String password) async {
    _setLoading(true);
    try {
      await _authService.signIn(email, password);
    } catch (e) {
      _setLoading(false);
      rethrow;
    }
    _setLoading(false);
  }

  Future<void> register(String name, String email, String password) async {
    _setLoading(true);
    try {
      final credential = await _authService.register(email, password);
      // Profile will be initialized with no languages; user will pick them in onboarding
      if (credential?.user != null) {
        final profile = {
          "name": name,
          "email": email,
          "selectedLanguages": [],
          "primaryLanguage": "",
          "xp": {},
          "hearts": 5, // Initialize hearts
          "levels": {},
          "streak": 0,
          "completedLessons": {}, 
          "createdAt": DateTime.now().toIso8601String(),
        };
        await _firestoreService.createUserProfile(credential!.user!.uid, profile);
        _userProfile = profile;
        _hearts = 5;
      }
    } catch (e) {
      _setLoading(false);
      rethrow;
    }
    _setLoading(false);
  }
  
  Future<void> deductHeart() async {
    if (_hearts > 0) {
      _hearts--;
      notifyListeners();
      if (_user != null) {
         await _firestoreService.updateUserProfile(_user!.uid, {'hearts': _hearts});
         _userProfile?['hearts'] = _hearts;
      }
    }
  }

  Future<void> refillHearts() async {
    _hearts = 5;
    notifyListeners();
    if (_user != null) {
      await _firestoreService.updateUserProfile(_user!.uid, {'hearts': _hearts});
      _userProfile?['hearts'] = _hearts;
    }
  }

  Future<void> setSelectedLanguages(List<String> languages, String primary) async {
    if (_user == null || _userProfile == null) return;

    final updates = {
      'selectedLanguages': languages,
      'primaryLanguage': primary,
      'languages': {
        for (var lang in languages)
          lang: {
            'basicProgress': 0.0,
            'intermediateProgress': 0.0,
            'advancedProgress': 0.0,
            'currentLevel': 'Basic',
            'xp': 0, // Total XP for this language
            'basicXP': 0,
            'interXP': 0,
            'advXP': 0,
            'completedLessons': [],
          }
      }
    };

    await _firestoreService.updateUserProfile(_user!.uid, updates);
    _userProfile!.addAll(updates);
    notifyListeners();
  }

  Future<void> addXP(int amount, {String section = 'Basic'}) async {
    if (_user == null || _userProfile == null) return;

    String currentLang = _userProfile!['primaryLanguage'] ?? '';
    if (currentLang.isEmpty) return;

    Map<String, dynamic> languagesMap = Map<String, dynamic>.from(_userProfile!['languages'] ?? {});
    Map<String, dynamic> langData = Map<String, dynamic>.from(languagesMap[currentLang] ?? {});
    
    if (langData.isEmpty) {
      langData = {
        'basicProgress': 0.0,
        'intermediateProgress': 0.0,
        'advancedProgress': 0.0,
        'currentLevel': 'Basic',
        'xp': 0,
        'basicXP': 0, 'interXP': 0, 'advXP': 0,
        'completedLessons': [],
      };
    }

    // Update global and level-specific XP
    int currentTotalXP = (langData['xp'] ?? 0);
    langData['xp'] = currentTotalXP + amount;

    if (section == 'Basic') {
      langData['basicXP'] = (langData['basicXP'] ?? 0) + amount;
    } else if (section == 'Intermediate') {
      langData['interXP'] = (langData['interXP'] ?? 0) + amount;
    } else if (section == 'Advanced') {
      langData['advXP'] = (langData['advXP'] ?? 0) + amount;
    }
    
    languagesMap[currentLang] = langData;
    await _firestoreService.updateUserProfile(_user!.uid, {'languages': languagesMap});
    _userProfile!['languages'] = languagesMap;
    notifyListeners();
  }

  Future<void> completeLesson(String lessonId, String section, List<String> allLessonIdsInSection) async {
    if (_user == null || _userProfile == null) return;
    
    String currentLang = _userProfile!['primaryLanguage'] ?? '';
    if (currentLang.isEmpty) return;

    Map<String, dynamic> languagesMap = Map<String, dynamic>.from(_userProfile!['languages'] ?? {});
    Map<String, dynamic> langData = Map<String, dynamic>.from(languagesMap[currentLang] ?? {});
    
    if (langData.isEmpty) {
      langData = {
        'basicProgress': 0.0,
        'intermediateProgress': 0.0,
        'advancedProgress': 0.0,
        'currentLevel': 'Basic',
        'xp': 0, 'basicXP': 0, 'interXP': 0, 'advXP': 0,
        'completedLessons': [],
      };
    }

    List<String> finished = List<String>.from(langData['completedLessons'] ?? []);
    
    if (!finished.contains(lessonId)) {
      finished.add(lessonId);
      langData['completedLessons'] = finished;
    }

    // New Accuracy Logic: Filter completed lessons by the ones provided for this section
    if (allLessonIdsInSection.isNotEmpty) {
      int completedInSection = finished.where((id) => allLessonIdsInSection.contains(id)).length;
      double progress = (completedInSection / allLessonIdsInSection.length) * 100;
      
      String key = '${section.toLowerCase()}Progress'; 
      langData[key] = progress;
      
      debugPrint('Progress for $section: $progress% ($completedInSection/${allLessonIdsInSection.length})');

      // UNLOCK LOGIC: XP-based (100 XP for Int, 200 XP for Adv)
      int totalLangXP = langData['xp'] ?? 0;
      
      if (section == 'Basic' && totalLangXP >= 100) {
          if (langData['currentLevel'] == 'Basic') {
               langData['currentLevel'] = 'Intermediate';
               debugPrint('Logic: Unlocked Intermediate (XP: $totalLangXP)');
          }
      } else if (section == 'Intermediate' && totalLangXP >= 200) {
          if (langData['currentLevel'] == 'Intermediate') {
               langData['currentLevel'] = 'Advanced';
               debugPrint('Logic: Unlocked Advanced (XP: $totalLangXP)');
          }
      }
    }
    
    languagesMap[currentLang] = langData;
    await _firestoreService.updateUserProfile(_user!.uid, {'languages': languagesMap});
    _userProfile!['languages'] = languagesMap;
    notifyListeners();
  }
  
  // Deprecated or kept for specific manual updates if needed
  Future<void> updateSectionProgress(String section, double progress) async {
    // This now just calls completeLesson or is integrated
    // For safety, let's keep it but make it robust
    if (_user == null || _userProfile == null) return;
    String currentLang = _userProfile!['primaryLanguage'] ?? '';
    
    Map<String, dynamic> languagesMap = Map<String, dynamic>.from(_userProfile!['languages'] ?? {});
    Map<String, dynamic> langData = Map<String, dynamic>.from(languagesMap[currentLang] ?? {});

    String key = '${section.toLowerCase()}Progress'; 
    langData[key] = progress;
    
    int totalLangXP = langData['xp'] ?? 0;
    
    if (section == 'Basic' && totalLangXP >= 100) {
      langData['currentLevel'] = 'Intermediate';
    } else if (section == 'Intermediate' && totalLangXP >= 200) {
      langData['currentLevel'] = 'Advanced';
    }

    languagesMap[currentLang] = langData;
    await _firestoreService.updateUserProfile(_user!.uid, {'languages': languagesMap});
    _userProfile!['languages'] = languagesMap;
    notifyListeners();
  }

  Future<void> setPrimaryLanguage(String language) async {
    if (_user == null || _userProfile == null) return;
    
    // Ensure the language map exists for this language
    Map<String, dynamic> languagesMap = Map<String, dynamic>.from(_userProfile!['languages'] ?? {});
    if (!languagesMap.containsKey(language)) {
      languagesMap[language] = {
        'basicProgress': 0.0,
        'intermediateProgress': 0.0,
        'advancedProgress': 0.0,
        'currentLevel': 'Basic',
        'xp': 0,
        'basicXP': 0,
        'interXP': 0,
        'advXP': 0,
        'completedLessons': [],
      };
    }

    final updates = {
      'primaryLanguage': language,
      'languages': languagesMap,
    };

    await _firestoreService.updateUserProfile(_user!.uid, updates);
    _userProfile!['primaryLanguage'] = language;
    _userProfile!['languages'] = languagesMap;
    notifyListeners();
  }

  Future<void> resetProgress() async {
    if (_user == null || _userProfile == null) return;
    
    // Wipe all language data, reset hearts, reset streak
    final updates = {
      'hearts': 5,
      'streak': 0,
      'xp': {},
      'completedLessons': {},
      'languages': {}, // This will force re-initialization on next use
      'selectedLanguages': [],
      'primaryLanguage': '',
    };

    await _firestoreService.updateUserProfile(_user!.uid, updates);
    _userProfile!.addAll(updates);
    _hearts = 5;
    notifyListeners();
  }

  Future<void> logout() async {
    await _authService.signOut();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
