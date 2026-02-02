import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kericho_delivery/presentation/router/app_router.dart';
import 'package:kericho_delivery/core/theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _imageOpacityAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimation();
    _navigateToNextScreen();
  }

  void _initAnimation() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.8, curve: Curves.easeInOut),
      ),
    );
    
    _slideAnimation = Tween<double>(begin: 60.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
      ),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 1.0, curve: Curves.elasticOut),
      ),
    );
    
    _imageOpacityAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );
    
    _controller.forward();
  }

  void _navigateToNextScreen() async {
    await Future.delayed(const Duration(seconds: 4));
    AppRouter.pushReplacementNamed(AppRouter.onboarding);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image with overlay
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _imageOpacityAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: _imageOpacityAnimation.value,
                  child: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(
                          'assets/images/top-view-table-full-delicious-food-composition.jpg',
                        ),
                        fit: BoxFit.cover,
                        colorFilter: ColorFilter.mode(
                          Colors.black.withOpacity(0.6),
                          BlendMode.darken,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Gradient overlay for better text readability
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.4),
                    Colors.black.withOpacity(0.6),
                    Colors.black.withOpacity(0.8),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),

          Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _slideAnimation.value),
                  child: Opacity(
                    opacity: _fadeAnimation.value,
                    child: Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Pizza Icon with delivery effect
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(60),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 20,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: Stack(
                                children: [
                                  Center(
                                    child: Icon(
                                      Icons.local_pizza,
                                      size: 70,
                                      color: AppTheme.primaryColor,
                                    ),
                                  ),
                                  // Delivery effect
                                  Positioned(
                                    bottom: 12,
                                    right: 12,
                                    child: Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        color: AppTheme.secondaryColor,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppTheme.secondaryColor.withOpacity(0.5),
                                            blurRadius: 8,
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.delivery_dining,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            const SizedBox(height: 40),
                            
                            // Main Title
                            Text(
                              'Fresh Pizza',
                              style: GoogleFonts.lexend(
                                fontSize: 48,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                height: 1.1,
                                letterSpacing: -0.5,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.5),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.center,
                            ),
                            
                            const SizedBox(height: 8),
                            
                            // Subtitle 1
                            Text(
                              'Delivered Fast with',
                              style: GoogleFonts.lexend(
                                fontSize: 28,
                                fontWeight: FontWeight.w400,
                                color: Colors.white.withOpacity(0.9),
                                letterSpacing: -0.3,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 5,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.center,
                            ),
                            
                            // Subtitle 2 with accent color
                            Text(
                              'Just One Click!',
                              style: GoogleFonts.lexend(
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.primaryColor,
                                letterSpacing: -0.3,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.5),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.center,
                            ),
                            
                            const SizedBox(height: 30),
                            
                            // Description
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Column(
                                children: [
                                  Text(
                                    'Your Ultimate App for',
                                    style: GoogleFonts.lexend(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w300,
                                      color: Colors.white.withOpacity(0.8),
                                      letterSpacing: 0.8,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Every Craving',
                                    style: GoogleFonts.lexend(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                      letterSpacing: 0.8,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                            
                            const SizedBox(height: 8),
                            
                            Text(
                              'Any Pizza, Anytime.',
                              style: GoogleFonts.lexend(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: Colors.white.withOpacity(0.8),
                                fontStyle: FontStyle.italic,
                                letterSpacing: 0.8,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            
                            const SizedBox(height: 50),
                            
                            // "Get Started" button
                            ScaleTransition(
                              scale: CurvedAnimation(
                                parent: _controller,
                                curve: const Interval(0.6, 1.0, curve: Curves.elasticOut),
                              ),
                              child: Container(
                                width: 220,
                                height: 60,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppTheme.primaryColor.withOpacity(0.9),
                                      AppTheme.secondaryColor.withOpacity(0.9),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(30),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.primaryColor.withOpacity(0.5),
                                      blurRadius: 20,
                                      spreadRadius: 3,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(30),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(30),
                                    onTap: () {
                                      AppRouter.pushReplacementNamed(AppRouter.onboarding);
                                    },
                                    child: Center(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Get Started',
                                            style: GoogleFonts.lexend(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white,
                                              letterSpacing: 1.2,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          const Icon(
                                            Icons.arrow_forward_rounded,
                                            color: Colors.white,
                                            size: 22,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            
                            const SizedBox(height: 40),
                            
                            // Loading indicator
                            Column(
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white.withOpacity(0.8),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Preparing your pizza experience...',
                                  style: GoogleFonts.lexend(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w300,
                                    color: Colors.white.withOpacity(0.7),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}