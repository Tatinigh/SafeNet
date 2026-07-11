import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/providers.dart';
import '../models/chat_message.dart';

/// State representation of the interactive chatbot session.
class ChatState {
  final List<ChatMessage> messages;
  final bool isTyping;
  final List<String> suggestions;

  ChatState({
    required this.messages,
    this.isTyping = false,
    required this.suggestions,
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isTyping,
    List<String>? suggestions,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isTyping: isTyping ?? this.isTyping,
      suggestions: suggestions ?? this.suggestions,
    );
  }
}

/// ChatNotifier managing local memory updates and simulated text stream.
class ChatNotifier extends StateNotifier<ChatState> {
  final Ref _ref;

  ChatNotifier(this._ref)
      : super(ChatState(
          messages: [],
          suggestions: [
            'Is this website safe?',
            'Explain phishing.',
            'What is a UPI scam?',
            'How to report SMS fraud?',
          ],
        )) {
    _loadLocalChatHistory();
  }

  void _loadLocalChatHistory() {
    final hiveService = _ref.read(hiveServiceProvider);
    final history = hiveService.getChatHistory();
    if (history.isNotEmpty) {
      state = state.copyWith(messages: history);
    } else {
      // Seed with initial greeting
      final greeting = ChatMessage(
        id: 'greet_1',
        role: 'assistant',
        text: 'Hello! I am SafeNet AI, your digital safety assistant. You can paste any link, SMS copy, or ask me security questions to evaluate scan risks. How can I help you today?',
        timestamp: DateTime.now(),
      );
      state = state.copyWith(messages: [greeting]);
    }
  }

  /// Sends a message and triggers the simulated word-by-word typing streaming response.
  Future<void> sendMessage(String text) async {
    final userMessage = ChatMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      role: 'user',
      text: text,
      timestamp: DateTime.now(),
    );

    // Save user message to UI state & Hive
    state = state.copyWith(
      messages: [...state.messages, userMessage],
      isTyping: true,
    );
    await _ref.read(hiveServiceProvider).saveChatMessage(userMessage);

    // Fetch API/Mock response
    final chatHistoryList = state.messages.map((m) => {'role': m.role, 'text': m.text}).toList();
    final apiClient = _ref.read(apiClientProvider);
    final fullReply = await apiClient.sendChatMessage(text, chatHistoryList);

    // Setup streaming simulation: add empty assistant message, then append words
    final assistantMessageId = 'msg_${DateTime.now().millisecondsSinceEpoch + 1}';
    final initialAssistantMessage = ChatMessage(
      id: assistantMessageId,
      role: 'assistant',
      text: '',
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, initialAssistantMessage],
      isTyping: false,
    );

    final words = fullReply.split(' ');
    String currentText = '';
    
    // Timer to append words with delay
    int wordIndex = 0;
    Timer.periodic(const Duration(milliseconds: 60), (timer) async {
      if (wordIndex < words.length) {
        currentText += '${words[wordIndex]} ';
        wordIndex++;

        // Update list in place
        final updatedList = List<ChatMessage>.from(state.messages);
        final targetIndex = updatedList.indexWhere((m) => m.id == assistantMessageId);
        if (targetIndex != -1) {
          updatedList[targetIndex] = ChatMessage(
            id: assistantMessageId,
            role: 'assistant',
            text: currentText.trim(),
            timestamp: initialAssistantMessage.timestamp,
          );
          state = state.copyWith(messages: updatedList);
        }
      } else {
        timer.cancel();
        // Save final streamed reply to local Hive
        final finalMessage = ChatMessage(
          id: assistantMessageId,
          role: 'assistant',
          text: fullReply,
          timestamp: DateTime.now(),
        );
        await _ref.read(hiveServiceProvider).saveChatMessage(finalMessage);
      }
    });
  }

  /// Clears chat history locally and in database
  Future<void> clearHistory() async {
    await _ref.read(hiveServiceProvider).clearChatHistory();
    state = state.copyWith(messages: []);
    _loadLocalChatHistory();
  }
}

/// Provider for AI chat interaction.
final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  return ChatNotifier(ref);
});
