class ChatMessageModel {
  final String role;
  final String content;

  ChatMessageModel({required this.role, required this.content});

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      role: json['role'] as String,
      content: json['content'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'role': role,
        'content': content,
      };
}

class ChatResponseModel {
  final String reply;
  final List<String> suggestedPrompts;

  ChatResponseModel({required this.reply, required this.suggestedPrompts});

  factory ChatResponseModel.fromJson(Map<String, dynamic> json) {
    return ChatResponseModel(
      reply: json['reply'] as String? ?? '',
      suggestedPrompts: (json['suggested_prompts'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );
  }
}