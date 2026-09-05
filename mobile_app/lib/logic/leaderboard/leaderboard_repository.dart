import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../map/map_models.dart';

class LeaderboardRepository {
  LeaderboardRepository({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<List<LeaderboardEntryModel>> getLeaderboard({String? region}) async {
    final response = await _apiClient.get(
      ApiConstants.leaderboard,
      queryParameters: region != null ? {'region': region} : null,
    );

    final data = response.data as List<dynamic>;
    return data
        .map((json) => LeaderboardEntryModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}