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

  User? get user => _user;
  Map<String, dynamic>? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    _authService.user.listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    _user = firebaseUser;
    if (firebaseUser != null) {
      await _fetchUserProfile(firebaseUser.uid);
    } else {
      _userProfile = null;
    }
    notifyListeners();
  }

  Future<void> _fetchUserProfile(String uid) async {
    final doc = await _firestoreService.getUserProfile(uid);
    if (doc.exists) {
      _userProfile = doc.data() as Map<String, dynamic>?;
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
      if (credential?.user != null) {
        final profile = {
          "name": name,
          "email": email,
          "learningLanguage": "amharic",
          "xp": 0,
          "level": 1,
          "streak": 0,
          "createdAt": DateTime.now().toIso8601String(),
        };
        await _firestoreService.createUserProfile(credential!.user!.uid, profile);
        _userProfile = profile;
      }
    } catch (e) {
      _setLoading(false);
      rethrow;
    }
    _setLoading(false);
  }

  Future<void> logout() async {
    await _authService.signOut();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Update XP and Level logic
  Future<void> addXP(int amount) async {
    if (_user == null || _userProfile == null) return;

    int currentXP = _userProfile!['xp'] ?? 0;
    
    int newXP = currentXP + amount;
    // Simple level up logic: every 100 XP is a level
    int newLevel = (newXP / 100).floor() + 1;

    final updates = {
      'xp': newXP,
      'level': newLevel,
    };

    await _firestoreService.updateUserProfile(_user!.uid, updates);
    _userProfile!.addAll(updates);
    notifyListeners();
  }
}
