import 'package:get/get.dart';
import 'package:posta/app/services/api_client.dart';
import 'package:posta/app/controllers/comment_controller.dart';

class CommentService {
  final ApiClient _apiClient = Get.find<ApiClient>();

  Future<List<Map<String, dynamic>>> getCommentsForPost(int postId) async {
    try {
      print('Fetching comments for post $postId...');

      if (postId <= 0) {
        throw Exception('Invalid post ID');
      }

      final response = await _apiClient.dio.get('/comments/$postId');

      if (response.statusCode != 200) {
        print('Failed to fetch comments with status: ${response.statusCode}');
        final errorMessage = response.data?['error'] ??
            response.statusMessage ??
            'Unknown error';
        throw Exception('Failed to fetch comments: $errorMessage');
      }

      final data = response.data as List<dynamic>;
      final comments = data.cast<Map<String, dynamic>>();
      print('Comments fetched successfully: ${comments.length} comments');

      // Validate comment data structure
      final validatedComments = comments.map((comment) {
        if (comment['id'] == null || comment['text'] == null) {
          print('Warning: Comment missing required fields: $comment');
        }
        return comment;
      }).toList();

      return validatedComments;
    } catch (e) {
      print('Error fetching comments for post $postId: $e');
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Failed to fetch comments: $e');
    }
  }

  Future<Map<String, dynamic>> createComment({
    required int postId,
    required String text,
  }) async {
    try {
      print('Creating comment for post $postId: $text');

      // Validate input
      if (text.trim().isEmpty) {
        throw Exception('Comment text cannot be empty');
      }

      if (text.length > 300) {
        throw Exception('Comment text cannot exceed 300 characters');
      }

      final response = await _apiClient.dio.post('/comments', data: {
        'postId': postId,
        'text': text.trim(),
      });

      if (response.statusCode != 201) {
        print('Failed to create comment with status: ${response.statusCode}');
        final errorMessage = response.data?['error'] ??
            response.statusMessage ??
            'Unknown error';
        throw Exception('Failed to create comment: $errorMessage');
      }

      // The backend returns the created comment, but we need to fetch it with user data
      // to match the format expected by the UI
      final createdComment = response.data;
      print('Comment created successfully: ${response.data}');

      // Wait a moment for the database to be updated, then fetch the comment with user data
      await Future.delayed(const Duration(milliseconds: 500));

      try {
        final commentsResponse = await _apiClient.dio.get('/comments/$postId');
        if (commentsResponse.statusCode == 200) {
          final comments = commentsResponse.data as List<dynamic>;
          final commentWithUser = comments.firstWhere(
            (comment) => comment['id'] == createdComment['id'],
            orElse: () => createdComment,
          );
          return commentWithUser;
        }
      } catch (e) {
        print(
            'Failed to fetch comment with user data, returning basic comment: $e');
      }

      return createdComment;
    } catch (e) {
      print('Error creating comment: $e');
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Failed to create comment: $e');
    }
  }

  Future<void> deleteComment(int commentId) async {
    try {
      print('Deleting comment $commentId...');

      if (commentId <= 0) {
        throw Exception('Invalid comment ID');
      }

      final response = await _apiClient.dio.delete('/comments/$commentId');

      if (response.statusCode != 204) {
        print('Failed to delete comment with status: ${response.statusCode}');
        final errorMessage = response.data?['error'] ??
            response.statusMessage ??
            'Unknown error';
        throw Exception('Failed to delete comment: $errorMessage');
      }

      print('Comment deleted successfully');
    } catch (e) {
      print('Error deleting comment $commentId: $e');
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Failed to delete comment: $e');
    }
  }
}

class CommentBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CommentService>(() => CommentService());
    Get.lazyPut<CommentController>(() => CommentController());
  }
}
