import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:posta/app/screens/auth/login_screen.dart';
import 'package:posta/app/screens/feed/feed_screen.dart';
import 'package:posta/app/screens/post/create_post_screen.dart';

class AppRoutes {
  static const String login = '/login';
  static const String feed = '/feed';
  static const String createPost = '/create-post';

  static final pages = <GetPage<dynamic>>[
    GetPage(name: login, page: () => const LoginScreen()),
    GetPage(name: feed, page: () => const FeedScreen()),
    GetPage(name: createPost, page: () => const CreatePostScreen()),
  ];
}
