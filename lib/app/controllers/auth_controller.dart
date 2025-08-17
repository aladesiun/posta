import 'package:get/get.dart';
import 'package:posta/app/routes.dart';
import 'package:posta/app/services/auth_service.dart';
import 'package:posta/app/services/token_storage.dart';

class AuthController extends GetxController {
  final AuthService _auth = Get.find<AuthService>();
  final TokenStorage _tokenStorage = Get.find<TokenStorage>();
  final isLoading = false.obs;
  final isAuthenticated = false.obs;
  final isInitialized = false.obs;

  @override
  void onInit() {
    super.onInit();
    _checkAuthState();
  }

  /// Check if user is already authenticated on app startup
  Future<void> _checkAuthState() async {
    try {
      final token = await _tokenStorage.readAccessToken();
      if (token != null && token.isNotEmpty) {
        // Token exists, validate it by making a test API call
        await _validateToken(token);
      } else {
        isAuthenticated.value = false;
      }
    } catch (e) {
      print('Error checking auth state: $e');
      // If token validation fails, clear stored tokens
      await _tokenStorage.clear();
      isAuthenticated.value = false;
    } finally {
      isInitialized.value = true;
    }
  }

  /// Validate stored token by making a test API call
  Future<void> _validateToken(String token) async {
    try {
      // Make a simple API call to validate the token
      // You can use any endpoint that requires authentication
      await _auth.validateToken();
      isAuthenticated.value = true;
      print('Token validation successful');
    } catch (e) {
      print('Token validation failed: $e');
      // Token is invalid, clear it
      await _tokenStorage.clear();
      isAuthenticated.value = false;
    }
  }

  /// Get the initial route based on authentication state
  String get initialRoute {
    if (!isInitialized.value) {
      return AppRoutes.splash;
    }
    return isAuthenticated.value ? AppRoutes.feed : AppRoutes.onboarding;
  }

  Future<void> login(String email, String password) async {
    if (isLoading.value) return;
    final trimmedEmail = email.trim();
    final trimmedPassword = password.trim();
    if (trimmedEmail.isEmpty || trimmedPassword.isEmpty) {
      Get.snackbar('Validation', 'Email and password are required');
      return;
    }
    isLoading.value = true;
    try {
      print('Login attempt: $trimmedEmail, $trimmedPassword');
      await _auth.login(trimmedEmail, trimmedPassword);
      isAuthenticated.value = true;
      Get.offAllNamed(AppRoutes.feed);
    } catch (e, stackTrace) {
      print('Login failed: $e');
      print('Stack trace: $stackTrace');
      Get.snackbar('Login failed', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> register(String username, String email, String password) async {
    if (isLoading.value) return;
    final trimmedUsername = username.trim();
    final trimmedEmail = email.trim();
    final trimmedPassword = password.trim();

    if (trimmedUsername.isEmpty ||
        trimmedEmail.isEmpty ||
        trimmedPassword.isEmpty) {
      Get.snackbar('Validation', 'All fields are required');
      return;
    }

    if (trimmedUsername.length < 3) {
      Get.snackbar('Validation', 'Username must be at least 3 characters');
      return;
    }

    if (trimmedPassword.length < 6) {
      Get.snackbar('Validation', 'Password must be at least 6 characters');
      return;
    }

    isLoading.value = true;
    try {
      print('Registration attempt: $trimmedUsername, $trimmedEmail');
      await _auth.register(trimmedUsername, trimmedEmail, trimmedPassword);
      isAuthenticated.value = true;
      Get.offAllNamed(AppRoutes.feed);
    } catch (e) {
      print('Registration failed: $e');
      Get.snackbar('Registration failed', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      await _auth.logout();
      isAuthenticated.value = false;
      Get.offAllNamed(AppRoutes.onboarding);
    } catch (e) {
      Get.snackbar('Logout failed', e.toString());
    }
  }

  Future<void> clearStoredData() async {
    try {
      await _auth.clearStoredData();
      isAuthenticated.value = false;
      Get.snackbar('Success', 'Stored data cleared');
    } catch (e) {
      Get.snackbar('Error', 'Failed to clear stored data: ${e.toString()}');
    }
  }
}
