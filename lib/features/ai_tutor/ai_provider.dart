import 'package:flutter/material.dart';
import '../../core/services/ai_service.dart';

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
      text: "Selam! I'm your AI language tutor. Ask me anything about Amharic, Afaan Oromo, or Tigregna!",
      isUser: false,
      timestamp: DateTime.now(),
    ));
  }

  Future<void> sendMessage(String text, String language, String level) async {
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
      String aiResponse = await AIService().getAIResponse(
        scenario: "You are an AI language tutor. The user is at the $level level in $language.",
        userInput: text,
        language: language,
      );
      
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


  void clearChat() {
    _messages.clear();
    notifyListeners();
  }
}
