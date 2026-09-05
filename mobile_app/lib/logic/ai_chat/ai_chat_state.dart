part of 'ai_chat_bloc.dart';

class AiChatState extends Equatable {
  const AiChatState({
    required this.messages,
    this.isSending = false,
    this.errorMessage,
    this.suggestedPrompts = const [
      'Как сортировать пластик?',
      'Что такое ДЗЗ?',
      'Как передать данные в ООПТ?',
    ],
  });

  final List<ChatMessageModel> messages;
  final bool isSending;
  final String? errorMessage;
  final List<String> suggestedPrompts;

  AiChatState copyWith({
    List<ChatMessageModel>? messages,
    bool? isSending,
    String? errorMessage,
    List<String>? suggestedPrompts,
  }) {
    return AiChatState(
      messages: messages ?? this.messages,
      isSending: isSending ?? this.isSending,
      errorMessage: errorMessage,
      suggestedPrompts: suggestedPrompts ?? this.suggestedPrompts,
    );
  }

  @override
  List<Object?> get props => [messages, isSending, errorMessage, suggestedPrompts];
}