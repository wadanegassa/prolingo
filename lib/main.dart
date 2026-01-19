import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'auth/auth_provider.dart';
import 'auth/login_screen.dart';
import 'features/home/home_screen.dart';
import 'features/lessons/lesson_provider.dart';
import 'features/ai_tutor/ai_provider.dart';
import 'features/onboarding/language_selection_screen.dart';
import 'features/settings/settings_provider.dart';
import 'core/services/ai_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // --- AI INITIALIZATION ---
  // To unlock full AI features, replace 'YOUR_API_KEY_HERE' with your real Gemini API Key.
  // ProTip: Use 'flutter run --dart-define=GEMINI_API_KEY=your_key_here'
  const apiKey = String.fromEnvironment('GEMINI_API_KEY', defaultValue: 'AIzaSyAOelLNZ_MK8co5fUm3y8Xumn_jRojjabs');
  AIService().init(apiKey);
  // --------------------------
  
  runApp(const ProLingoApp());
}

class ProLingoApp extends StatelessWidget {
  const ProLingoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => LessonProvider()),
        ChangeNotifierProvider(create: (_) => AIProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return MaterialApp(
            title: 'ProLingo AI',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: const AuthWrapper(),
          );
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    if (authProvider.isAuthenticated) {
      final profile = authProvider.userProfile;
      if (profile != null) {
        final List selectedLangs = profile['selectedLanguages'] ?? [];
        if (selectedLangs.isEmpty) {
          return const LanguageSelectionScreen();
        }
      }
      return const HomeScreen();
    } else {
      return const LoginScreen();
    }
  }
}
