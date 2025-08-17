import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:posta/app/controllers/auth_controller.dart';
import 'package:posta/app/routes.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final authController = Get.find<AuthController>();

    // If not initialized yet, stay on current route
    if (!authController.isInitialized.value) {
      return null;
    }

    // If not authenticated and trying to access protected route, redirect to onboarding
    if (!authController.isAuthenticated.value && _isProtectedRoute(route)) {
      return const RouteSettings(name: AppRoutes.onboarding);
    }

    // If authenticated and trying to access auth routes, redirect to feed
    if (authController.isAuthenticated.value && _isAuthRoute(route)) {
      return const RouteSettings(name: AppRoutes.feed);
    }

    return null;
  }

  bool _isProtectedRoute(String? route) {
    if (route == null) return false;

    final protectedRoutes = [
      AppRoutes.feed,
      AppRoutes.createPost,
      AppRoutes.comments,
    ];

    return protectedRoutes.contains(route);
  }

  bool _isAuthRoute(String? route) {
    if (route == null) return false;

    final authRoutes = [
      AppRoutes.login,
      AppRoutes.register,
      AppRoutes.onboarding,
    ];

    return authRoutes.contains(route);
  }
}
