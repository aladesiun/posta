import 'package:get/get.dart';
import 'package:posta/app/services/feed_service.dart';

class FeedController extends GetxController {
  final FeedService _feed = Get.find<FeedService>();
  final posts = <Map<String, dynamic>>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetch();
  }

  Future<void> fetch() async {
    isLoading.value = true;
    try {
      print('Fetching feed...');
      posts.value = await _feed.fetchFeed();
      print('Feed fetched successfully. Posts count: ${posts.length}');
      print('Posts: $posts');
    } catch (e) {
      print('Error fetching feed: $e');
      posts.value = [];
    } finally {
      isLoading.value = false;
    }
  }

  void updatePostLikeStatus(int postId, bool hasLiked, int newLikeCount) {
    final postIndex = posts.indexWhere((post) => post['id'] == postId);
    if (postIndex != -1) {
      final updatedPost = Map<String, dynamic>.from(posts[postIndex]);
      updatedPost['hasLiked'] = hasLiked;
      updatedPost['likeCount'] = newLikeCount;

      // Force reactivity by updating the entire list
      final newPosts = List<Map<String, dynamic>>.from(posts);
      newPosts[postIndex] = updatedPost;
      posts.value = newPosts;

      print(
          'Updated post $postId like status: hasLiked=$hasLiked, likeCount=$newLikeCount');
      print('Posts after update: ${posts.value}');
    } else {
      print('Post $postId not found in feed for like status update');
    }
  }

  void incrementCommentCount(int postId) {
    final postIndex = posts.indexWhere((post) => post['id'] == postId);
    if (postIndex != -1) {
      final updatedPost = Map<String, dynamic>.from(posts[postIndex]);
      final currentCount = updatedPost['commentCount'] ?? 0;
      updatedPost['commentCount'] = currentCount + 1;
      posts[postIndex] = updatedPost;
      print(
          'Incremented comment count for post $postId: $currentCount -> ${currentCount + 1}');
    } else {
      print('Post $postId not found in feed for comment count update');
    }
  }

  void decrementCommentCount(int postId) {
    final postIndex = posts.indexWhere((post) => post['id'] == postId);
    if (postIndex != -1) {
      final updatedPost = Map<String, dynamic>.from(posts[postIndex]);
      final currentCount = updatedPost['commentCount'] ?? 0;
      updatedPost['commentCount'] = currentCount > 0 ? currentCount - 1 : 0;
      posts[postIndex] = updatedPost;
      print(
          'Decremented comment count for post $postId: $currentCount -> ${updatedPost['commentCount']}');
    } else {
      print('Post $postId not found in feed for comment count update');
    }
  }
}
