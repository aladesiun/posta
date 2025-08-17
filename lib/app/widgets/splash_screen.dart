import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:posta/app/routes.dart';
import 'package:posta/app/controllers/auth_controller.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 0.8, curve: Curves.elasticOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.3, 0.8, curve: Curves.easeOut),
    ));

    _animationController.forward();

    // Wait for authentication check to complete, then navigate
    _waitForAuthAndNavigate();
  }

  Future<void> _waitForAuthAndNavigate() async {
    // Wait for the animation to complete
    await Future.delayed(const Duration(milliseconds: 3000));

    if (!mounted) return;

    // Wait a bit more for all services to be initialized
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    try {
      final authController = Get.find<AuthController>();

      // Wait for authentication state to be initialized
      while (!authController.isInitialized.value) {
        await Future.delayed(const Duration(milliseconds: 100));
        if (!mounted) return;
      }

      // Navigate based on authentication state
      if (authController.isAuthenticated.value) {
        Get.offAllNamed(AppRoutes.feed);
      } else {
        Get.offAllNamed(AppRoutes.onboarding);
      }
    } catch (e) {
      print('Error finding AuthController: $e');
      // Fallback to onboarding if AuthController is not available
      Get.offAllNamed(AppRoutes.onboarding);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Speech bubble icon
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black, width: 3),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Stack(
                          children: [
                            // Speech bubble tail
                            Positioned(
                              left: 20,
                              bottom: -15,
                              child: CustomPaint(
                                size: const Size(30, 30),
                                painter: SpeechBubbleTailPainter(),
                              ),
                            ),
                            // Center dot representing openness
                            Center(
                              child: Container(
                                width: 24,
                                height: 24,
                                decoration: const BoxDecoration(
                                  color: Colors.black,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                      // Posta text
                      const Text(
                        'POSTA',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          letterSpacing: 2.0,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Tagline
                      const Text(
                        'Share openly, connect freely',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 40),
                      // Loading indicator
                      const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class SpeechBubbleTailPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width / 2, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
