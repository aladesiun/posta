import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:posta/app/theme.dart';
import 'package:posta/app/routes.dart';
import 'package:posta/app/services/api_client.dart';
import 'package:posta/app/services/auth_service.dart';
import 'package:posta/app/services/feed_service.dart';
import 'package:posta/app/services/post_service.dart';
import 'package:posta/app/controllers/auth_controller.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Posta',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      initialBinding: BindingsBuilder(() {
        // Initialize core services
        ApiBinding().dependencies();
        AuthBinding().dependencies();
        FeedBinding().dependencies();
        PostBinding().dependencies();
      }),
      onInit: () {
        // Check authentication status on app startup
        final authController = Get.find<AuthController>();
        authController.checkAuthStatus();
      },
      initialRoute: AppRoutes.login,
      getPages: AppRoutes.pages,
    );
  }
}
// Home is handled via GetX routes
