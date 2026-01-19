import 'package:flutter/material.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

class AIProvider extends ChangeNotifier {
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;

  AIProvider() {
    // Initial welcome message
    _messages.add(ChatMessage(
      text: "Selam! I'm your Amharic tutor. Ask me anything about the language or try writing a sentence!",
      isUser: false,
      timestamp: DateTime.now(),
    ));
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // Add user message
    _messages.add(ChatMessage(
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    ));
    _isLoading = true;
    notifyListeners();

    try {
      // TODO: Call Firebase Cloud Function proxy for OpenAI/Gemini
      // For now, simulate a response
      await Future.delayed(const Duration(seconds: 2));
      
      String aiResponse = _getMockResponse(text);
      
      _messages.add(ChatMessage(
        text: aiResponse,
        isUser: false,
        timestamp: DateTime.now(),
      ));
    } catch (e) {
      _messages.add(ChatMessage(
        text: "Sorry, I'm having trouble connecting right now. Please try again later.",
        isUser: false,
        timestamp: DateTime.now(),
      ));
    }

    _isLoading = false;
    notifyListeners();
  }

  String _getMockResponse(String userText) {
    if (userText.contains('እኔ መሄድ')) {
      return "Correct form: 'እኔ ወደ ቤት እሄዳለሁ'.\n'መሄድ' is infinitive (to go). In Amharic, you need to conjugate the verb based on the subject.";
    }
    if (userText.toLowerCase().contains('hello')) {
      return "Hello! In Amharic, you can say 'Selam' (ሰላም) or 'Tadiyas' (ታዲያስ). How can I help you today?";
    }
    return "That's an interesting sentence! Let me analyze it. You're making good progress. If you want to say something specific in Amharic, just ask!";
  }

  void clearChat() {
    _messages.clear();
    notifyListeners();
  }
}
