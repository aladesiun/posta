import 'dart:io';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:posta/app/services/profile_service.dart';
import 'package:posta/app/services/image_upload_service.dart';

class ProfileController extends GetxController {
  final ProfileService _profileService = Get.find<ProfileService>();

  final isLoading = false.obs;
  final isUpdating = false.obs;
  final profile = <String, dynamic>{}.obs;
  final isEditing = false.obs;
  final bioController = TextEditingController();
  final isFollowing = false.obs;

  // Posts management
  final userPosts = <Map<String, dynamic>>[].obs;
  final isLoadingPosts = false.obs;
  final hasMorePosts = true.obs;
  final postsOffset = 0.obs;
  final postsLimit = 10;

  @override
  void onInit() {
    super.onInit();
    // Initialize with empty profile
    profile.value = {
      'username': '',
      'bio': '',
      'avatarUrl': null,
      'followers': 0,
      'following': 0,
      'postsCount': 0,
    };
  }

  @override
  void onClose() {
    bioController.dispose();
    super.onClose();
  }

  /// Load profile for a specific username
  Future<void> loadProfile(String username) async {
    if (isLoading.value) return;

    isLoading.value = true;
    try {
      final profileData = await _profileService.getProfile(username);
      profile.value = profileData;

      // Initialize bio controller with current bio
      bioController.text = profileData['bio'] ?? '';

      // Load user posts if we have a user ID
      if (profileData['id'] != null) {
        await loadUserPosts();
      }

      print('Profile loaded: $profileData');
    } catch (e) {
      print('Error loading profile: $e');
      Get.snackbar(
        'Error',
        'Failed to load profile: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Load current user's profile
  Future<void> loadCurrentUserProfile() async {
    if (isLoading.value) return;

    isLoading.value = true;
    try {
      final profileData = await _profileService.getCurrentUserProfile();
      profile.value = profileData;

      // Initialize bio controller with current bio
      bioController.text = profileData['bio'] ?? '';

      // Load current user posts
      await loadCurrentUserPosts();

      print('Current user profile loaded: $profileData');
    } catch (e) {
      print('Error loading current user profile: $e');
      Get.snackbar(
        'Error',
        'Failed to load profile: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Load posts for a specific user
  Future<void> loadUserPosts() async {
    if (isLoadingPosts.value) return;

    isLoadingPosts.value = true;
    try {
      // Reset posts for new user
      userPosts.clear();
      postsOffset.value = 0;
      hasMorePosts.value = true;

      final posts = await _profileService.getUserPosts(
        profile['id'],
        limit: postsLimit,
        offset: postsOffset.value,
      );

      userPosts.addAll(posts);
      postsOffset.value += posts.length;
      hasMorePosts.value = posts.length >= postsLimit;

      print('Loaded ${posts.length} posts for user');
    } catch (e) {
      print('Error loading user posts: $e');
    } finally {
      isLoadingPosts.value = false;
    }
  }

  /// Load current user's posts
  Future<void> loadCurrentUserPosts() async {
    if (isLoadingPosts.value) return;

    isLoadingPosts.value = true;
    try {
      // Reset posts
      userPosts.clear();
      postsOffset.value = 0;
      hasMorePosts.value = true;

      final posts = await _profileService.getCurrentUserPosts(
        limit: postsLimit,
        offset: postsOffset.value,
      );

      userPosts.addAll(posts);
      postsOffset.value += posts.length;
      hasMorePosts.value = posts.length >= postsLimit;

      print('Loaded ${posts.length} posts for current user');
    } catch (e) {
      print('Error loading current user posts: $e');
    } finally {
      isLoadingPosts.value = false;
    }
  }

  /// Load more posts (pagination)
  Future<void> loadMorePosts() async {
    if (isLoadingPosts.value || !hasMorePosts.value) return;

    isLoadingPosts.value = true;
    try {
      final posts = await _profileService.getUserPosts(
        profile['id'],
        limit: postsLimit,
        offset: postsOffset.value,
      );

      userPosts.addAll(posts);
      postsOffset.value += posts.length;
      hasMorePosts.value = posts.length >= postsLimit;

      print('Loaded ${posts.length} more posts');
    } catch (e) {
      print('Error loading more posts: $e');
    } finally {
      isLoadingPosts.value = false;
    }
  }

  /// Refresh profile and posts data
  Future<void> refreshProfile() async {
    try {
      if (profile['id'] != null) {
        // Reload posts
        await loadUserPosts();
      }
    } catch (e) {
      print('Error refreshing profile: $e');
    }
  }

  /// Toggle edit mode
  void toggleEditMode() {
    isEditing.value = !isEditing.value;
    if (!isEditing.value) {
      // Reset bio controller to original value
      bioController.text = profile['bio'] ?? '';
    }
  }

  /// Update profile with new bio and/or avatar
  Future<void> updateProfile() async {
    if (isUpdating.value) return;

    isUpdating.value = true;
    try {
      final updatedProfile = await _profileService.updateProfile(
        bio: bioController.text.trim(),
        avatarUrl: profile['avatarUrl'],
      );

      profile.value = updatedProfile;
      isEditing.value = false;

      Get.snackbar(
        'Success',
        'Profile updated successfully!',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      print('Profile updated: $updatedProfile');
    } catch (e) {
      print('Error updating profile: $e');
      Get.snackbar(
        'Error',
        'Failed to update profile: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isUpdating.value = false;
    }
  }

  /// Upload and update profile picture
  Future<void> uploadProfilePicture() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (image != null) {
        isUpdating.value = true;

        // Upload image using backend endpoint (same approach as posts)
        final imageUrl =
            await _profileService.uploadProfileImage(File(image.path));

        // Update profile with new avatar URL
        profile.value = {
          ...profile.value,
          'avatarUrl': imageUrl,
        };

        Get.snackbar(
          'Success',
          'Profile picture updated successfully!',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        print('Profile picture updated: $imageUrl');
      }
    } catch (e) {
      print('Error uploading profile picture: $e');
      Get.snackbar(
        'Error',
        'Failed to upload profile picture: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isUpdating.value = false;
    }
  }

  /// Follow a user
  Future<void> followUser(String username) async {
    try {
      await _profileService.followUser(username);
      isFollowing.value = true;
      profile['followers'] = (profile['followers'] ?? 0) + 1;

      Get.snackbar(
        'Success',
        'You are now following $username',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print('Error following user: $e');
      Get.snackbar(
        'Error',
        'Failed to follow user: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// Unfollow a user
  Future<void> unfollowUser(String username) async {
    try {
      await _profileService.unfollowUser(username);
      isFollowing.value = false;
      profile['followers'] = (profile['followers'] ?? 1) - 1;

      Get.snackbar(
        'Success',
        'You unfollowed $username',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print('Error unfollowing user: $e');
      Get.snackbar(
        'Error',
        'Failed to unfollow user: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
