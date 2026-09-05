import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import 'ai_chat_models.dart';

class AiChatRepository {
  AiChatRepository({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<ChatResponseModel> sendMessage({
    required String message,
    required List<ChatMessageModel> history,
  }) async {
    final response = await _apiClient.post(
      ApiConstants.aiChatMessage,
      data: {
        'message': message,
        'history': history.map((m) => m.toJson()).toList(),
      },
    );

    return ChatResponseModel.fromJson(response.data as Map<String, dynamic>);
  }
}