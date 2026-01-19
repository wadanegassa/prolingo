import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/auth_provider.dart';
import 'lesson_provider.dart';
import 'models/lesson.dart';
import 'exercise_widgets.dart';
import '../../core/theme/app_theme.dart';

class LessonScreen extends StatefulWidget {
  final Unit unit;
  final Lesson lesson;

  const LessonScreen({super.key, required this.unit, required this.lesson});

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  final PageController _pageController = PageController();
  List<Exercise> _exercises = [];
  int _currentIndex = 0;
  bool _isLoading = true;
  String? _selectedAnswer;
  bool _isCorrect = false;
  bool _hasChecked = false;

  @override
  void initState() {
    super.initState();
    _loadExercises();
  }

  Future<void> _loadExercises() async {
    final exercises = await Provider.of<LessonProvider>(context, listen: false)
        .fetchExercises(widget.unit.id, widget.lesson.id);
    setState(() {
      _exercises = exercises;
      _isLoading = false;
    });
  }

  void _onCheck() {
    final exercise = _exercises[_currentIndex];
    bool correct = false;

    if (exercise.type == ExerciseType.multipleChoice || exercise.type == ExerciseType.fillInTheBlank || exercise.type == ExerciseType.translate) {
      correct = _selectedAnswer?.trim().toLowerCase() == exercise.correctAnswer?.trim().toLowerCase();
    } else if (exercise.type == ExerciseType.match) {
      // Simple match logic for now
      correct = true; // TODO: Implement robust match validation
    }

    setState(() {
      _isCorrect = correct;
      _hasChecked = true;
    });
  }

  void _next() {
    if (_currentIndex < _exercises.length - 1) {
      setState(() {
        _currentIndex++;
        _hasChecked = false;
        _selectedAnswer = null;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finishLesson();
    }
  }

  void _finishLesson() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.addXP(20); // Reward 20 XP for lesson completion
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Lesson Complete!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.emoji_events, size: 80, color: AppTheme.duoYellow),
            const SizedBox(height: 16),
            const Text('You earned 20 XP!'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Dialog
              Navigator.pop(context); // LessonScreen
            },
            child: const Text('CONTINUE'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_exercises.isEmpty) return const Scaffold(body: Center(child: Text('No exercises found.')));

    final progress = (_currentIndex + 1) / _exercises.length;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppTheme.duoGray),
          onPressed: () => Navigator.pop(context),
        ),
        title: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: AppTheme.duoLightGray,
            color: AppTheme.duoGreen,
            minHeight: 12,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _exercises.length,
              itemBuilder: (context, index) {
                final exercise = _exercises[index];
                return ExerciseWidget(
                  exercise: exercise,
                  onSelect: (val) => setState(() => _selectedAnswer = val),
                  selectedValue: _selectedAnswer,
                );
              },
            ),
          ),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _hasChecked 
          ? (_isCorrect ? const Color(0xFFD7FFB8) : const Color(0xFFFFDFE0))
          : Colors.white,
        border: const Border(top: BorderSide(color: AppTheme.duoLightGray, width: 2)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_hasChecked) ...[
            Row(
              children: [
                Icon(
                  _isCorrect ? Icons.check_circle : Icons.error,
                  color: _isCorrect ? AppTheme.duoGreen : AppTheme.duoRed,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Text(
                  _isCorrect ? 'Excellent!' : 'Correct solution:',
                  style: TextStyle(
                    color: _isCorrect ? AppTheme.duoDarkGreen : AppTheme.duoRed,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            if (!_isCorrect) 
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  _exercises[_currentIndex].correctAnswer ?? '',
                  style: const TextStyle(color: AppTheme.duoRed),
                ),
              ),
            const SizedBox(height: 16),
          ],
          ElevatedButton(
            onPressed: (_selectedAnswer == null && !_hasChecked) ? null : (_hasChecked ? _next : _onCheck),
            style: ElevatedButton.styleFrom(
              backgroundColor: _hasChecked 
                ? (_isCorrect ? AppTheme.duoGreen : AppTheme.duoRed)
                : AppTheme.duoGreen,
            ),
            child: Text(_hasChecked ? 'CONTINUE' : 'CHECK'),
          ),
        ],
      ),
    );
  }
}
