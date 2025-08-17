import 'package:get/get.dart' hide FormData, MultipartFile;
import 'package:image_picker/image_picker.dart';
import 'package:posta/app/services/api_client.dart';
import 'package:posta/app/controllers/post_controller.dart';
import 'package:dio/dio.dart';
import 'dart:io';

class PostService {
  final ApiClient _apiClient = Get.find<ApiClient>();

  Future<void> createPost({
    required String text,
    XFile? imageFile,
  }) async {
    try {
      // Create FormData for multipart upload using Dio
      final formData = FormData.fromMap({
        'text': text,
      });

      if (imageFile != null) {
        final file = File(imageFile.path);
        formData.files.add(MapEntry(
          'image',
          await MultipartFile.fromFile(
            file.path,
            filename: 'posta_${DateTime.now().millisecondsSinceEpoch}.jpg',
          ),
        ));
      }

      // Send post data to backend (backend handles Cloudinary upload)
      final response = await _apiClient.dio.post(
        '/posts',
        data: formData,
      );

      if (response.statusCode != 201 && response.statusCode != 200) {
        throw Exception('Failed to create post: ${response.statusMessage}');
      }

      print('Post created successfully: ${response.data}');
    } catch (e) {
      print('Error creating post: $e');
      throw Exception('Failed to create post: $e');
    }
  }
}

class PostBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PostService>(() => PostService());
    Get.lazyPut<PostController>(() => PostController());
  }
}
