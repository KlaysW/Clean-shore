import 'dart:io';

import 'package:dio/dio.dart';

import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../camera/camera_models.dart';

class CameraRepository {
  CameraRepository({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<String> uploadPhoto(File photoFile) async {
    final fileName = photoFile.path.split('/').last;

    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(photoFile.path, filename: fileName),
    });

    final response = await _apiClient.post(
      ApiConstants.questUploadPhoto,
      data: formData,
      options: Options(
        contentType: 'multipart/form-data',
        sendTimeout: ApiConstants.uploadTimeout,
        receiveTimeout: ApiConstants.uploadTimeout,
      ),
    );

    final data = response.data as Map<String, dynamic>;
    return data['url'] as String;
  }

  Future<SpotSearchResultModel> submitSearch({
    required double lat,
    required double lon,
    required String photoUrl,
  }) async {
    final response = await _apiClient.post(
      ApiConstants.questSearch,
      data: {
        'lat': lat,
        'lon': lon,
        'photo_url': photoUrl,
      },
    );

    return SpotSearchResultModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<SpotCleanupResultModel> submitCleanup({
    required String spotId,
    required String photoAfterUrl,
  }) async {
    final response = await _apiClient.post(
      ApiConstants.questCleanup,
      data: {
        'spot_id': spotId,
        'photo_after_url': photoAfterUrl,
      },
    );

    return SpotCleanupResultModel.fromJson(response.data as Map<String, dynamic>);
  }
}