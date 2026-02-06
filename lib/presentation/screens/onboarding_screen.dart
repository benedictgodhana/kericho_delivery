import 'package:flutter/material.dart';
import 'package:kericho_delivery/presentation/router/app_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kericho_delivery/core/constants/app_icons.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late AnimationController _iconController;
  late Animation<double> _iconAnimation;

  final List<OnboardingItem> _onboardingItems = [
    OnboardingItem(
      title: 'Fast Delivery in Kericho',
      description:
          'Get your favorite food, groceries, and more delivered to your doorstep in minutes.',
      assetImage: AppIcons.deliveryMan,
      color: Colors.white,
      subtitle: 'QUICK & RELIABLE',
    ),
    OnboardingItem(
      title: 'Wide Variety of Stores',
      description:
          'Choose from restaurants, supermarkets, pharmacies, and local shops across Kericho.',
      assetImage: AppIcons.shopping,
      color: Colors.white,
      subtitle: 'ENDLESS CHOICES',
    ),
    OnboardingItem(
      title: 'Easy M-Pesa Payments',
      description:
          'Pay securely with M-Pesa. Cash on delivery also available for your convenience.',
      assetImage: 'assets/icons/money.png',
      color: Colors.white,
      subtitle: 'SECURE & CONVENIENT',
    ),
    OnboardingItem(
      title: 'Real-Time Tracking',
      description:
          'Track your order live on the map. Know exactly when your delivery arrives.',
      assetImage: 'assets/icons/track.png',
      color: Colors.white,
      subtitle: 'STAY INFORMED',
    ),
  ];

  // Colors matching the login screen
  static const Color kPrimaryColor = Color(0xFF0F766E);
  static const Color kPrimaryDark = Color(0xFF0F172A);
  static const Color kBackgroundColor = Color(0xFFF8FAFC);
  static const Color kCardColor = Colors.white;
  static const Color kTextPrimary = Color(0xFF0F172A);
  static const Color kTextSecondary = Color(0xFF64748B);
  static const Color kBorderColor = Color(0xFFE2E8F0);

  @override
  void initState() {
    super.initState();
    _iconController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _iconAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _iconController,
        curve: Curves.elasticOut,
      ),
    );
    _iconController.forward();

    _pageController.addListener(() {
      if (_pageController.page?.round() != _currentPage) {
        _iconController.reset();
        _iconController.forward();
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _iconController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: Column(
        children: [
          // Curved header section
          SizedBox(
            height: screenHeight * 0.45,
            child: Stack(
              children: [
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: ClipPath(
                    clipper: OnboardingHeaderCurveClipper(),
                    child: Container(
                      height: screenHeight * 0.45,
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
                            bottom: false,
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 24),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const SizedBox(height: 20),

                                  // Skip Button (top right)
                                  Align(
                                    alignment: Alignment.topRight,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: Colors.white.withOpacity(0.3),
                                          width: 1,
                                        ),
                                      ),
                                      child: TextButton(
                                        onPressed: _goToLogin,
                                        style: TextButton.styleFrom(
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 20, vertical: 10),
                                        ),
                                        child: Text(
                                          'SKIP',
                                          style: GoogleFonts.afacad(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 1.0,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 20),

                                  // App Icon/Logo
                                  Container(
                                    width: 70,
                                    height: 70,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          blurRadius: 20,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Icon(
                                        Icons.shopping_bag_rounded,
                                        size: 36,
                                        color: kPrimaryColor,
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 16),

                                  // Centered Title
                                  Container(
                                    constraints: BoxConstraints(
                                        maxWidth: screenWidth * 0.8),
                                    child: Text(
                                      'Kericho Delivery',
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.afacad(
                                        fontSize: screenWidth *
                                            0.09, // Responsive font size
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                        letterSpacing: -0.5,
                                        shadows: [
                                          Shadow(
                                            color:
                                                Colors.black.withOpacity(0.3),
                                            blurRadius: 10,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 8),

                                  // Tagline
                                  Text(
                                    'Order from your favorite stores',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.afacad(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white.withOpacity(0.9),
                                    ),
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
              ],
            ),
          ),

          // Content area with proper constraints
          Expanded(
            child: Container(
              color: kBackgroundColor,
              child: Column(
                children: [
                  // Page content area
                  Expanded(
                    flex: 3,
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: _onboardingItems.length,
                      onPageChanged: (index) {
                        setState(() => _currentPage = index);
                      },
                      itemBuilder: (context, index) {
                        return _buildOnboardingPage(_onboardingItems[index]);
                      },
                    ),
                  ),

                  // Bottom controls section
                  _buildBottomControls(screenWidth),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundImage() {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          'assets/images/fresh-vegetables-fruit-market-stall.jpg',
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
    );
  }

  Widget _buildOnboardingPage(OnboardingItem item) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated Icon/Asset Container
            AnimatedBuilder(
              animation: _iconAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: 0.8 + (_iconAnimation.value * 0.4),
                  child: Transform.rotate(
                    angle: _iconAnimation.value * 0.1,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: kPrimaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(60),
                        border: Border.all(
                          color: kPrimaryColor.withOpacity(0.4),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: kPrimaryColor.withOpacity(0.2),
                            blurRadius: 15,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          Center(
                            child: item.assetImage != null
                                ? Image.asset(
                                    item.assetImage!,
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.contain,
                                    color: kPrimaryColor,
                                  )
                                : Icon(
                                    item.icon!,
                                    size: 60,
                                    color: kPrimaryColor,
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 30),

            // Subtitle
            Text(
              item.subtitle,
              style: GoogleFonts.afacad(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: kPrimaryColor,
                letterSpacing: 1.5,
              ),
            ),

            const SizedBox(height: 15),

            // Title
            Text(
              item.title,
              textAlign: TextAlign.center,
              style: GoogleFonts.afacad(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: kTextPrimary,
                height: 1.2,
                letterSpacing: -0.5,
              ),
            ),

            const SizedBox(height: 15),

            // Description
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                item.description,
                textAlign: TextAlign.center,
                style: GoogleFonts.afacad(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: kTextSecondary,
                  height: 1.5,
                  letterSpacing: 0.1,
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomControls(double screenWidth) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        children: [
          // Page Indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _onboardingItems.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                width: _currentPage == index ? 32 : 10,
                height: 10,
                margin: const EdgeInsets.symmetric(horizontal: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: _currentPage == index
                      ? kPrimaryColor
                      : kTextSecondary.withOpacity(0.3),
                  boxShadow: _currentPage == index
                      ? [
                          BoxShadow(
                            color: kPrimaryColor.withOpacity(0.3),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ]
                      : null,
                ),
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Next / Get Started Button
          SizedBox(
            width: double.infinity,
            height: 58,
            child: ElevatedButton(
              onPressed: () {
                if (_currentPage < _onboardingItems.length - 1) {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeInOutCubic,
                  );
                } else {
                  _goToLogin();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor,
                foregroundColor: Colors.white,
                elevation: 4,
                shadowColor: kPrimaryColor.withOpacity(0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _currentPage < _onboardingItems.length - 1
                        ? 'CONTINUE'
                        : 'GET STARTED NOW',
                    style: GoogleFonts.afacad(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                  if (_currentPage < _onboardingItems.length - 1)
                    const SizedBox(width: 12),
                  if (_currentPage < _onboardingItems.length - 1)
                    AnimatedBuilder(
                      animation: _iconController,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(_iconController.value * 10, 0),
                          child: Image.asset(
                            'assets/icons/continuous.png',
                            width: 26,
                            height: 26,
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Sign in prompt (only on last page)
          if (_currentPage == _onboardingItems.length - 1)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account? ',
                    style: GoogleFonts.afacad(
                      color: kTextSecondary,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  GestureDetector(
                    onTap: _goToLogin,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: kPrimaryColor,
                            width: 2,
                          ),
                        ),
                      ),
                      child: Text(
                        'SIGN IN',
                        style: GoogleFonts.afacad(
                          color: kPrimaryColor,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 10),
        ],
      ),
    );
  }

  void _goToLogin() {
    AppRouter.pushReplacementNamed(AppRouter.login);
  }
}

class OnboardingHeaderCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 60);

    final firstControlPoint = Offset(size.width * 0.25, size.height);
    final firstEndPoint = Offset(size.width * 0.5, size.height - 40);
    path.quadraticBezierTo(
      firstControlPoint.dx,
      firstControlPoint.dy,
      firstEndPoint.dx,
      firstEndPoint.dy,
    );

    final secondControlPoint = Offset(size.width * 0.75, size.height - 80);
    final secondEndPoint = Offset(size.width, size.height - 60);
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

class OnboardingItem {
  final String title;
  final String description;
  final String? assetImage;
  final IconData? icon;
  final Color color;
  final String subtitle;

  OnboardingItem({
    required this.title,
    required this.description,
    this.assetImage,
    this.icon,
    required this.color,
    required this.subtitle,
  });
}
