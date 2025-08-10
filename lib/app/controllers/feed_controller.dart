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
}
