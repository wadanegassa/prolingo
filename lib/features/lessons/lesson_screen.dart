import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/auth_provider.dart';
import 'lesson_provider.dart';
import 'models/lesson.dart';
import 'exercise_widgets.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/ai_service.dart';
import 'package:confetti/confetti.dart';

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
  late ConfettiController _confettiController;
  int _correctAnswers = 0; // Track score
  
  bool _isCheckingAI = false;
  String? _aiResponse;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _loadExercises();
  }
  @override
  void dispose() {
    _confettiController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadExercises() async {
    final exercises = await Provider.of<LessonProvider>(context, listen: false)
        .fetchExercises(widget.unit.id, widget.lesson.id);
    setState(() {
      _exercises = exercises;
      _isLoading = false;
    });
  }

  Future<void> _onCheck() async {
    final exercise = _exercises[_currentIndex];
    bool correct = false;

    if (exercise.type == ExerciseType.multipleChoice || 
        exercise.type == ExerciseType.fillInTheBlank || 
        exercise.type == ExerciseType.translate) {
      correct = _selectedAnswer?.trim().toLowerCase() == exercise.correctAnswer?.trim().toLowerCase();
    } else if (exercise.type == ExerciseType.voice || exercise.type == ExerciseType.aiScenario) {
      setState(() => _isCheckingAI = true);
      
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final lang = authProvider.userProfile?['primaryLanguage'] ?? 'amharic';
      
      if (exercise.type == ExerciseType.voice) {
        // Use AI to evaluate spoken text meaning
        correct = await AIService().evaluateAnswer(
          target: exercise.correctAnswer ?? '',
          transcription: _selectedAnswer ?? '',
          language: lang,
        );
      } else {
        // AI Scenario: AI responds and judges
        _aiResponse = await AIService().getAIResponse(
          scenario: exercise.question,
          userInput: _selectedAnswer ?? '',
          language: lang,
        );
        // For scenarios, we'll assume the interaction is "correct" if the AI responded
        // or we could add a judgment logic. Let's assume correct for now to allow flow.
        correct = _aiResponse != null && !_aiResponse!.contains('Error');
      }
      
      setState(() => _isCheckingAI = false);
    } else if (exercise.type == ExerciseType.match) {
      correct = true; 
    }

    if (correct) {
      _correctAnswers++;
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      authProvider.addXP(10, section: widget.unit.section); 
    } else {
       final authProvider = Provider.of<AuthProvider>(context, listen: false);
       authProvider.deductHeart();
       
       if (authProvider.hearts <= 0) {
         _showGameOverDialog();
         return;
       }
    }

    setState(() {
      _isCorrect = correct;
      _hasChecked = true;
    });
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Out of Hearts!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.favorite_border, size: 80, color: AppTheme.duoRed),
            const SizedBox(height: 16),
            const Text('You need hearts to continue learning. Practice to earn them back or wait!'),
          ],
        ),
        actions: [
          TextButton(
             onPressed: () {
               Navigator.pop(context); // Dialog
               Navigator.pop(context); // Screen
             },
             child: const Text('QUIT'),
          ),
          ElevatedButton(
            onPressed: () {
               Provider.of<AuthProvider>(context, listen: false).refillHearts(); // Hack for demo
               Navigator.pop(context);
            },
            child: const Text('REFILL (DEMO)'),
          )
        ],
      ),
    );
  }

  void _next() {
    if (_currentIndex < _exercises.length - 1) {
      setState(() {
        _currentIndex++;
        _hasChecked = false;
        _selectedAnswer = null;
        _aiResponse = null;
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
    // Calculate Score
    final double percentage = (_correctAnswers / _exercises.length) * 100;
    
    if (percentage < 70) {
      _showFailDialog(percentage);
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final lessonProvider = Provider.of<LessonProvider>(context, listen: false);
    
    // Calculate total lessons in this section to update progress percentage
  final sectionUnits = lessonProvider.getUnitsBySection(widget.unit.section);
  final allLessonIds = sectionUnits.expand((u) => u.lessons.map((l) => l.id)).toList();
  
  authProvider.addXP(20, section: widget.unit.section); // Reward 20 XP for lesson completion
  authProvider.completeLesson(widget.lesson.id, widget.unit.section, allLessonIds);
  _confettiController.play();
    
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
            Text('Score: ${percentage.toInt()}%', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const Text('You mastered this lesson!'),
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

  void _showFailDialog(double percentage) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Lesson Failed'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.sentiment_dissatisfied, size: 80, color: AppTheme.duoRed),
            const SizedBox(height: 16),
            Text('Score: ${percentage.toInt()}%', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('You need 70% to pass. Try again!'),
          ],
        ),
        actions: [
           TextButton(
             onPressed: () {
               Navigator.pop(context); // Dialog
               Navigator.pop(context); // Screen
             },
             child: const Text('QUIT'),
           ),
           ElevatedButton(
             onPressed: () {
               Navigator.pop(context);
               // Restart lesson logic (simple reload)
               Navigator.pushReplacement(
                 context, 
                 MaterialPageRoute(builder: (context) => LessonScreen(unit: widget.unit, lesson: widget.lesson))
               );
             },
             child: const Text('RETRY'),
           )
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppTheme.duoGray),
          onPressed: () => _showQuitDialog(), // Better quit confirmation
        ),
        centerTitle: true,
        title: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            height: 16, // Thicker progress bar
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppTheme.duoLightGray,
              color: AppTheme.duoGreen,
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Icon(Icons.favorite, color: AppTheme.duoRed),
                const SizedBox(width: 4),
                Consumer<AuthProvider>(
                  builder: (context, auth, _) => Text(
                    '${auth.hearts}',
                    style: const TextStyle(
                      color: AppTheme.duoRed,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                PageView.builder(
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
                Align(
                  alignment: Alignment.topCenter,
                  child: ConfettiWidget(
                    confettiController: _confettiController,
                    blastDirectionality: BlastDirectionality.explosive,
                    shouldLoop: false,
                    colors: const [
                      AppTheme.duoGreen,
                      AppTheme.duoBlue,
                      AppTheme.duoOrange,
                      AppTheme.duoYellow,
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_aiResponse != null)
            Positioned(
              top: 100,
              left: 24,
              right: 24,
              child: _buildAIResponseBubble(),
            ),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildAIResponseBubble() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.duoBlue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.duoBlue, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.assistant, color: AppTheme.duoBlue, size: 20),
              SizedBox(width: 8),
              Text('AI Tutor', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.duoBlue)),
            ],
          ),
          const SizedBox(height: 8),
          Text(_aiResponse!, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  void _showQuitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quit Lesson?'),
        content: const Text('You will lose your progress in this lesson.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('QUIT', style: TextStyle(color: AppTheme.duoRed)),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.only(left: 24, right: 24, top: 24, bottom: 24),
      decoration: BoxDecoration(
        color: _hasChecked 
          ? (_isCorrect ? const Color(0xFFD7FFB8) : const Color(0xFFFFDFE0))
          : Colors.white,
        border: const Border(top: BorderSide(color: AppTheme.duoLightGray, width: 2)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch, // Full width button
          children: [
            if (_hasChecked) ...[
              Row(
                children: [
                   Container(
                     padding: const EdgeInsets.all(4),
                     decoration: const BoxDecoration(
                       color: Colors.white,
                       shape: BoxShape.circle,
                     ),
                     child: Icon(
                        _isCorrect ? Icons.check_circle : Icons.cancel,
                        color: _isCorrect ? AppTheme.duoGreen : AppTheme.duoRed,
                        size: 32,
                     ),
                   ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isCorrect ? 'Excellent!' : 'Correct solution:',
                        style: TextStyle(
                          color: _isCorrect ? AppTheme.duoDarkGreen : AppTheme.duoRed,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      if (!_isCorrect)
                        Text(
                          _exercises[_currentIndex].correctAnswer ?? '',
                          style: const TextStyle(color: AppTheme.duoRed, fontSize: 16),
                        ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
            ElevatedButton(
              onPressed: (_selectedAnswer == null && !_hasChecked) || _isCheckingAI 
                  ? null 
                  : (_hasChecked ? _next : _onCheck),
              style: ElevatedButton.styleFrom(
                backgroundColor: _hasChecked 
                  ? (_isCorrect ? AppTheme.duoGreen : AppTheme.duoRed)
                  : AppTheme.duoGreen,
                elevation: 4, 
              ),
              child: _isCheckingAI 
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Text(_hasChecked ? 'CONTINUE' : 'CHECK'),
            ),
          ],
        ),
      ),
    );
  }
}
