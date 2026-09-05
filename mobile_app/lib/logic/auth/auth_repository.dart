import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import 'auth_models.dart';

class AuthRepository {
  AuthRepository({ApiClient? apiClient, FlutterSecureStorage? secureStorage})
      : _apiClient = apiClient ?? ApiClient(),
        _secureStorage = secureStorage ?? const FlutterSecureStorage();

  final ApiClient _apiClient;
  final FlutterSecureStorage _secureStorage;

  Future<UserModel> register({
    required String email,
    required String password,
    required String nickname,
    bool isOoptStaff = false,
  }) async {
    final response = await _apiClient.post(
      ApiConstants.register,
      data: {
        'email': email,
        'password': password,
        'nickname': nickname,
        'is_oopt_staff': isOoptStaff,
      },
    );

    final token = TokenModel.fromJson(response.data as Map<String, dynamic>);
    await _persistToken(token.accessToken);
    return getCurrentUser();
  }

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.post(
      ApiConstants.login,
      data: {
        'username': email,
        'password': password,
      },
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );

    final token = TokenModel.fromJson(response.data as Map<String, dynamic>);
    await _persistToken(token.accessToken);
    return getCurrentUser();
  }

  Future<UserModel> getCurrentUser() async {
    final response = await _apiClient.get(ApiConstants.me);
    return UserModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> logout() async {
    await _secureStorage.delete(key: ApiConstants.secureStorageTokenKey);
  }

  Future<bool> hasValidSession() async {
    final token = await _secureStorage.read(
      key: ApiConstants.secureStorageTokenKey,
    );
    return token != null && token.isNotEmpty;
  }

  Future<void> _persistToken(String token) async {
    await _secureStorage.write(
      key: ApiConstants.secureStorageTokenKey,
      value: token,
    );
  }
}