import 'package:dio/dio.dart';
import '../config/app_config.dart';
import 'auth_service.dart';

/// Thin REST client for the portfolio-api backend. Public GETs don't need
/// auth; writes are rejected by the server unless a Supabase access token
/// for the admin account is attached.
class ApiClient {
  ApiClient._()
    : _dio = Dio(
        BaseOptions(
          baseUrl: AppConfig.apiBaseUrl,
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
        ),
      ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = AuthService.instance.accessToken;
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );
  }

  static final instance = ApiClient._();

  final Dio _dio;

  Future<List<Map<String, dynamic>>> list(String path) async {
    final response = await _dio.get<List<dynamic>>(path);
    return (response.data ?? []).cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> getOne(String path) async {
    final response = await _dio.get<Map<String, dynamic>>(path);
    return response.data!;
  }

  Future<Map<String, dynamic>> create(String path, Map<String, dynamic> body) async {
    final response = await _dio.post<Map<String, dynamic>>(path, data: body);
    return response.data!;
  }

  Future<Map<String, dynamic>> update(String path, Map<String, dynamic> body) async {
    final response = await _dio.patch<Map<String, dynamic>>(path, data: body);
    return response.data!;
  }

  Future<void> delete(String path) => _dio.delete(path);
}

/// Surfaces the server's error message instead of a raw DioException string.
String apiErrorMessage(Object error) {
  if (error is DioException) {
    final data = error.response?.data;
    if (data is Map && data['message'] != null) {
      final message = data['message'];
      if (message is List) return message.join(', ');
      return message.toString();
    }
    return error.message ?? 'Network error';
  }
  return error.toString();
}
