import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:posta/app/services/post_service.dart';
import 'package:posta/app/services/like_service.dart';
import 'package:posta/app/controllers/feed_controller.dart';

class PostController extends GetxController {
  final PostService _postService = Get.find<PostService>();
  final LikeService _likeService = Get.find<LikeService>();
  final isLoading = false.obs;
  final _likeLoadingStates = <int, bool>{}.obs; // Track loading state per post

  bool isLikeLoading(int postId) => _likeLoadingStates[postId] ?? false;

  void _setLikeLoading(int postId, bool loading) {
    _likeLoadingStates[postId] = loading;
  }

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

  Future<void> toggleLike(int postId) async {
    try {
      print('PostController: Starting like toggle for post $postId');
      _setLikeLoading(postId, true);

      final result = await _likeService.toggleLike(postId);
      print('PostController: Like toggled successfully: $result');

      // Update the specific post's like status instead of refetching the entire feed
      final feedController = Get.find<FeedController>();
      final currentPost = feedController.posts.firstWhere(
        (post) => post['id'] == postId,
        orElse: () => {'likeCount': 0},
      );
      final currentLikeCount = currentPost['likeCount'] ?? 0;
      final liked = result['liked'] as bool;
      final newLikeCount = liked ? currentLikeCount + 1 : currentLikeCount - 1;

      print(
          'PostController: Updating post $postId: currentCount=$currentLikeCount, newCount=$newLikeCount, hasLiked=$liked');
      print('PostController: Current post data before update: $currentPost');
      feedController.updatePostLikeStatus(postId, liked, newLikeCount);

      // Verify the update
      final updatedPost = feedController.posts.firstWhere(
        (post) => post['id'] == postId,
        orElse: () => {},
      );
      print('PostController: Post data after update: $updatedPost');
    } catch (e) {
      print('PostController: Error toggling like for post $postId: $e');
      final errorMessage = e.toString();

      if (errorMessage.contains('Authentication required')) {
        Get.snackbar(
          'Authentication Error',
          'Please login again to like posts',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 3),
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Error',
          'Failed to toggle like: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 3),
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } finally {
      _setLikeLoading(postId, false);
      print('PostController: Like toggle completed for post $postId');
    }
  }
}
