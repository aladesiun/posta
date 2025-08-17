import 'package:get/get.dart';
import 'package:posta/app/services/api_client.dart';

class LikeService {
  final ApiClient _apiClient = Get.find<ApiClient>();

  Future<Map<String, dynamic>> toggleLike(int postId) async {
    try {
      print('Toggling like for post $postId...');
      final response = await _apiClient.dio.post('/likes/$postId/toggle');

      if (response.statusCode != 200) {
        print('Like toggle failed with status: ${response.statusCode}');
        print('Response data: ${response.data}');
        throw Exception('Failed to toggle like: ${response.statusMessage}');
      }

      print('Like toggle response: ${response.data}');
      return response.data;
    } catch (e) {
      print('Error toggling like for post $postId: $e');

      // Check for specific error types
      if (e.toString().contains('401') ||
          e.toString().contains('Unauthorized')) {
        throw Exception('Authentication required. Please login again.');
      } else if (e.toString().contains('404') ||
          e.toString().contains('Not found')) {
        throw Exception('Post not found.');
      } else if (e.toString().contains('Network') ||
          e.toString().contains('timeout')) {
        throw Exception('Network error. Please check your connection.');
      } else {
        throw Exception('Failed to toggle like: $e');
      }
    }
  }
}

class LikeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LikeService>(() => LikeService());
  }
}
