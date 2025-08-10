import 'package:get/get.dart';
import 'package:posta/app/services/api_client.dart';
import 'package:posta/app/services/token_storage.dart';

class AuthService {
  final ApiClient _api = Get.find<ApiClient>();
  final TokenStorage _storage = Get.find<TokenStorage>();

  Future<void> login(String email, String password) async {
    final resp = await _api.dio.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    print('login resp:');
    print(resp.data);
    final access = resp.data['accessToken'] as String;
    final refresh = resp.data['refreshToken'] as String;
    await _storage.saveTokens(accessToken: access, refreshToken: refresh);
  }

  Future<void> register(String username, String email, String password) async {
    final resp = await _api.dio.post('/auth/register', data: {
      'username': username,
      'email': email,
      'password': password,
    });
    final access = resp.data['accessToken'] as String;
    final refresh = resp.data['refreshToken'] as String;
    await _storage.saveTokens(accessToken: access, refreshToken: refresh);
  }

  Future<void> logout() async {
    try {
      await _api.dio.post('/auth/logout');
    } catch (e) {
      // Continue with logout even if API call fails
    } finally {
      await _storage.clear();
    }
  }

  Future<bool> isAuthenticated() async {
    try {
      final accessToken = await _storage.readAccessToken();
      if (accessToken == null) return false;

      // Validate token with backend
      await _api.dio.get('/auth/me');
      return true;
    } catch (e) {
      // Token is invalid or expired
      await _storage.clear();
      return false;
    }
  }

  Future<void> refreshTokens() async {
    try {
      final refreshToken = await _storage.readRefreshToken();
      if (refreshToken == null) throw Exception('No refresh token');

      final resp = await _api.dio.post('/auth/refresh', data: {
        'refreshToken': refreshToken,
      });

      final access = resp.data['accessToken'] as String;
      final refresh = resp.data['refreshToken'] as String;
      await _storage.saveTokens(accessToken: access, refreshToken: refresh);
    } catch (e) {
      await _storage.clear();
      throw Exception('Failed to refresh tokens');
    }
  }
}

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(AuthService());
  }
}
