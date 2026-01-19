import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter/foundation.dart';

class AIService {
  static final AIService _instance = AIService._internal();
  factory AIService() => _instance;
  AIService._internal();

  GenerativeModel? _model;
  
  // Note: In a real app, use a secure way to store this.
  // For this project, we'll allow setting it from outside or using an env var.
  void init(String apiKey) {
    if (apiKey.isEmpty || apiKey == 'YOUR_API_KEY_HERE') {
      debugPrint('AI Service: No valid API Key provided. AI features will be disabled.');
      return;
    }
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
    );
  }

  bool get isInitialized => _model != null;

  /// Evaluates a user's transcription against a target answer.
  /// Returns true if the meaning matches, even if the transcription is slightly different.
  Future<bool> evaluateAnswer({
    required String target,
    required String transcription,
    required String language,
  }) async {
    if (_model == null) {
      // Fallback to simple matching if AI not initialized
      return transcription.trim().toLowerCase() == target.trim().toLowerCase();
    }

    final prompt = '''
Role: Language tutor.
Task: Evaluate if the spoken transcription effectively matches the target answer in $language.
Target: "$target"
User Spoke: "$transcription"

Rules:
1. Allow for minor transcription errors (e.g., "hellow" instead of "hello").
2. Allow for synonyms if they convey the exact same meaning in this context.
3. Be lenient but ensure the core meaning is correct.
4. Respond ONLY with "YES" if it's correct/acceptable, or "NO" if it's incorrect.
''';

    try {
      final content = [Content.text(prompt)];
      final response = await _model!.generateContent(content);
      return response.text?.trim().toUpperCase() == 'YES';
    } catch (e) {
      debugPrint('AI Evaluation failed: $e');
      return transcription.trim().toLowerCase() == target.trim().toLowerCase();
    }
  }

  /// Generates a response from an AI character for a scenario.
  Future<String> getAIResponse({
    required String scenario,
    required String userInput,
    required String language,
  }) async {
    if (_model == null) return "AI not initialized.";

    final prompt = '''
Role: A character in a language learning scenario.
Scenario: "$scenario"
User said: "$userInput"
Language: $language

Task: Respond naturally (1-2 short sentences) to the user in $language. Then, add a English translation in parentheses.
Example: "Selam! Endemen neh? (Hello! How are you?)"
''';

    try {
      final content = [Content.text(prompt)];
      final response = await _model!.generateContent(content);
      return response.text?.trim() ?? "No response.";
    } catch (e) {
      debugPrint('AI Response failed: $e');
      return "Error generating response.";
    }
  }
}
