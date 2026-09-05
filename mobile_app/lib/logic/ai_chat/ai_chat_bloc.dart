import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../core/network/network_exceptions.dart';
import 'ai_chat_models.dart';
import 'ai_chat_repository.dart';

part 'ai_chat_event.dart';
part 'ai_chat_state.dart';

const int _maxStoredHistoryMessages = 20;

class AiChatBloc extends Bloc<AiChatEvent, AiChatState> {
  AiChatBloc({required AiChatRepository aiChatRepository})
      : _aiChatRepository = aiChatRepository,
        super(const AiChatState(messages: [])) {
    on<AiChatMessageSent>(_onMessageSent);
    on<AiChatPresetPromptTapped>(_onPresetPromptTapped);
    on<AiChatCleared>(_onCleared);
  }

  final AiChatRepository _aiChatRepository;

  Future<void> _onMessageSent(
    AiChatMessageSent event,
    Emitter<AiChatState> emit,
  ) async {
    final userMessage = ChatMessageModel(role: 'user', content: event.message);
    final historyForRequest = List<ChatMessageModel>.from(state.messages);

    emit(state.copyWith(
      messages: [...state.messages, userMessage],
      isSending: true,
      errorMessage: null,
    ));

    try {
      final response = await _aiChatRepository.sendMessage(
        message: event.message,
        history: historyForRequest.length > _maxStoredHistoryMessages
            ? historyForRequest.sublist(
                historyForRequest.length - _maxStoredHistoryMessages,
              )
            : historyForRequest,
      );

      final assistantMessage = ChatMessageModel(
        role: 'assistant',
        content: response.reply,
      );

      emit(state.copyWith(
        messages: [...state.messages, assistantMessage],
        isSending: false,
        suggestedPrompts: response.suggestedPrompts,
      ));
    } on AppException catch (e) {
      emit(state.copyWith(isSending: false, errorMessage: e.message));
    }
  }

  Future<void> _onPresetPromptTapped(
    AiChatPresetPromptTapped event,
    Emitter<AiChatState> emit,
  ) async {
    add(AiChatMessageSent(event.prompt));
  }

  Future<void> _onCleared(
    AiChatCleared event,
    Emitter<AiChatState> emit,
  ) async {
    emit(const AiChatState(messages: []));
  }
}