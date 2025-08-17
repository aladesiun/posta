import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:posta/app/routes.dart';
import 'package:posta/app/controllers/auth_controller.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _checkAuthState();
  }

  void _checkAuthState() {
    try {
      // If user is already authenticated, go directly to feed
      final authController = Get.find<AuthController>();
      if (authController.isAuthenticated.value) {
        Get.offAllNamed(AppRoutes.feed);
      }
    } catch (e) {
      print('Error finding AuthController in onboarding: $e');
      // AuthController not available yet, continue with onboarding
    }
  }

  final List<OnboardingSlide> _slides = [
    OnboardingSlide(
      title: 'Welcome to Posta',
      subtitle: 'Your privacy-focused social network',
      description:
          'Connect with friends and share moments while keeping your data secure and private.',
      icon: Icons.security,
      color: Colors.blue,
    ),
    OnboardingSlide(
      title: 'Share Your Stories',
      subtitle: 'Create and share posts',
      description:
          'Share your thoughts, photos, and experiences with your community in a safe environment.',
      icon: Icons.photo_camera,
      color: Colors.green,
    ),
    OnboardingSlide(
      title: 'Connect & Engage',
      subtitle: 'Like, comment, and follow',
      description:
          'Interact with posts, follow interesting people, and build meaningful connections.',
      icon: Icons.favorite,
      color: Colors.pink,
    ),
    OnboardingSlide(
      title: 'Privacy First',
      subtitle: 'Your data, your control',
      description:
          'We believe in minimal data collection and strong privacy protection. Your information stays yours.',
      icon: Icons.lock,
      color: Colors.purple,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _getStarted();
    }
  }

  void _getStarted() {
    Get.offAllNamed(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top buttons row
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back to Login button
                  TextButton(
                    onPressed: () {
                      Get.offAllNamed(AppRoutes.login);
                    },
                    child: const Text(
                      'Back to Login',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  // Skip button
                  TextButton(
                    onPressed: _getStarted,
                    child: const Text(
                      'Skip Intro',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Page content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _slides.length,
                itemBuilder: (context, index) {
                  return _buildSlide(_slides[index]);
                },
              ),
            ),

            // Bottom section with indicators and buttons
            Container(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // Page indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _slides.length,
                      (index) => _buildPageIndicator(index),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Next/Get Started button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _nextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        _currentPage == _slides.length - 1
                            ? 'Get Started'
                            : 'Next',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Already have an account button
                  TextButton(
                    onPressed: () {
                      Get.offAllNamed(AppRoutes.login);
                    },
                    child: const Text(
                      'Already have an account? Sign in',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Back button (only show if not on first page)
                  if (_currentPage > 0)
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton(
                        onPressed: () {
                          _pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.black,
                          side: const BorderSide(color: Colors.black),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Back',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlide(OnboardingSlide slide) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: slide.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(60),
            ),
            child: Icon(
              slide.icon,
              size: 60,
              color: slide.color,
            ),
          ),

          const SizedBox(height: 40),

          // Title
          Text(
            slide.title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          // Subtitle
          Text(
            slide.subtitle,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 24),

          // Description
          Text(
            slide.description,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator(int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: _currentPage == index ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: _currentPage == index ? Colors.black : Colors.grey[300],
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class OnboardingSlide {
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final Color color;

  OnboardingSlide({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.color,
  });
}
