part of 'ai_chat_bloc.dart';

abstract class AiChatEvent extends Equatable {
  const AiChatEvent();

  @override
  List<Object?> get props => [];
}

class AiChatMessageSent extends AiChatEvent {
  const AiChatMessageSent(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class AiChatPresetPromptTapped extends AiChatEvent {
  const AiChatPresetPromptTapped(this.prompt);

  final String prompt;

  @override
  List<Object?> get props => [prompt];
}

class AiChatCleared extends AiChatEvent {
  const AiChatCleared();
}