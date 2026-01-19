import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:prolingo/auth/auth_provider.dart';
import 'package:prolingo/features/lessons/lesson_provider.dart';
import 'package:prolingo/features/lessons/models/lesson.dart';
import 'package:prolingo/features/lessons/lesson_screen.dart';
import 'package:prolingo/core/theme/app_theme.dart';
// Home Screen import might not be needed if I duplicate LessonNode, but sticking to plan

// Note: Assuming LessonNode and LessonPathPainter are movable or public. 
// I will likely need to duplicate or move them. For now I'll duplicate to ensure isolation and then clean up.

class LevelMapScreen extends StatelessWidget {
  final String levelName;

  const LevelMapScreen({super.key, required this.levelName});

  @override
  Widget build(BuildContext context) {
    final lessonProvider = Provider.of<LessonProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    
    // Get units for this level
    // levelName matches 'Basic', 'Intermediate', 'Advanced'
    final units = lessonProvider.getUnitsBySection(levelName);
    
    final userProfile = authProvider.userProfile;
    final primaryLang = userProfile?['primaryLanguage'] ?? '';
    final langData = userProfile?['languages']?[primaryLang] ?? {};
    final completedLessons = List<String>.from(langData['completedLessons'] ?? []);
    
    // Find active lesson (first incomplete one)
    String? activeLessonId;
    bool foundActive = false;
    for (var unit in units) {
      for (var lesson in unit.lessons) {
        if (!completedLessons.contains(lesson.id)) {
          if (!foundActive) {
            activeLessonId = lesson.id;
            foundActive = true;
          }
        }
      }
    }
    
    Color levelColor;
    switch (levelName) {
      case 'Intermediate': levelColor = AppTheme.duoBlue; break;
      case 'Advanced': levelColor = AppTheme.duoOrange; break;
      default: levelColor = AppTheme.duoGreen;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(levelName.toUpperCase(), style: TextStyle(color: levelColor, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: units.isEmpty
          ? const Center(child: Text("No content available for this level yet."))
          : ListView.builder(
              padding: const EdgeInsets.only(bottom: 40),
              itemCount: units.length,
              itemBuilder: (context, index) {
                final unit = units[index];
                return Column(
                  children: [
                    // _buildUnitHeader removed as per user request
                    _UnitMap(
                      unit: unit,
                      completedLessons: completedLessons,
                      activeLessonId: activeLessonId,
                      levelColor: levelColor,
                    ),
                  ],
                );
              },
            ),
    );
  }
  

}

class _UnitMap extends StatelessWidget {
  final Unit unit;
  final List<String> completedLessons;
  final String? activeLessonId;
  final Color levelColor;

  const _UnitMap({
    required this.unit,
    required this.completedLessons,
    required this.activeLessonId,
    required this.levelColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _LessonPathPainter(lessonCount: unit.lessons.length),
              ),
            ),
            Column(
              children: unit.lessons.map((lesson) {
                _LessonNodeStatus status = _LessonNodeStatus.locked;
                if (completedLessons.contains(lesson.id)) {
                  status = _LessonNodeStatus.completed;
                } else if (lesson.id == activeLessonId) {
                  status = _LessonNodeStatus.active;
                }
                
                return _LessonNode(
                  unit: unit,
                  lesson: lesson,
                  status: status,
                  baseColor: levelColor,
                );
              }).toList(),
            ),
            // Floating Mascot
            Positioned(
              bottom: 20,
              right: 20,
              child: _FloatingMascot(),
            ),
          ],
        ),
        const SizedBox(height: 40),
      ],
    );
  }
}

enum _LessonNodeStatus { locked, active, completed }

class _LessonNode extends StatelessWidget {
  final Unit unit;
  final Lesson lesson;
  final _LessonNodeStatus status;
  final Color baseColor;

  const _LessonNode({
    required this.unit,
    required this.lesson,
    required this.status,
    required this.baseColor,
  });

  @override
  Widget build(BuildContext context) {
    bool isLeft = lesson.order % 2 == 0;
    
    Color circleColor;
    Color shadowColor;
    IconData icon;
    
    switch (status) {
      case _LessonNodeStatus.completed:
        circleColor = AppTheme.duoYellow;
        shadowColor = AppTheme.duoOrange;
        icon = Icons.check;
        break;
      case _LessonNodeStatus.active:
        circleColor = baseColor;
        shadowColor = baseColor.withValues(alpha: 0.7); // Darker approx
        icon = Icons.star;
        break;
      case _LessonNodeStatus.locked:
        circleColor = AppTheme.duoLightGray;
        shadowColor = Colors.grey[400]!;
        icon = Icons.lock;
        break;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Align(
        alignment: isLeft ? const Alignment(-0.3, 0) : const Alignment(0.3, 0),
        child: InkWell(
          onTap: status == _LessonNodeStatus.locked 
              ? null 
              : () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LessonScreen(unit: unit, lesson: lesson)),
                );
              },
          borderRadius: BorderRadius.circular(40),
          child: Column(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: circleColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: shadowColor,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 40),
              ),
              const SizedBox(height: 8),
              Text(
                lesson.title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: status == _LessonNodeStatus.locked ? AppTheme.duoGray : Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LessonPathPainter extends CustomPainter {
  final int lessonCount;
  
  _LessonPathPainter({required this.lessonCount});

  @override
  void paint(Canvas canvas, Size size) {
    if (lessonCount <= 1) return;

    final paint = Paint()
      ..color = Colors.grey[300]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    final path = Path();
    
    double itemHeight = 136.0; 
    double startY = itemHeight / 2;

    for (int i = 0; i < lessonCount - 1; i++) {
      bool isLeft = i % 2 == 0;
      bool nextIsLeft = (i + 1) % 2 == 0;
      
      double x1 = size.width * (isLeft ? 0.35 : 0.65);
      double y1 = startY + (i * itemHeight);
      
      double x2 = size.width * (nextIsLeft ? 0.35 : 0.65);
      double y2 = startY + ((i + 1) * itemHeight);
      
      if (i == 0) path.moveTo(x1, y1);
      
      double ctrlY = (y1 + y2) / 2;
      path.quadraticBezierTo(
        (x1 + x2) / 2, 
        ctrlY,         
        x2, y2
      );
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _FloatingMascot extends StatelessWidget {
  const _FloatingMascot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2), // Corrected alpha usage
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Icon(Icons.pets, size: 40, color: AppTheme.duoGreen),
          Positioned(
            right: 15,
            top: 15,
            child: Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
