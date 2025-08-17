import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:posta/app/theme.dart';
import 'package:posta/app/routes.dart';
import 'package:posta/app/services/api_client.dart';
import 'package:posta/app/services/auth_service.dart';
import 'package:posta/app/services/feed_service.dart';
import 'package:posta/app/services/post_service.dart';
import 'package:posta/app/services/like_service.dart';
import 'package:posta/app/services/profile_service.dart';
import 'package:posta/app/controllers/auth_controller.dart';
import 'package:posta/app/controllers/post_controller.dart';
import 'package:posta/app/services/image_upload_service.dart';

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
        try {
          // Initialize core services first
          ApiBinding().dependencies();
          AuthBinding().dependencies();
          FeedBinding().dependencies();
          PostBinding().dependencies();
          LikeBinding().dependencies();
          ImageUploadBinding()
              .dependencies(); // Move this before ProfileBinding
          ProfileBinding().dependencies();

          // Initialize controllers
          Get.put(AuthController());
          Get.put(PostController());
        } catch (e) {
          print('Error during app initialization: $e');
        }
      }),
      onInit: () {
        // Authentication check moved to initialBinding
      },
      initialRoute: AppRoutes.splash,
      getPages: AppRoutes.pages,
    );
  }
}
// Home is handled via GetX routes
