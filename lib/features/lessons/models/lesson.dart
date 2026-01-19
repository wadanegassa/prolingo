enum ExerciseType { multipleChoice, match, fillInTheBlank, translate }

class Unit {
  final String id;
  final String title;
  final String description;
  final int order;
  final List<Lesson> lessons;

  Unit({
    required this.id,
    required this.title,
    required this.description,
    required this.order,
    this.lessons = const [],
  });

  factory Unit.fromFirestore(String id, Map<String, dynamic> data) {
    return Unit(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      order: data['order'] ?? 0,
    );
  }
}

class Lesson {
  final String id;
  final String title;
  final int order;
  final bool isLocked;
  final List<Exercise> exercises;

  Lesson({
    required this.id,
    required this.title,
    required this.order,
    this.isLocked = true,
    this.exercises = const [],
  });

  factory Lesson.fromFirestore(String id, Map<String, dynamic> data) {
    return Lesson(
      id: id,
      title: data['title'] ?? '',
      order: data['order'] ?? 0,
      isLocked: data['isLocked'] ?? true,
    );
  }
}

class Exercise {
  final String id;
  final ExerciseType type;
  final String question;
  final String? amharicText;
  final String? englishText;
  final List<String> options;
  final String? correctAnswer;
  final Map<String, String>? matchPairs; // For matching exercises
  final String? instruction;

  Exercise({
    required this.id,
    required this.type,
    required this.question,
    this.amharicText,
    this.englishText,
    this.options = const [],
    this.correctAnswer,
    this.matchPairs,
    this.instruction,
  });

  factory Exercise.fromFirestore(String id, Map<String, dynamic> data) {
    ExerciseType type;
    switch (data['type']) {
      case 'multipleChoice':
        type = ExerciseType.multipleChoice;
        break;
      case 'match':
        type = ExerciseType.match;
        break;
      case 'fillInTheBlank':
        type = ExerciseType.fillInTheBlank;
        break;
      case 'translate':
        type = ExerciseType.translate;
        break;
      default:
        type = ExerciseType.multipleChoice;
    }

    return Exercise(
      id: id,
      type: type,
      question: data['question'] ?? '',
      amharicText: data['amharicText'],
      englishText: data['englishText'],
      options: List<String>.from(data['options'] ?? []),
      correctAnswer: data['correctAnswer'],
      matchPairs: data['matchPairs'] != null ? Map<String, String>.from(data['matchPairs']) : null,
      instruction: data['instruction'],
    );
  }
}
