import 'package:dio/dio.dart';

class AppException implements Exception {
  final String message;
  final int? statusCode;

  AppException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class NetworkExceptions {
  NetworkExceptions._();

  static AppException fromDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return AppException('Превышено время ожидания ответа сервера');

      case DioExceptionType.connectionError:
        return AppException('Нет подключения к серверу. Проверьте интернет');

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final detail = _extractDetail(error.response?.data);
        return AppException(
          detail ?? 'Ошибка сервера ($statusCode)',
          statusCode: statusCode,
        );

      case DioExceptionType.cancel:
        return AppException('Запрос был отменён');

      default:
        return AppException('Непредвиденная ошибка. Попробуйте снова');
    }
  }

  static String? _extractDetail(dynamic data) {
    if (data is Map<String, dynamic> && data.containsKey('detail')) {
      final detail = data['detail'];
      return detail is String ? detail : detail.toString();
    }
    return null;
  }
}