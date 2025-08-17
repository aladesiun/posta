import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:posta/app/controllers/profile_controller.dart';
import 'package:posta/app/routes.dart';
import 'package:posta/app/utils/date_utils.dart' as PostaDateUtils;

class ProfileScreen extends StatelessWidget {
  final String? username; // If null, show current user's profile

  const ProfileScreen({super.key, this.username});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProfileController());

    // Get username from arguments if not provided directly
    final String? profileUsername = username ?? Get.arguments as String?;

    // Load profile data when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Small delay to ensure all services are initialized
      await Future.delayed(const Duration(milliseconds: 100));

      if (profileUsername != null) {
        controller.loadProfile(profileUsername);
      } else {
        controller.loadCurrentUserProfile();
      }
    });

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          profileUsername ?? 'My Profile',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        actions: [
          if (username == null) // Only show edit button for current user
            Obx(() => controller.isEditing.value
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextButton(
                        onPressed: controller.toggleEditMode,
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: controller.updateProfile,
                        child: const Text(
                          'Save',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  )
                : TextButton(
                    onPressed: controller.toggleEditMode,
                    child: const Text(
                      'Edit',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
            ),
          );
        }

        final profile = controller.profile.value;

        return RefreshIndicator(
          onRefresh: () async {
            final controller = Get.find<ProfileController>();
            await controller.refreshProfile();
          },
          color: Colors.black,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Header
                _buildProfileHeader(controller, profile),

                const SizedBox(height: 24),

                // Bio Section
                _buildBioSection(controller, profile),

                const SizedBox(height: 24),

                // Stats Section
                _buildStatsSection(profile),

                const SizedBox(height: 24),

                // Follow Button (only for other users)
                if (profileUsername != null)
                  _buildFollowButton(controller, profile),

                const SizedBox(height: 24),

                // Posts Section (placeholder for now)
                _buildPostsSection(),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildProfileHeader(
      ProfileController controller, Map<String, dynamic> profile) {
    return Center(
      child: Column(
        children: [
          // Profile Picture
          Stack(
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black, width: 3),
                ),
                child: ClipOval(
                  child: profile['avatarUrl'] != null
                      ? CachedNetworkImage(
                          imageUrl: profile['avatarUrl'],
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Colors.grey[300],
                            child: const Icon(
                              Icons.person,
                              size: 60,
                              color: Colors.grey,
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey[300],
                            child: const Icon(
                              Icons.person,
                              size: 60,
                              color: Colors.grey,
                            ),
                          ),
                        )
                      : Container(
                          color: Colors.grey[300],
                          child: const Icon(
                            Icons.person,
                            size: 60,
                            color: Colors.grey,
                          ),
                        ),
                ),
              ),

              // Edit Profile Picture Button (only for current user)
              if (username == null)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: controller.uploadProfilePicture,
                      constraints: const BoxConstraints(
                        minWidth: 36,
                        minHeight: 36,
                      ),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 16),

          // Username
          Text(
            profile['username'] ?? 'Unknown User',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBioSection(
      ProfileController controller, Map<String, dynamic> profile) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bio',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Obx(() => controller.isEditing.value
              ? TextField(
                  controller: controller.bioController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Tell us about yourself...',
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black, width: 2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black, width: 2),
                    ),
                  ),
                )
              : Text(
                  profile['bio']?.isNotEmpty == true
                      ? profile['bio']
                      : 'No bio yet',
                  style: TextStyle(
                    fontSize: 16,
                    color: profile['bio']?.isNotEmpty == true
                        ? Colors.black
                        : Colors.grey,
                  ),
                )),
        ],
      ),
    );
  }

  Widget _buildStatsSection(Map<String, dynamic> profile) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatItem('Posts', '${profile['postsCount'] ?? 0}'),
        _buildStatItem('Followers', '${profile['followers'] ?? 0}'),
        _buildStatItem('Following', '${profile['following'] ?? 0}'),
      ],
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildFollowButton(
      ProfileController controller, Map<String, dynamic> profile) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: Obx(() => ElevatedButton(
            onPressed: () {
              if (controller.isFollowing.value) {
                controller.unfollowUser(profile['username']);
              } else {
                controller.followUser(profile['username']);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  controller.isFollowing.value ? Colors.grey : Colors.black,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              elevation: 0,
            ),
            child: Text(
              controller.isFollowing.value ? 'Unfollow' : 'Follow',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          )),
    );
  }

  Widget _buildPostsSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Posts',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          Obx(() {
            final controller = Get.find<ProfileController>();

            if (controller.isLoadingPosts.value &&
                controller.userPosts.isEmpty) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                ),
              );
            }

            if (controller.userPosts.isEmpty) {
              return Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.post_add_outlined,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No posts yet',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Posts will appear here',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: [
                ...controller.userPosts.map((post) => _buildPostItem(post)),
                if (controller.hasMorePosts.value)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                      child: ElevatedButton(
                        onPressed: controller.loadMorePosts,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text('Load More Posts'),
                      ),
                    ),
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPostItem(Map<String, dynamic> post) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Post header with profile picture
          Row(
            children: [
              // Profile picture
              Container(
                width: 32,
                height: 32,
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
                            size: 16,
                          ),
                          errorWidget: (context, url, error) => Icon(
                            Icons.person,
                            color: Colors.grey[600],
                            size: 16,
                          ),
                        ),
                      )
                    : Icon(
                        Icons.person,
                        color: Colors.grey[600],
                        size: 16,
                      ),
              ),
              const SizedBox(width: 8),
              // Username and date
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post['User']?['username'] ?? 'User',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      PostaDateUtils.DateUtils.formatPostDate(
                          post['created_at'] ?? post['createdAt']),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Post text
          if (post['text'] != null && post['text'].toString().isNotEmpty)
            Text(
              post['text'],
              style: const TextStyle(
                fontSize: 16,
                height: 1.4,
                color: Colors.black87,
              ),
            ),

          // Media display (if any)
          if (post['mediaUrl'] != null) ...[
            if (post['text'] != null && post['text'].toString().isNotEmpty)
              const SizedBox(height: 12),
            Container(
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: post['mediaUrl'],
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[300],
                    child: const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[300],
                    child: const Icon(
                      Icons.error,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ),
          ],

          // Post stats
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.favorite_border,
                size: 16,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 4),
              Text(
                '${post['likeCount'] ?? 0}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(width: 16),
              Icon(
                Icons.chat_bubble_outline,
                size: 16,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 4),
              Text(
                '${post['commentCount'] ?? 0}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
