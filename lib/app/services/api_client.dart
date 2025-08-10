import 'dart:async';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:posta/app/config.dart';
import 'package:posta/app/services/token_storage.dart';

class ApiClient {
  final Dio _dio;
  final TokenStorage _tokenStorage;
  bool _isRefreshing = false;
  final List<Completer<void>> _refreshWaiters = [];

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
      onError: (e, handler) async {
        if (e.response?.statusCode == 401) {
          try {
            await _handleTokenRefresh();
            final newToken = await _tokenStorage.readAccessToken();
            if (newToken != null) {
              final req = e.requestOptions;
              req.headers['Authorization'] = 'Bearer $newToken';
              final cloned = await _dio.fetch(req);
              return handler.resolve(cloned);
            }
          } catch (_) {}
        }
        handler.next(e);
      },
    ));
  }

  Future<void> _handleTokenRefresh() async {
    if (_isRefreshing) {
      final waiter = Completer<void>();
      _refreshWaiters.add(waiter);
      return waiter.future;
    }
    _isRefreshing = true;
    try {
      final refresh = await _tokenStorage.readRefreshToken();
      if (refresh == null) throw Exception('No refresh token');
      final resp =
          await _dio.post('/auth/refresh', data: {'refreshToken': refresh});
      final accessToken = resp.data['accessToken'] as String?;
      final refreshToken = resp.data['refreshToken'] as String? ?? refresh;
      if (accessToken == null) throw Exception('No access token in refresh');
      await _tokenStorage.saveTokens(
          accessToken: accessToken, refreshToken: refreshToken);
    } finally {
      _isRefreshing = false;
      for (final c in _refreshWaiters) {
        c.complete();
      }
      _refreshWaiters.clear();
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
