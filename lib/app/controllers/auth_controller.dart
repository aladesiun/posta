import 'package:get/get.dart';
import 'package:posta/app/routes.dart';
import 'package:posta/app/services/auth_service.dart';

class AuthController extends GetxController {
  final AuthService _auth = Get.find<AuthService>();
  final isLoading = false.obs;
  final isAuthenticated = false.obs;

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
      await _auth.login(trimmedEmail, trimmedPassword);
      isAuthenticated.value = true;
      Get.offAllNamed(AppRoutes.feed);
    } catch (e) {
      Get.snackbar('Login failed', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      await _auth.logout();
      isAuthenticated.value = false;
      Get.offAllNamed(AppRoutes.login);
    } catch (e) {
      Get.snackbar('Logout failed', e.toString());
    }
  }

  Future<void> checkAuthStatus() async {
    try {
      final authenticated = await _auth.isAuthenticated();
      isAuthenticated.value = authenticated;

      if (authenticated) {
        Get.offAllNamed(AppRoutes.feed);
      }
    } catch (e) {
      isAuthenticated.value = false;
    }
  }
}
