import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/auth_provider.dart';
import '../lessons/lesson_provider.dart';
import '../lessons/models/lesson.dart';
import '../lessons/lesson_screen.dart';
import '../../core/widgets/bottom_nav.dart';
import '../ai_tutor/chat_screen.dart';
import '../profile/profile_screen.dart';
import '../../core/theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const UnitListScreen(),
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

class UnitListScreen extends StatefulWidget {
  const UnitListScreen({super.key});

  @override
  State<UnitListScreen> createState() => _UnitListScreenState();
}

class _UnitListScreenState extends State<UnitListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<LessonProvider>(context, listen: false).fetchUnits();
    });
  }

  @override
  Widget build(BuildContext context) {
    final lessonProvider = Provider.of<LessonProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final userProfile = authProvider.userProfile;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.flash_on, color: AppTheme.duoOrange),
            const SizedBox(width: 4),
            Text('${userProfile?['streak'] ?? 0}'),
            const SizedBox(width: 16),
            const Icon(Icons.stars, color: AppTheme.duoBlue),
            const SizedBox(width: 4),
            Text('${userProfile?['xp'] ?? 0}'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.flag, color: AppTheme.duoBlue),
            onPressed: () {},
          ),
        ],
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: lessonProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : lessonProvider.units.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.auto_stories, size: 80, color: AppTheme.duoLightGray),
                        const SizedBox(height: 24),
                        const Text(
                          'No lessons found',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Your language journey is about to begin. Tap below to load the demo units!',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppTheme.duoGray),
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton(
                          onPressed: () => lessonProvider.seedData(),
                          child: const Text('START MY JOURNEY'),
                        ),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () => lessonProvider.fetchUnits(),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    itemCount: lessonProvider.units.length,
                    itemBuilder: (context, index) {
                      final unit = lessonProvider.units[index];
                      return UnitSection(unit: unit);
                    },
                  ),
                ),
    );
  }
}

class UnitSection extends StatelessWidget {
  final Unit unit;

  const UnitSection({super.key, required this.unit});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: AppTheme.duoGreen,
            boxShadow: [
              BoxShadow(
                color: AppTheme.duoDarkGreen,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'UNIT ${unit.order}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                unit.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        ...unit.lessons.map((lesson) => LessonNode(unit: unit, lesson: lesson)),
        const SizedBox(height: 40),
      ],
    );
  }
}

class LessonNode extends StatelessWidget {
  final Unit unit;
  final Lesson lesson;

  const LessonNode({super.key, required this.unit, required this.lesson});

  @override
  Widget build(BuildContext context) {
    // Alternate alignment for path effect
    bool isLeft = lesson.order % 2 == 0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Align(
        alignment: isLeft ? const Alignment(-0.3, 0) : const Alignment(0.3, 0),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => LessonScreen(unit: unit, lesson: lesson)),
            );
          },
          child: Column(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppTheme.duoYellow,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.duoOrange,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(Icons.star, color: Colors.white, size: 40),
              ),
              const SizedBox(height: 8),
              Text(
                lesson.title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
