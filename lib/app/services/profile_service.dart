import 'package:get/get.dart' hide FormData, MultipartFile;
import 'package:posta/app/services/api_client.dart';
import 'package:posta/app/services/image_upload_service.dart';
import 'package:dio/dio.dart';
import 'dart:io';

class ProfileService {
  final ApiClient _api = Get.find<ApiClient>();

  /// Get profile information for a specific username
  Future<Map<String, dynamic>> getProfile(String username) async {
    try {
      final response = await _api.dio.get('/profile/$username');
      return response.data;
    } catch (e) {
      print('Error fetching profile: $e');
      throw Exception('Failed to fetch profile: $e');
    }
  }

  /// Get current user's profile with posts count
  Future<Map<String, dynamic>> getCurrentUserProfile() async {
    try {
      final response = await _api.dio.get('/profile/me/posts');
      return response.data;
    } catch (e) {
      print(
          'Error fetching current user profile with /me/posts, trying fallback: $e');
      // Fallback: try to get basic profile info
      return await _getCurrentUserProfileFallback();
    }
  }

  /// Fallback method to get current user profile
  Future<Map<String, dynamic>> _getCurrentUserProfileFallback() async {
    try {
      // Use the posts endpoint to get user info from JWT token
      final response = await _api.dio
          .get('/posts', queryParameters: {'limit': 1, 'offset': 0});

      if (response.data is List && response.data.isNotEmpty) {
        final firstPost = response.data[0];
        final user = firstPost['user'];

        if (user != null) {
          // Get posts count separately
          final postsCount = await getUserPostsCount(user['id']);

          return {
            'id': user['id'],
            'username': user['username'],
            'bio': 'No bio yet',
            'avatarUrl': user['avatarUrl'],
            'followers': 0,
            'following': 0,
            'postsCount': postsCount,
          };
        }
      }

      // If no posts found, return default profile
      return {
        'username': 'Current User',
        'bio': 'No bio yet',
        'avatarUrl': null,
        'followers': 0,
        'following': 0,
        'postsCount': 0,
      };
    } catch (e) {
      print('Fallback profile method also failed: $e');
      throw Exception('Failed to fetch current user profile: $e');
    }
  }

  /// Get posts by a specific user
  Future<List<Map<String, dynamic>>> getUserPosts(int userId,
      {int limit = 20, int offset = 0}) async {
    try {
      final response =
          await _api.dio.get('/posts/user/$userId', queryParameters: {
        'limit': limit,
        'offset': offset,
      });
      return List<Map<String, dynamic>>.from(response.data);
    } catch (e) {
      print('Error fetching user posts: $e');
      throw Exception('Failed to fetch user posts: $e');
    }
  }

  /// Upload profile image using backend endpoint
  Future<String> uploadProfileImage(File imageFile) async {
    try {
      // Create FormData for multipart upload using the same approach as PostService
      final formData = FormData.fromMap({});

      formData.files.add(MapEntry(
        'image',
        await MultipartFile.fromFile(
          imageFile.path,
          filename: 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ),
      ));

      final response =
          await _api.dio.post('/profile/upload-image', data: formData);

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to upload profile image: ${response.statusMessage}');
      }

      final data = response.data;
      if (data['success'] == true && data['avatarUrl'] != null) {
        return data['avatarUrl'] as String;
      } else {
        throw Exception('Invalid response from server');
      }
    } catch (e) {
      print('Error uploading profile image: $e');
      throw Exception('Failed to upload profile image: $e');
    }
  }

  /// Get posts count for a specific user
  Future<int> getUserPostsCount(int userId) async {
    try {
      final response =
          await _api.dio.get('/posts/user/$userId', queryParameters: {
        'limit': 1,
        'offset': 0,
      });

      // Get total count from response headers or calculate from data
      // For now, we'll use a simple approach
      return response.data.length;
    } catch (e) {
      print('Error getting posts count: $e');
      return 0;
    }
  }

  /// Get current user's posts
  Future<List<Map<String, dynamic>>> getCurrentUserPosts(
      {int limit = 20, int offset = 0}) async {
    try {
      // First get current user profile to get userId
      final profile = await getCurrentUserProfile();
      final userId = profile['id'];

      if (userId == null) {
        throw Exception('User ID not found');
      }

      return await getUserPosts(userId, limit: limit, offset: offset);
    } catch (e) {
      print('Error fetching current user posts: $e');
      throw Exception('Failed to fetch current user posts: $e');
    }
  }

  /// Update current user's profile
  Future<Map<String, dynamic>> updateProfile({
    String? bio,
    String? avatarUrl,
  }) async {
    try {
      final response = await _api.dio.put('/profile', data: {
        if (bio != null) 'bio': bio,
        if (avatarUrl != null) 'avatarUrl': avatarUrl,
      });
      return response.data;
    } catch (e) {
      print('Error updating profile: $e');
      throw Exception('Failed to update profile: $e');
    }
  }

  /// Follow a user
  Future<Map<String, dynamic>> followUser(String username) async {
    try {
      final response = await _api.dio.post('/profile/$username/follow');
      return response.data;
    } catch (e) {
      print('Error following user: $e');
      throw Exception('Failed to follow user: $e');
    }
  }

  /// Unfollow a user
  Future<Map<String, dynamic>> unfollowUser(String username) async {
    try {
      final response = await _api.dio.post('/profile/$username/unfollow');
      return response.data;
    } catch (e) {
      print('Error unfollowing user: $e');
      throw Exception('Failed to unfollow user: $e');
    }
  }
}

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(ProfileService());
  }
}
