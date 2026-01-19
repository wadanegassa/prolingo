import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/auth_provider.dart';
import '../lessons/lesson_provider.dart';
import '../../core/widgets/bottom_nav.dart';
import '../ai_tutor/chat_screen.dart';
import '../profile/profile_screen.dart';
import '../../core/theme/app_theme.dart';
import 'widgets/level_card.dart';
import '../lessons/lesson_screen.dart';

enum LessonStatus { locked, active, completed }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const LevelSelectionScreen(),
    const AIChatScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

class LevelSelectionScreen extends StatefulWidget {
  const LevelSelectionScreen({super.key});

  @override
  State<LevelSelectionScreen> createState() => _LevelSelectionScreenState();
}

class _LevelSelectionScreenState extends State<LevelSelectionScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final lang = authProvider.userProfile?['primaryLanguage'] ?? 'amharic';
      Provider.of<LessonProvider>(context, listen: false).fetchUnits(lang);
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final lessonProvider = Provider.of<LessonProvider>(context);
    
    if (lessonProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Check if we need to seed data for this language
    if (lessonProvider.units.isEmpty) {
      final lang = authProvider.userProfile?['primaryLanguage'] ?? 'amharic';
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.auto_stories, size: 80, color: AppTheme.duoLightGray),
            const SizedBox(height: 24),
            Text(
              'Welcome to ${lang.toUpperCase()}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => lessonProvider.seedData(lang),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.duoGreen,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: const Text('START MY JOURNEY'),
            ),
          ],
        ),
      );
    }

    final userProfile = authProvider.userProfile;
    final String lang = userProfile?['primaryLanguage'] ?? 'amharic';
    
    // Safety check for new data structure
    final Map<String, dynamic> langData = 
        (userProfile?['languages'] != null && userProfile!['languages'][lang] != null) 
        ? userProfile['languages'][lang] 
        : {};

    final int streak = userProfile?['streak'] ?? 0;

    // Progress
    final double basicProgress = (langData['basicProgress'] ?? 0.0).toDouble();
    final double intermediateProgress = (langData['intermediateProgress'] ?? 0.0).toDouble();
    final double advancedProgress = (langData['advancedProgress'] ?? 0.0).toDouble();

    // Unlock Logic: Requires Progress >= 100% AND XP requirement
    final int basicXP = langData['basicXP'] ?? 0;
    final int interXP = langData['interXP'] ?? 0;
    final int advXP = langData['advXP'] ?? 0;

    final String currentLevel = langData['currentLevel'] ?? 'Basic';
    final int totalLangXP = langData['xp'] ?? 0;
    
    bool isIntermediateLocked = totalLangXP < 100; 
    bool isAdvancedLocked = totalLangXP < 200;

    debugPrint('Level Selection State: currentLevel=$currentLevel, totalXP=$totalLangXP');

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.flash_on, color: AppTheme.duoOrange),
            const SizedBox(width: 4),
            Text('$streak'),
            const SizedBox(width: 16),
            const Icon(Icons.stars, color: AppTheme.duoBlue),
            const SizedBox(width: 4),
            Text('${langData['xp'] ?? 0}'), // Total XP for this language
            const Expanded(child: SizedBox()),
            IconButton(
              icon: const Icon(Icons.flag, color: AppTheme.duoBlue),
              onPressed: () => _showLanguagePicker(context, authProvider),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 40, top: 20),
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Text(
              "Your Learning Path",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          
          LevelCard(
            levelName: 'Basic',
            progress: basicProgress / 100, // Scale 0-100 to 0-1
            isLocked: false,
            xp: basicXP,
            onTap: () => _launchQuiz(context, 'Basic'),
          ),
          
          LevelCard(
            levelName: 'Intermediate',
            progress: intermediateProgress / 100,
            isLocked: isIntermediateLocked,
            lockedReason: 'NEED 100 XP',
            xp: interXP,
            onTap: isIntermediateLocked ? null : () { _launchQuiz(context, 'Intermediate'); },
          ),
          
          LevelCard(
            levelName: 'Advanced',
            progress: advancedProgress / 100,
            isLocked: isAdvancedLocked,
            lockedReason: 'NEED 200 XP',
            xp: advXP,
            onTap: isAdvancedLocked ? null : () { _launchQuiz(context, 'Advanced'); },
          ),
        ],
      ),
    );
  }

  Future<void> _launchQuiz(BuildContext context, String levelName) async {
    final lessonProvider = Provider.of<LessonProvider>(context, listen: false);
    
    // Get the section's units
    final units = lessonProvider.getUnitsBySection(levelName);
    
    if (units.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No content available for this level')),
      );
      return;
    }

    // Get the first unit for this level (prioritize versioned or just the first)
    final unit = units.isNotEmpty ? units.first : null;
    
    if (unit == null || unit.lessons.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No lessons available')),
      );
      return;
    }

    // Get the first (and only) lesson
    final lesson = unit.lessons.first;
    
    // Navigate to LessonScreen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LessonScreen(unit: unit, lesson: lesson),
      ),
    );
  }

  void _showLanguagePicker(BuildContext context, AuthProvider authProvider) {
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Switch Language', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _langTile(context, authProvider, 'Amharic', 'amharic'),
            _langTile(context, authProvider, 'Afaan Oromo', 'afaan oromo'),
            _langTile(context, authProvider, 'Tigregna', 'tigregna'),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _langTile(BuildContext context, AuthProvider authProvider, String title, String code) {
    final currentLang = authProvider.userProfile?['primaryLanguage'] ?? 'amharic';
    final isSelected = currentLang == code;

    return ListTile(
      title: Text(title, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      trailing: isSelected ? const Icon(Icons.check_circle, color: AppTheme.duoGreen) : null,
      onTap: () {
        if (!isSelected) {
          authProvider.setPrimaryLanguage(code);
          Provider.of<LessonProvider>(context, listen: false).fetchUnits(code);
        }
        Navigator.pop(context);
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}

