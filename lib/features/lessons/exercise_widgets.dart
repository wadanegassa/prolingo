import 'package:flutter/material.dart';
import 'models/lesson.dart';
import '../../core/theme/app_theme.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';

class ExerciseWidget extends StatelessWidget {
  final Exercise exercise;
  final Function(String) onSelect;
  final String? selectedValue;

  const ExerciseWidget({
    super.key,
    required this.exercise,
    required this.onSelect,
    this.selectedValue,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            exercise.instruction ?? _getDefaultInstruction(),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4B4B4B),
            ),
          ),
          const SizedBox(height: 32),
          _buildQuestionArea(),
          const SizedBox(height: 32),
          Expanded(child: _buildOptionsArea()),
        ],
      ),
    );
  }

  String _getDefaultInstruction() {
    switch (exercise.type) {
      case ExerciseType.multipleChoice:
        return 'Select the correct meaning';
      case ExerciseType.match:
        return 'Match the pairs';
      case ExerciseType.fillInTheBlank:
        return 'Fill in the blank';
      case ExerciseType.translate:
        return 'Translate this sentence';
      case ExerciseType.voice:
        return 'Speak this sentence';
      case ExerciseType.aiScenario:
        return 'Respond to the scenario';
    }
  }

  Widget _buildQuestionArea() {
    if (exercise.type == ExerciseType.translate) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: AppTheme.duoLightGray, width: 2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const Icon(Icons.volume_up, color: AppTheme.duoBlue),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                exercise.amharicText ?? exercise.question,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      );
    }
    return Text(
      exercise.question,
      style: const TextStyle(fontSize: 20),
    );
  }

  Widget _buildOptionsArea() {
    switch (exercise.type) {
      case ExerciseType.multipleChoice:
        return ListView.separated(
          itemCount: exercise.options.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final option = exercise.options[index];
            final isSelected = selectedValue == option;
            return ChoiceCard(
              text: option,
              isSelected: isSelected,
              onTap: () => onSelect(option),
            );
          },
        );
      case ExerciseType.match:
        return MatchExercise(
          exercise: exercise,
          onComplete: (pairs) {
            onSelect('matched'); // Signal completion
          },
        );
      case ExerciseType.translate:
      case ExerciseType.fillInTheBlank:
        return TextField(
          onChanged: onSelect,
          decoration: const InputDecoration(
            hintText: 'Type your answer here...',
          ),
          style: const TextStyle(fontSize: 18),
        );
      case ExerciseType.voice:
      case ExerciseType.aiScenario:
        return VoiceExerciseWidget(
          exercise: exercise,
          onTranscribed: onSelect,
        );
    }
  }
}

class ChoiceCard extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  const ChoiceCard({
    super.key,
    required this.text,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer( // animated container for smooth transition
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFDDF4FF) : Colors.white,
          border: Border.all(
            color: isSelected ? AppTheme.duoBlue : AppTheme.duoLightGray,
            width: isSelected ? 2.5 : 2, // Thicker border when selected
            strokeAlign: BorderSide.strokeAlignInside, // Keep size constant
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
             // "Button" style shadow (solid color offset)
             BoxShadow(
                color: isSelected ? AppTheme.duoDarkBlue : AppTheme.duoLightGray,
                offset: const Offset(0, 4),
                blurRadius: 0, 
              ),
          ],
        ),
        child: Row(
          children: [
            Container( // Custom check circle
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.duoBlue : Colors.transparent,
                border: Border.all(
                  color: isSelected ? AppTheme.duoBlue : AppTheme.duoLightGray,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(8), // Rounded square check
              ),
              child: isSelected
                  ? const Center(
                      child: Icon(Icons.check, size: 16, color: Colors.white),
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? AppTheme.duoBlue : const Color(0xFF4B4B4B),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MatchExercise extends StatefulWidget {
  final Exercise exercise;
  final Function(Map<String, String>) onComplete;

  const MatchExercise({super.key, required this.exercise, required this.onComplete});

  @override
  State<MatchExercise> createState() => _MatchExerciseState();
}

class _MatchExerciseState extends State<MatchExercise> {
  String? _selectedLeft;
  String? _selectedRight;
  final Map<String, String> _matches = {};
  final Set<String> _completedSide = {};

  @override
  Widget build(BuildContext context) {
    if (widget.exercise.matchPairs == null) return const Center(child: Text('Invalid match exercise'));

    final leftItems = widget.exercise.matchPairs!.keys.toList();
    final rightItems = widget.exercise.matchPairs!.values.toList()..shuffle();

    return Row(
      children: [
        Expanded(
          child: ListView.separated(
            itemCount: leftItems.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = leftItems[index];
              final isCompleted = _completedSide.contains(item);
              final isSelected = _selectedLeft == item;

              return InkWell(
                onTap: isCompleted ? null : () => setState(() => _selectedLeft = item),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isCompleted ? Colors.grey[200] : (isSelected ? const Color(0xFFDDF4FF) : Colors.white),
                    border: Border.all(color: isSelected ? AppTheme.duoBlue : AppTheme.duoLightGray, width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(item, style: TextStyle(color: isCompleted ? Colors.grey : Colors.black)),
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: ListView.separated(
            itemCount: rightItems.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = rightItems[index];
              final isCompleted = _matches.values.contains(item);
              final isSelected = _selectedRight == item;

              return InkWell(
                onTap: isCompleted ? null : () {
                  if (_selectedLeft != null) {
                    setState(() {
                      _selectedRight = item;
                      _checkMatch();
                    });
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isCompleted ? Colors.grey[200] : (isSelected ? const Color(0xFFDDF4FF) : Colors.white),
                    border: Border.all(color: isSelected ? AppTheme.duoBlue : AppTheme.duoLightGray, width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(item, style: TextStyle(color: isCompleted ? Colors.grey : Colors.black)),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _checkMatch() {
    if (_selectedLeft != null && _selectedRight != null) {
      if (widget.exercise.matchPairs![_selectedLeft] == _selectedRight) {
        _matches[_selectedLeft!] = _selectedRight!;
        _completedSide.add(_selectedLeft!);
        _selectedLeft = null;
        _selectedRight = null;

        if (_matches.length == widget.exercise.matchPairs!.length) {
          widget.onComplete(_matches);
        }
      } else {
        _selectedLeft = null;
        _selectedRight = null;
      }
      setState(() {});
    }
  }
}

class VoiceExerciseWidget extends StatefulWidget {
  final Exercise exercise;
  final Function(String) onTranscribed;

  const VoiceExerciseWidget({super.key, required this.exercise, required this.onTranscribed});

  @override
  State<VoiceExerciseWidget> createState() => _VoiceExerciseWidgetState();
}

class _VoiceExerciseWidgetState extends State<VoiceExerciseWidget> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  bool _isInitialized = false;
  String _text = '';
  String _status = 'Tap to speak';

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  void _initSpeech() async {
    try {
      var status = await Permission.microphone.status;
      if (status.isDenied) {
        status = await Permission.microphone.request();
      }
      
      if (status.isGranted) {
        bool initialized = await _speech.initialize(
          onStatus: (s) => debugPrint('STT Status: $s'),
          onError: (e) => debugPrint('STT Error: $e'),
        );
        setState(() => _isInitialized = initialized);
      }
    } catch (e) {
      debugPrint('Speech initialization failed: $e');
    }
  }

  void _listen() async {
    if (!_isInitialized) {
      _initSpeech();
      return;
    }

    if (!_isListening) {
      setState(() {
        _isListening = true;
        _status = 'Listening...';
        _text = '';
      });
      
      await _speech.listen(
        onResult: (val) {
          setState(() {
            _text = val.recognizedWords;
            if (val.hasConfidenceRating && val.confidence > 0) {
              widget.onTranscribed(_text);
            }
          });
        },
        listenFor: const Duration(seconds: 10),
        pauseFor: const Duration(seconds: 3),
        listenOptions: stt.SpeechListenOptions(partialResults: true),
      );
    } else {
      _stopListening();
    }
  }

  void _stopListening() {
    _speech.stop();
    setState(() {
      _isListening = false;
      _status = _text.isEmpty ? 'Tap to speak' : 'Ready to check';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 40),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _isListening ? AppTheme.duoBlue.withValues(alpha: 0.1) : Colors.transparent,
            border: Border.all(
              color: _isListening ? AppTheme.duoBlue : AppTheme.duoLightGray,
              width: 4,
            ),
          ),
          child: InkWell(
            onTap: _listen,
            borderRadius: BorderRadius.circular(100),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _isListening ? AppTheme.duoBlue.withValues(alpha: 0.1) : Colors.transparent,
                border: Border.all(
                  color: _isListening ? AppTheme.duoBlue : AppTheme.duoLightGray,
                  width: 4,
                ),
                boxShadow: _isListening ? [
                  BoxShadow(
                    color: AppTheme.duoBlue.withValues(alpha: 0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  )
                ] : [],
              ),
              child: Icon(
                _isListening ? Icons.mic : Icons.mic_none,
                size: 64,
                color: _isListening ? AppTheme.duoBlue : AppTheme.duoGray,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          _status,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: _isListening ? AppTheme.duoBlue : AppTheme.duoGray,
          ),
        ),
        const SizedBox(height: 32),
        if (_text.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.duoLightGray),
            ),
            child: Column(
              children: [
                const Text(
                  'Transcribed Text:',
                  style: TextStyle(fontSize: 12, color: AppTheme.duoGray),
                ),
                const SizedBox(height: 8),
                Text(
                  _text,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
