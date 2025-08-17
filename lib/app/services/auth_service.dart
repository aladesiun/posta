import 'package:get/get.dart';
import 'package:posta/app/services/api_client.dart';
import 'package:posta/app/services/token_storage.dart';

class AuthService {
  final ApiClient _api = Get.find<ApiClient>();
  final TokenStorage _storage = Get.find<TokenStorage>();

  /// Validate the current token by making a test API call
  Future<void> validateToken() async {
    try {
      // Make a simple API call to validate the token
      // Using the posts endpoint as it requires authentication
      await _api.dio.get('/posts', queryParameters: {'limit': 1, 'offset': 0});
    } catch (e) {
      print('Token validation failed: $e');
      throw Exception('Token validation failed: $e');
    }
  }

  Future<void> login(String email, String password) async {
    try {
      final response = await _api.dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      final access = response.data['accessToken'] as String;
      final refresh = response.data['refreshToken'] as String;
      await _storage.saveTokens(accessToken: access, refreshToken: refresh);
    } catch (e) {
      print('Login failed: ${e.toString()}');
      throw Exception('Login failed: ${e.toString()}');
    }
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

  Future<void> clearStoredData() async {
    await _storage.clear();
  }
}

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(AuthService());
  }
}
