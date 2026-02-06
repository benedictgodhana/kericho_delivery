import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kericho_delivery/presentation/router/app_router.dart';
import 'package:kericho_delivery/core/theme/app_theme.dart';
import 'package:kericho_delivery/core/constants/app_icons.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _iconAnimation;

  // Colors matching the login screen
  static const Color kPrimaryColor = Color(0xFF0F766E);
  static const Color kPrimaryDark = Color(0xFF0F172A);
  static const Color kBackgroundColor = Color(0xFFF8FAFC);
  static const Color kCardColor = Colors.white;
  static const Color kTextPrimary = Color(0xFF0F172A);
  static const Color kTextSecondary = Color(0xFF64748B);

  @override
  void initState() {
    super.initState();
    _initAnimation();
    _navigateToNextScreen();
  }

  void _initAnimation() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.8, curve: Curves.easeInOut),
      ),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 1.0, curve: Curves.elasticOut),
      ),
    );
    
    _iconAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeInOut),
      ),
    );
    
    _controller.forward();
  }

  void _navigateToNextScreen() async {
    await Future.delayed(const Duration(seconds: 3));
    AppRouter.pushReplacementNamed(AppRouter.onboarding);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: Stack(
        children: [
          // Curved Header Section
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ClipPath(
              clipper: SplashHeaderCurveClipper(),
              child: Container(
                height: screenHeight * 0.5,
                decoration: BoxDecoration(
                  color: kPrimaryDark,
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Background Image
                    _buildBackgroundImage(),
                    
                    // Content
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(height: 40),
                            
                            // App Icon/Logo with animation
                            AnimatedBuilder(
                              animation: _iconAnimation,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: 0.8 + (_iconAnimation.value * 0.4),
                                  child: Container(
                                    width: 100,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.3),
                                          blurRadius: 30,
                                          spreadRadius: 3,
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Icon(
                                        Icons.shopping_bag_rounded,
                                        size: 50,
                                        color: kPrimaryColor,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // App Title with responsive font
                            Container(
                              constraints: BoxConstraints(maxWidth: screenWidth * 0.8),
                              child: AnimatedBuilder(
                                animation: _fadeAnimation,
                                builder: (context, child) {
                                  return Opacity(
                                    opacity: _fadeAnimation.value,
                                    child: Text(
                                      'Kericho Delivery',
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.afacad(
                                        fontSize: screenWidth * 0.1, // Responsive font size
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                        letterSpacing: -0.5,
                                        shadows: [
                                          Shadow(
                                            color: Colors.black.withOpacity(0.4),
                                            blurRadius: 15,
                                            offset: const Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            
                            const SizedBox(height: 12),
                            
                            // Tagline
                            AnimatedBuilder(
                              animation: _fadeAnimation,
                              builder: (context, child) {
                                return Opacity(
                                  opacity: _fadeAnimation.value,
                                  child: Text(
                                    'Order from your favorite stores',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.afacad(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white.withOpacity(0.9),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Main Content Area
          Positioned(
            top: screenHeight * 0.45,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              color: kBackgroundColor,
              child: Center(
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, 20 - (_fadeAnimation.value * 20)),
                      child: Opacity(
                        opacity: _fadeAnimation.value,
                        child: Transform.scale(
                          scale: _scaleAnimation.value,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Main Highlight Text
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 20),
                                  child: Column(
                                    children: [
                                      Text(
                                        'Fresh Pizza & Delicious Food',
                                        style: GoogleFonts.afacad(
                                          fontSize: 32,
                                          fontWeight: FontWeight.w800,
                                          color: kTextPrimary,
                                          height: 1.1,
                                          letterSpacing: -0.5,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      
                                      const SizedBox(height: 12),
                                      
                                      Text(
                                        'Delivered Fast with',
                                        style: GoogleFonts.afacad(
                                          fontSize: 22,
                                          fontWeight: FontWeight.w500,
                                          color: kTextSecondary,
                                          letterSpacing: -0.3,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      
                                      Text(
                                        'Just One Click!',
                                        style: GoogleFonts.afacad(
                                          fontSize: 24,
                                          fontWeight: FontWeight.w700,
                                          color: kPrimaryColor,
                                          letterSpacing: -0.3,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                                
                                const SizedBox(height: 40),
                                
                                // Description
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 20),
                                  child: Column(
                                    children: [
                                      Text(
                                        'Your Ultimate App for',
                                        style: GoogleFonts.afacad(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400,
                                          color: kTextSecondary,
                                          letterSpacing: 0.5,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Every Craving',
                                        style: GoogleFonts.afacad(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: kTextPrimary,
                                          letterSpacing: 0.5,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                                
                                const SizedBox(height: 12),
                                
                                Text(
                                  'Any Food, Anytime.',
                                  style: GoogleFonts.afacad(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                    color: kTextSecondary,
                                    fontStyle: FontStyle.italic,
                                    letterSpacing: 0.5,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                
                                const SizedBox(height: 60),
                                
                                // Get Started Button
                                ScaleTransition(
                                  scale: CurvedAnimation(
                                    parent: _controller,
                                    curve: const Interval(0.6, 1.0, curve: Curves.elasticOut),
                                  ),
                                  child: SizedBox(
                                    width: 240,
                                    height: 60,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        AppRouter.pushReplacementNamed(AppRouter.onboarding);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: kPrimaryColor,
                                        foregroundColor: Colors.white,
                                        elevation: 8,
                                        shadowColor: kPrimaryColor.withOpacity(0.4),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20), // More rounded
                                        ),
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Get Started',
                                            style: GoogleFonts.afacad(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w800,
                                              color: Colors.white,
                                              letterSpacing: 0.5,
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
                                
                                const SizedBox(height: 40),
                                
                                // Loading indicator
                                Column(
                                  children: [
                                    SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          kPrimaryColor,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Preparing your experience...',
                                      style: GoogleFonts.afacad(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                        color: kTextSecondary,
                                        letterSpacing: 0.3,
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundImage() {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                'assets/images/top-view-table-full-delicious-food-composition.jpg',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [kPrimaryColor, const Color(0xFF0D9488)],
                    ),
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.3),
                      Colors.transparent,
                      Colors.black.withOpacity(0.5),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class SplashHeaderCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 80);

    final firstControlPoint = Offset(size.width * 0.25, size.height);
    final firstEndPoint = Offset(size.width * 0.5, size.height - 60);
    path.quadraticBezierTo(
      firstControlPoint.dx,
      firstControlPoint.dy,
      firstEndPoint.dx,
      firstEndPoint.dy,
    );

    final secondControlPoint = Offset(size.width * 0.75, size.height - 120);
    final secondEndPoint = Offset(size.width, size.height - 80);
    path.quadraticBezierTo(
      secondControlPoint.dx,
      secondControlPoint.dy,
      secondEndPoint.dx,
      secondEndPoint.dy,
    );

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}