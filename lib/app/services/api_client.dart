import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:posta/app/config.dart';
import 'package:posta/app/services/token_storage.dart';

class ApiClient {
  final Dio _dio;
  final TokenStorage _tokenStorage;
  bool _isRefreshing = false;

  ApiClient(this._dio, this._tokenStorage) {
    _dio.options.baseUrl = AppConfig.baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 20);

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _tokenStorage.readAccessToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401 && !_isRefreshing) {
          _isRefreshing = true;

          try {
            // Try to refresh the token
            final refreshToken = await _tokenStorage.readRefreshToken();
            if (refreshToken != null) {
              await _refreshToken(refreshToken);

              // Retry the original request with new token
              final newToken = await _tokenStorage.readAccessToken();
              if (newToken != null) {
                error.requestOptions.headers['Authorization'] =
                    'Bearer $newToken';
                final response = await _dio.fetch(error.requestOptions);
                handler.resolve(response);
                return;
              }
            }
          } catch (e) {
            print('Token refresh failed: $e');
            // Clear tokens and redirect to login
            await _tokenStorage.clear();
            Get.offAllNamed('/onboarding');
          } finally {
            _isRefreshing = false;
          }
        }

        handler.next(error);
      },
    ));
  }

  Future<void> _refreshToken(String refreshToken) async {
    try {
      final response = await _dio.post('/auth/refresh', data: {
        'refreshToken': refreshToken,
      });

      final access = response.data['accessToken'] as String;
      final refresh = response.data['refreshToken'] as String;
      await _tokenStorage.saveTokens(
          accessToken: access, refreshToken: refresh);
    } catch (e) {
      print('Failed to refresh token: $e');
      throw Exception('Token refresh failed');
    }
  }

  Dio get dio => _dio;
}

// Simple GetX binding/provider
class ApiBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(TokenStorage());
    Get.put(ApiClient(Dio(), Get.find<TokenStorage>()));
  }
}
