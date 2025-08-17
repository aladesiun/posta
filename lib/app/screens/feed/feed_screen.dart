import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:posta/app/controllers/feed_controller.dart';
import 'package:posta/app/controllers/post_controller.dart';
import 'package:posta/app/controllers/auth_controller.dart';
import 'package:posta/app/routes.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:posta/app/utils/date_utils.dart' as PostaDateUtils;

class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(FeedController());
    final postController =
        Get.find<PostController>(); // Use find instead of put
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Posta',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, size: 28),
            onPressed: () {
              Get.toNamed('/create-post');
            },
          ),
          PopupMenuButton<String>(
            icon:
                const Icon(Icons.account_circle, size: 28, color: Colors.black),
            color: Colors.white,
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: Colors.black, width: 2),
            ),
            onSelected: (value) {
              switch (value) {
                case 'profile':
                  Get.toNamed('/profile');
                  break;
                case 'settings':
                  // TODO: Navigate to settings screen
                  break;
                case 'logout':
                  final authController = Get.find<AuthController>();
                  authController.logout();
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    const Icon(Icons.person, size: 20, color: Colors.black),
                    const SizedBox(width: 8),
                    const Text(
                      'Profile',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    const Icon(Icons.settings, size: 20, color: Colors.black),
                    const SizedBox(width: 8),
                    const Text(
                      'Settings',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    const Icon(Icons.logout, size: 20, color: Colors.black),
                    const SizedBox(width: 8),
                    const Text(
                      'Logout',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                ),
                SizedBox(height: 16),
                Text(
                  'Loading posts...',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        }

        final items = controller.posts;

        if (items.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.post_add_outlined,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No posts yet',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Be the first to share something!',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            // TODO: Implement refresh
          },
          color: Colors.black,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final post = items[index];
              final user = post['User'] ?? post['user'] ?? {};

              return AnimatedContainer(
                duration: Duration(milliseconds: 300 + (index * 50)),
                curve: Curves.easeOutCubic,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Post header
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          // Avatar
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              shape: BoxShape.circle,
                            ),
                            child: (post['User']?['avatarUrl'] != null)
                                ? ClipOval(
                                    child: CachedNetworkImage(
                                      imageUrl: post['User']['avatarUrl'],
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => Icon(
                                        Icons.person,
                                        color: Colors.grey[600],
                                      ),
                                      errorWidget: (context, url, error) =>
                                          Icon(
                                        Icons.person,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  )
                                : Icon(
                                    Icons.person,
                                    color: Colors.grey[600],
                                  ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    final username = post['User']?['username'];
                                    if (username != null) {
                                      Get.toNamed('/profile',
                                          arguments: username);
                                    }
                                  },
                                  child: Text(
                                    post['User']?['username'] ?? 'User',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                Text(
                                  PostaDateUtils.DateUtils.formatPostDate(
                                      post['created_at'] ?? post['createdAt']),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.more_horiz,
                              color: Colors.grey[600],
                            ),
                            onPressed: () {
                              // TODO: Show post options
                            },
                          ),
                        ],
                      ),
                    ),

                    // Post content
                    if (post['text'] != null &&
                        post['text'].toString().isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          post['text'],
                          style: const TextStyle(
                            fontSize: 16,
                            height: 1.4,
                            color: Colors.black87,
                          ),
                        ),
                      ),

                    // Media display (if any)
                    if (post['mediaUrl'] != null)
                      Container(
                        margin: const EdgeInsets.only(top: 12),
                        height: 200,
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.vertical(
                            bottom: Radius.circular(16),
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            bottom: Radius.circular(16),
                          ),
                          child: CachedNetworkImage(
                            imageUrl: post['mediaUrl'],
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: 200,
                            placeholder: (context, url) => Container(
                              color: Colors.grey[200],
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.grey[400]!,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Loading image...',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: Colors.grey[200],
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.error_outline,
                                      size: 48,
                                      color: Colors.grey[400],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Failed to load image',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                    // Action buttons
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          _buildActionButton(
                            icon: postController.isLikeLoading(post['id'])
                                ? Icons.hourglass_empty
                                : (post['hasLiked'] == true ||
                                        post['hasLiked'] == 'true')
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                            label:
                                '${post['likeCount'] ?? 0}', // Show actual like count
                            onTap: postController.isLikeLoading(post['id'])
                                ? null
                                : () {
                                    postController.toggleLike(post['id']);
                                  },
                          ),
                          const SizedBox(width: 24),
                          _buildActionButton(
                            icon: Icons.chat_bubble_outline,
                            label:
                                '${post['commentCount'] ?? 0}', // Show actual comment count
                            onTap: () {
                              Get.toNamed('/comments', arguments: post);
                            },
                          ),
                          const SizedBox(width: 24),
                          _buildActionButton(
                            icon: Icons.share_outlined,
                            label: 'Share',
                            onTap: () {
                              // TODO: Handle share
                            },
                          ),
                          const Spacer(),
                          IconButton(
                            icon: Icon(
                              Icons.bookmark_border,
                              color: Colors.grey[600],
                            ),
                            onPressed: () {
                              // TODO: Handle bookmark
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      }),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
  }) {
    final isDisabled = onTap == null;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: isDisabled ? Colors.grey[400] : Colors.grey[700],
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: isDisabled ? Colors.grey[400] : Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
