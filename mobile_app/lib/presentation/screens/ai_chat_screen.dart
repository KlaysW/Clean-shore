import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../logic/ai_chat/ai_chat_bloc.dart';
import '../../logic/ai_chat/ai_chat_models.dart';

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();

  void _sendMessage([String? presetText]) {
    final text = presetText ?? _textController.text.trim();
    if (text.isEmpty) return;

    context.read<AiChatBloc>().add(AiChatMessageSent(text));
    _textController.clear();

    Future.delayed(const Duration(milliseconds: 200), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Эко-Ассистент'),
            BlocBuilder<AiChatBloc, AiChatState>(
              builder: (context, state) {
                return Text(
                  state.isSending ? 'печатает...' : 'ИИ Консультант онлайн',
                  style: AppTextStyles.caption,
                );
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocConsumer<AiChatBloc, AiChatState>(
              listener: (context, state) {
                if (state.errorMessage != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.errorMessage!)),
                  );
                }
              },
              builder: (context, state) {
                if (state.messages.isEmpty) {
                  return _buildEmptyState(state);
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: state.messages.length,
                  itemBuilder: (context, index) {
                    return _ChatBubble(message: state.messages[index]);
                  },
                );
              },
            ),
          ),
          BlocBuilder<AiChatBloc, AiChatState>(
            builder: (context, state) {
              if (state.messages.isEmpty) return const SizedBox.shrink();
              return _buildPresetChips(state.suggestedPrompts);
            },
          ),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildEmptyState(AiChatState state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.eco, size: 48, color: AppColors.primaryGreenEnd),
            const SizedBox(height: 16),
            Text(
              'Задай вопрос об экологии, ДЗЗ или платформе',
              style: AppTextStyles.bodySecondary,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            _buildPresetChips(state.suggestedPrompts),
          ],
        ),
      ),
    );
  }

  Widget _buildPresetChips(List<String> prompts) {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: prompts.map((prompt) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ActionChip(
              label: Text(prompt),
              onPressed: () => _sendMessage(prompt),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildInputBar() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _textController,
                decoration: const InputDecoration(
                  hintText: 'Спросите Эко-Ассистента...',
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            const SizedBox(width: 8),
            BlocBuilder<AiChatBloc, AiChatState>(
              builder: (context, state) {
                return IconButton(
                  onPressed: state.isSending ? null : () => _sendMessage(),
                  icon: const Icon(Icons.send, color: AppColors.primaryGreenEnd),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({required this.message});

  final ChatMessageModel message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == 'user';

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isUser ? AppColors.primaryGreenEnd : AppColors.chipBackground,
          borderRadius: BorderRadius.circular(18),
        ),
        child: isUser
            ? Text(
                message.content,
                style: AppTextStyles.bodyRegular.copyWith(color: Colors.white),
              )
            : MarkdownBody(
                data: message.content,
                styleSheet: MarkdownStyleSheet(
                  p: AppTextStyles.bodyRegular,
                ),
              ),
      ),
    );
  }
}