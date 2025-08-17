import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:posta/app/screens/auth/login_screen.dart';
import 'package:posta/app/screens/auth/register_screen.dart';
import 'package:posta/app/screens/feed/feed_screen.dart';
import 'package:posta/app/screens/post/create_post_screen.dart';
import 'package:posta/app/screens/post/comments_screen.dart';
import 'package:posta/app/screens/profile/profile_screen.dart';
import 'package:posta/app/widgets/splash_screen.dart';
import 'package:posta/app/screens/onboarding/onboarding_screen.dart';
import 'package:posta/app/services/comment_service.dart';
import 'package:posta/app/services/profile_service.dart';
import 'package:posta/app/middleware/auth_middleware.dart';

class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String feed = '/feed';
  static const String createPost = '/create-post';
  static const String comments = '/comments';
  static const String profile = '/profile';

  static final pages = <GetPage<dynamic>>[
    GetPage(name: splash, page: () => const SplashScreen()),
    GetPage(name: onboarding, page: () => const OnboardingScreen()),
    GetPage(name: login, page: () => const LoginScreen()),
    GetPage(name: register, page: () => const RegisterScreen()),
    GetPage(
      name: feed,
      page: () => const FeedScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: createPost,
      page: () => const CreatePostScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: comments,
      page: () => const CommentsScreen(),
      binding: CommentBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: profile,
      page: () => const ProfileScreen(),
      binding: ProfileBinding(),
      middlewares: [AuthMiddleware()],
    ),
  ];
}
