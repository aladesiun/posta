import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:posta/app/controllers/comment_controller.dart';
import 'package:posta/app/controllers/auth_controller.dart';
import 'package:posta/app/utils/date_utils.dart' as PostaDateUtils;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:posta/app/models/post.dart';
import 'package:posta/app/models/comment.dart';

class CommentsScreen extends StatefulWidget {
  const CommentsScreen({super.key});

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  Post? post;
  final TextEditingController _textController = TextEditingController();
  final CommentController _commentController = Get.find<CommentController>();
  final AuthController _authController = Get.find<AuthController>();

  @override
  void initState() {
    super.initState();
    // Get post data from route arguments
    final args = Get.arguments;
    if (args != null && args is Map<String, dynamic>) {
      try {
        post = Post.fromJson(args);
        // Fetch comments when screen loads
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _loadComments();
        });
      } catch (e) {
        print('Error parsing post data: $e');
        Get.snackbar(
          'Error',
          'Invalid post data format',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        Get.back();
      }
    } else {
      Get.snackbar(
        'Error',
        'No post data provided',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      Get.back(); // Go back if no post data
    }
  }

  void _loadComments() {
    try {
      if (post?.id != null) {
        _commentController.fetchComments(post!.id);
      } else {
        print('Warning: Post ID is null, cannot fetch comments');
        Get.snackbar(
          'Error',
          'Invalid post data',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('Error loading comments: $e');
      Get.snackbar(
        'Error',
        'Failed to load comments: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _refreshComments() {
    try {
      if (post?.id != null) {
        _commentController.fetchComments(post!.id);
        Get.snackbar(
          'Refreshing',
          'Loading latest comments...',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.blue,
          colorText: Colors.white,
          duration: const Duration(seconds: 1),
        );
      } else {
        Get.snackbar(
          'Error',
          'Invalid post data',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('Error refreshing comments: $e');
      Get.snackbar(
        'Error',
        'Failed to refresh comments: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _handleCommentError(String operation, dynamic error) {
    print('Error in comment $operation: $error');
    String errorMessage = 'Unknown error occurred';

    if (error is Exception) {
      errorMessage = error.toString().replaceAll('Exception: ', '');
    } else if (error is String) {
      errorMessage = error;
    }

    Get.snackbar(
      'Error',
      'Failed to $operation: $errorMessage',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    if (post?.id != null) {
      _commentController.clearComments(post!.id);
    }
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Ensure comments are loaded when dependencies change
    if (post?.id != null &&
        _commentController.getCommentsForPost(post!.id).isEmpty &&
        !_commentController.isLoadingComments(post!.id)) {
      _loadComments();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Comments'),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        titleTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: () => _refreshComments(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Post preview at the top
          _buildPostPreview(),

          // Comments list
          Expanded(
            child: Obx(() {
              // Check if post is null first
              if (post == null) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Post data not available',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                );
              }

              if (_commentController.isLoadingComments(post!.id)) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text(
                        'Loading comments...',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                );
              }

              final comments = _commentController.getCommentsForPost(post!.id);

              if (comments.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.chat_bubble_outline,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No comments yet',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Be the first to comment!',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextButton.icon(
                        onPressed: () => _refreshComments(),
                        icon: const Icon(Icons.refresh, size: 16),
                        label: const Text('Refresh'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () {
                  if (post != null) {
                    return _commentController.fetchComments(post!.id);
                  }
                  return Future.value();
                },
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    final comment = comments[index];
                    if (!_commentController.isValidComment(comment)) {
                      return const SizedBox.shrink(); // Skip invalid comments
                    }
                    return _buildCommentItem(comment);
                  },
                  // Performance optimizations
                  addAutomaticKeepAlives: false,
                  addRepaintBoundaries: false,
                  cacheExtent: 100,
                ),
              ).marginOnly(top: 16);
            }),
          ),

          // Comment input at the bottom
          _buildCommentInput(),
        ],
      ),
    );
  }

  Widget _buildPostPreview() {
    // Check if post is null first
    if (post == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey[200]!),
          ),
        ),
        child: const Center(
          child: Text(
            'Post data not available',
            style: TextStyle(
              color: Colors.red,
              fontSize: 16,
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Row(
        children: [
          // User avatar
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.grey[300],
            backgroundImage: (post!.toJson()['User']?['avatarUrl'] != null)
                ? CachedNetworkImageProvider(
                    post!.toJson()['User']['avatarUrl'])
                : null,
            child: (post!.toJson()['User']?['avatarUrl'] == null)
                ? Icon(Icons.person, color: Colors.grey[600])
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post!.toJson()['User']?['username'] ?? 'Unknown User',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                if (post!.text != null && post!.text.isNotEmpty)
                  Text(
                    post!.text,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentItem(Map<String, dynamic> comment) {
    final currentUserId = _commentController.getCurrentUserId();
    final canDelete = currentUserId != null &&
        _commentController.canDeleteComment(comment, currentUserId);

    // Handle both backend response formats and ensure data integrity
    final user = comment['User'] ?? comment['user'];
    final username = user?['username'] ?? 'Unknown User';
    final avatarUrl = user?['avatarUrl'];
    final createdAt = comment['created_at'] ?? comment['createdAt'];
    final commentText = comment['text'] ?? 'No text available';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Commenter avatar
          CircleAvatar(
            radius: 16,
            backgroundColor: Colors.grey[300],
            backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty
                ? CachedNetworkImageProvider(avatarUrl)
                : null,
            child: avatarUrl == null || avatarUrl.isEmpty
                ? Icon(Icons.person, size: 20, color: Colors.grey[600])
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        username,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      PostaDateUtils.DateUtils.formatPostDate(createdAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  commentText,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.4,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          if (canDelete)
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 18),
              onPressed: () => _showDeleteCommentDialog(comment),
              color: Colors.grey[600],
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              tooltip: 'Delete comment',
            ),
        ],
      ),
    );
  }

  Widget _buildCommentInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              decoration: InputDecoration(
                hintText: 'Write a comment...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(color: Colors.black),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                counterText: '${_textController.text.length}/300',
                counterStyle: TextStyle(
                  color: _textController.text.length > 250
                      ? Colors.orange
                      : Colors.grey,
                  fontSize: 12,
                ),
                errorText: _textController.text.length > 300
                    ? 'Comment too long'
                    : null,
              ),
              maxLines: null,
              maxLength: 300,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _submitComment(),
              onChanged: (value) {
                setState(() {}); // Rebuild to update counter and validation
              },
            ),
          ),
          const SizedBox(width: 12),
          Obx(() {
            final isValid = _textController.text.trim().isNotEmpty &&
                _textController.text.length <= 300;
            return ElevatedButton(
              onPressed: (_commentController.isCreatingComment || !isValid)
                  ? null
                  : _submitComment,
              style: ElevatedButton.styleFrom(
                backgroundColor: isValid ? Colors.black : Colors.grey,
                foregroundColor: Colors.white,
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(12),
              ),
              child: _commentController.isCreatingComment
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.send, size: 20),
            );
          }),
        ],
      ),
    );
  }

  void _submitComment() {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      Get.snackbar(
        'Error',
        'Comment text cannot be empty',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (text.length > 300) {
      Get.snackbar(
        'Error',
        'Comment text cannot exceed 300 characters',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (post?.id == null) {
      Get.snackbar(
        'Error',
        'Invalid post data',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    _commentController
        .createComment(
      postId: post!.id,
      text: text,
    )
        .then((_) {
      _textController.clear();
      // Refresh comments immediately without showing success toast
      _commentController.fetchComments(post!.id);
    }).catchError((error) {
      _handleCommentError('post comment', error);
    });
  }

  void _showDeleteCommentDialog(Map<String, dynamic> comment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Comment'),
        content: const Text(
            'Are you sure you want to delete this comment? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteComment(comment);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _deleteComment(Map<String, dynamic> comment) {
    if (comment['id'] == null) {
      Get.snackbar(
        'Error',
        'Invalid comment data',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (post?.id == null) {
      Get.snackbar(
        'Error',
        'Invalid post data',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    _commentController
        .deleteComment(
      post!.id,
      comment['id'],
    )
        .then((_) {
      // Refresh comments immediately without showing success toast
      _commentController.fetchComments(post!.id);
    }).catchError((error) {
      _handleCommentError('delete comment', error);
    });
  }
}
