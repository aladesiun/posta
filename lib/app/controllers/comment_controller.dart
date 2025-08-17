import 'package:get/get.dart';
import 'package:posta/app/services/comment_service.dart';
import 'package:posta/app/controllers/feed_controller.dart';
import 'package:posta/app/controllers/auth_controller.dart';

class CommentController extends GetxController {
  final CommentService _commentService = Get.find<CommentService>();
  
  // Store comments for each post
  final _comments = <int, List<Map<String, dynamic>>>{}.obs;
  
  // Loading states for each post
  final _loadingStates = <int, bool>{}.obs;
  
  // Comment creation loading state
  final _isCreatingComment = false.obs;

  // Get comments for a specific post
  List<Map<String, dynamic>> getCommentsForPost(int postId) {
    return _comments[postId] ?? [];
  }

  // Check if comments are loading for a post
  bool isLoadingComments(int postId) {
    return _loadingStates[postId] ?? false;
  }

  // Check if comment creation is in progress
  bool get isCreatingComment => _isCreatingComment.value;

  // Fetch comments for a post
  Future<void> fetchComments(int postId) async {
    try {
      print('Fetching comments for post $postId...');
      _loadingStates[postId] = true;
      
      final comments = await _commentService.getCommentsForPost(postId);
      print('Received ${comments.length} comments from backend for post $postId');
      
      // Ensure comments have the required fields
      final validatedComments = comments.map((comment) {
        if (comment['User'] == null && comment['user'] == null) {
          print('Warning: Comment ${comment['id']} missing user data, creating fallback');
          // If no user data, create a fallback
          return {
            ...comment,
            'User': {
              'id': comment['userId'] ?? 0,
              'username': 'Unknown User',
              'avatarUrl': null,
            }
          };
        }
        return comment;
      }).toList();
      
      _comments[postId] = validatedComments;
      print('Successfully stored ${validatedComments.length} comments for post $postId');
    } catch (e) {
      print('Error fetching comments for post $postId: $e');
      // Keep existing comments if fetch fails
    } finally {
      _loadingStates[postId] = false;
      print('Finished loading comments for post $postId');
    }
  }

  // Create a new comment
  Future<void> createComment({
    required int postId,
    required String text,
  }) async {
    final trimmedText = text.trim();
    if (trimmedText.isEmpty) {
      throw Exception('Comment text cannot be empty');
    }
    
    if (trimmedText.length > 300) {
      throw Exception('Comment text cannot exceed 300 characters');
    }

    try {
      _isCreatingComment.value = true;
      print('Creating comment for post $postId with text: "${trimmedText.substring(0, trimmedText.length > 50 ? 50 : trimmedText.length)}${trimmedText.length > 50 ? '...' : ''}"');
      
      final newComment = await _commentService.createComment(
        postId: postId,
        text: trimmedText,
      );

      // Ensure the new comment has user data
      if (newComment['User'] == null && newComment['user'] == null) {
        // If no user data, create a fallback
        newComment['User'] = {
          'id': newComment['userId'] ?? 0,
          'username': 'Unknown User',
          'avatarUrl': null,
        };
      }

      // Add the new comment to the list
      if (_comments[postId] != null) {
        _comments[postId]!.insert(0, newComment);
      } else {
        _comments[postId] = [newComment];
      }

      print('Comment created successfully and added to local list. Total comments for post $postId: ${_comments[postId]?.length ?? 0}');

      // Update the feed controller to increment comment count
      try {
        final feedController = Get.find<FeedController>();
        feedController.incrementCommentCount(postId);
        print('Updated feed controller comment count for post $postId');
      } catch (e) {
        print('Feed controller not found, skipping comment count update: $e');
      }
    } catch (e) {
      print('Error creating comment: $e');
      rethrow;
    } finally {
      _isCreatingComment.value = false;
    }
  }

  // Delete a comment
  Future<void> deleteComment(int postId, int commentId) async {
    try {
      print('Attempting to delete comment $commentId from post $postId');
      
      // Validate that the comment exists locally before attempting deletion
      final commentExists = _comments[postId]?.any((comment) => comment['id'] == commentId) ?? false;
      if (!commentExists) {
        print('Warning: Comment $commentId not found locally for post $postId');
        throw Exception('Comment not found');
      }

      await _commentService.deleteComment(commentId);
      print('Comment $commentId deleted successfully from backend');
      
      // Remove comment from local list
      if (_comments[postId] != null) {
        _comments[postId]!.removeWhere((comment) => comment['id'] == commentId);
        print('Comment $commentId removed from local list. Remaining comments for post $postId: ${_comments[postId]!.length}');
      }

      // Update the feed controller to decrement comment count
      try {
        final feedController = Get.find<FeedController>();
        feedController.decrementCommentCount(postId);
        print('Updated feed controller comment count for post $postId');
      } catch (e) {
        print('Feed controller not found, skipping comment count update: $e');
      }
    } catch (e) {
      print('Error deleting comment $commentId: $e');
      rethrow;
    }
  }

  // Clear comments for a post (useful when navigating away)
  void clearComments(int postId) {
    _comments.remove(postId);
    _loadingStates.remove(postId);
  }

  // Clear all comments (useful when navigating away from comments screen)
  void clearAllComments() {
    _comments.clear();
    _loadingStates.clear();
  }

  // Check if user can delete a comment
  bool canDeleteComment(Map<String, dynamic> comment, int currentUserId) {
    if (comment == null || currentUserId == null) return false;
    
    // Handle both backend response formats
    final userId = comment['userId'] ?? comment['user_id'];
    return userId == currentUserId;
  }

  // Get current user ID from auth controller
  int? getCurrentUserId() {
    try {
      final authController = Get.find<AuthController>();
      return authController.isAuthenticated.value ? 1 : null; // Temporary fix
    } catch (e) {
      print('Auth controller not found: $e');
      return null;
    }
  }

  // Validate comment data structure
  bool isValidComment(Map<String, dynamic> comment) {
    return comment != null && 
           comment['id'] != null && 
           comment['text'] != null && 
           comment['text'].toString().isNotEmpty;
  }

  // Get comment count for a post
  int getCommentCount(int postId) {
    return _comments[postId]?.length ?? 0;
  }

  @override
  void onClose() {
    clearAllComments();
    super.onClose();
  }
} 