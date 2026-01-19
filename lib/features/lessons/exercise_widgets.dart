import 'package:flutter/material.dart';
import 'models/lesson.dart';
import '../../core/theme/app_theme.dart';

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
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFDDF4FF) : Colors.white,
          border: Border.all(
            color: isSelected ? AppTheme.duoBlue : AppTheme.duoLightGray,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            if (!isSelected)
              const BoxShadow(
                color: AppTheme.duoLightGray,
                offset: Offset(0, 4),
              ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                border: Border.all(
                  color: isSelected ? AppTheme.duoBlue : AppTheme.duoLightGray,
                  width: 2,
                ),
                shape: BoxShape.circle,
              ),
              child: isSelected
                  ? const Center(
                      child: CircleAvatar(
                        radius: 8,
                        backgroundColor: AppTheme.duoBlue,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? AppTheme.duoDarkBlue : const Color(0xFF4B4B4B),
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
