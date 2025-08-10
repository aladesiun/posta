import 'package:get/get.dart';
import 'package:posta/app/services/api_client.dart';

class FeedService {
  final ApiClient _api = Get.find<ApiClient>();

  Future<List<Map<String, dynamic>>> fetchFeed(
      {int limit = 20, int offset = 0}) async {
    try {
      print('Making API call to fetch feed...');
      final resp = await _api.dio
          .get('/posts', queryParameters: {'limit': limit, 'offset': offset});
      print('API response status: ${resp.statusCode}');
      print('API response data: ${resp.data}');

      final data = resp.data as List<dynamic>;
      final posts = data.cast<Map<String, dynamic>>();
      print('Parsed posts: $posts');
      return posts;
    } catch (e) {
      print('Error in fetchFeed: $e');
      rethrow;
    }
  }
}

class FeedBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(FeedService());
  }
}
