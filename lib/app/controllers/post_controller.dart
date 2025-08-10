import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:posta/app/services/post_service.dart';
import 'package:posta/app/controllers/feed_controller.dart';

class PostController extends GetxController {
  final PostService _postService = Get.find<PostService>();
  final isLoading = false.obs;

  Future<void> createPost({
    required String text,
    XFile? imageFile,
  }) async {
    if (isLoading.value) return;

    isLoading.value = true;
    try {
      await _postService.createPost(
        text: text,
        imageFile: imageFile,
      );

      // Refresh the feed to show the new post
      final feedController = Get.find<FeedController>();
      await feedController.fetch();
    } finally {
      isLoading.value = false;
    }
  }
}
