import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import 'map_models.dart';

class MapRepository {
  MapRepository({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<List<SpotModel>> getSpots({String? statusFilter}) async {
    final response = await _apiClient.get(
      ApiConstants.mapSpots,
      queryParameters: statusFilter != null ? {'status': statusFilter} : null,
    );

    final data = response.data as List<dynamic>;
    return data
        .map((json) => SpotModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<List<HeatmapPointModel>> getHeatmap() async {
    final response = await _apiClient.get(ApiConstants.mapHeatmap);

    final data = response.data as List<dynamic>;
    return data
        .map((json) => HeatmapPointModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}