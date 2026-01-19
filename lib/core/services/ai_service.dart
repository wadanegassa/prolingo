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
      model: 'gemini-2.0-flash-lite-preview-02-05',
      apiKey: apiKey,
      systemInstruction: Content.system(
        'You are the expert ProLingo AI Tutor, a sophisticated language learning companion. '
        'Your personality is a mix of a supportive mentor and a highly intelligent linguistic researcher. '
        'You have deep expertise in Amharic, Afaan Oromo, and Tigregna. '
        'Be proactive, encouraging, and clear. Use varied conversational expressions. '
        'When evaluating, act as a human expert who understands intent, non-native accents, and phonetic slips.'
      ),
      safetySettings: [
        SafetySetting(HarmCategory.harassment, HarmBlockThreshold.none),
        SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.none),
        SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.none),
        SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.none),
      ],
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
Focus: Semantic Understanding & Encouragement.
Task: Decide if the user's spoken transcription effectively conveys the same intent as the target answer in $language.

Target Answer: "$target"
User's Spoken Transcription: "$transcription"

Evaluation Guidelines:
1. **Accents & Phonetics**: Be extremely lenient with non-native accents and phonetic transcription slips (e.g., "selam" vs "selem").
2. **Conversationally Equivalent**: If the user's response means essentially the same thing in a real-world conversation, it is CORRECT.
3. **Intent over Literalism**: Prioritize whether the user *understood* and *attempted* the right concept.
4. **Minor Contextual Variations**: Ignore missing/extra small words (like "the", "a", "is") if the core meaning remains intact.

Respond ONLY with "YES" if it's a pass/acceptable, or "NO" if it's fundamentally incorrect or a different meaning.
''';

    try {
      final content = [Content.text(prompt)];
      final response = await _model!.generateContent(content);
      final text = response.text?.trim() ?? '';
      return text.toUpperCase().contains('YES');
    } catch (e) {
      debugPrint('AI Evaluation failed: $e');
      // If the error is a safety block, it might return empty text
      return transcription.trim().toLowerCase() == target.trim().toLowerCase();
    }
  }

  /// Generates a response from an AI character for a scenario.
  Future<String> getAIResponse({
    required String scenario,
    required String userInput,
    required String language,
  }) async {
    if (_model == null) {
      // Smart Fallback for development
      final String greeting = language == 'amharic' ? 'Selam!' : (language == 'afaan oromo' ? 'Akkam!' : 'Selam!');
      return "$greeting I'm currently in Development Mode. (Please set your GEMINI_API_KEY in main.dart to unlock my full AI intelligence!)";
    }

    final prompt = '''
Role: You are a friendly, conversational character in a language learning scenario.
Scenario Context: "$scenario"
User just said to you: "$userInput"
Learning Language: $language

Task: Respond to the user in a natural, warm, and helpful way. 
- Use 1-2 short, conversational sentences in $language.
- Avoid sounding like a robot; use common greetings or supportive expressions.
- After the response, provide a English translation in parentheses.

Style: Friendly peer, encouraging, and clear.
Example: "Akkam! Maal siif fidu? (Hi! What can I bring you?)"
''';

    try {
      final content = [Content.text(prompt)];
      final response = await _model!.generateContent(content);
      final text = response.text?.trim();
      if (text == null || text.isEmpty) {
        debugPrint('AI Response: Received empty text. Check safety settings or prompt.');
        return "I'm sorry, I couldn't generate a response. (Safety block or empty result)";
      }
      return text;
    } catch (e) {
      debugPrint('AI Response failed in AIService: $e');
      return "Error generating response: ${e.toString().split('\n').first}";
    }
  }
}
