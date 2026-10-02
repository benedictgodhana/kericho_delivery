import 'package:flutter/material.dart';
import 'package:kericho_delivery/presentation/router/app_router.dart';
import 'package:kericho_delivery/core/theme/app_theme.dart';
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
      title: 'One App, Every Kitchen',
      description: 'Discover restaurants, cafés, bakeries and cloud kitchens near you — all in a single marketplace.',
      assetImage: AppIcons.deliveryMan,
      color: Colors.white,
      subtitle: 'ONE MARKETPLACE, MANY VENDORS',
    ),
    OnboardingItem(
      title: 'Browse Before You Buy',
      description: 'Explore menus, prices and ratings instantly — no account needed until you\'re ready to order.',
      assetImage: AppIcons.shopping,
      color: Colors.white,
      subtitle: 'NO LOGIN REQUIRED',
    ),
    OnboardingItem(
      title: 'Easy M-Pesa Payments',
      description: 'Pay securely with M-Pesa, card or wallet. Cash on delivery also available for your convenience.',
      icon: Icons.phone_android,
      color: Colors.white,
      subtitle: 'SECURE & CONVENIENT',
    ),
    OnboardingItem(
      title: 'Real-Time Tracking',
      description: 'Track your order live on the map. Know exactly when your delivery arrives.',
      icon: Icons.location_on,
      color: Colors.white,
      subtitle: 'STAY INFORMED',
    ),
  ];

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
    return Scaffold(
      body: Stack(
        children: [
          // Background Image with enhanced overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                    'assets/images/fresh-vegetables-fruit-market-stall.jpg',
                  ),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.5),
                    BlendMode.darken,
                  ),
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.2),
                      Colors.black.withOpacity(0.6),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          // Content
          SafeArea(
            child: Column(
              children: [
                // Logo + Skip Button
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Image.asset(
                          'assets/images/KulaHub_logo-removebg-preview.png',
                          height: 64,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: TextButton(
                          onPressed: _continueAsGuest,
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                          child: Text(
                            'SKIP',
                            style: GoogleFonts.afacad(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Carousel
                Expanded(
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

                // Bottom Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
                              color: _currentPage == index ? AppTheme.primaryColor : Colors.white.withOpacity(0.7),
                              boxShadow: _currentPage == index ? [
                                BoxShadow(
                                  color: AppTheme.primaryColor.withOpacity(0.5),
                                  blurRadius: 12,
                                  spreadRadius: 2,
                                ),
                              ] : null,
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
                              _continueAsGuest();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                            elevation: 12,
                            shadowColor: AppTheme.primaryColor.withOpacity(0.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _currentPage < _onboardingItems.length - 1 ? 'CONTINUE' : 'START BROWSING',
                                style: GoogleFonts.afacad(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.0,
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
                                      child: const Icon(
                                        Icons.arrow_forward_rounded,
                                        size: 22,
                                      ),
                                    );
                                  },
                                ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Sign in prompt
                      if (_currentPage == _onboardingItems.length - 1)
                        Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Already have an account? ',
                                style: GoogleFonts.afacad(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              GestureDetector(
                                onTap: _goToLogin,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: Colors.white,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                  child: Text(
                                    'SIGN IN',
                                    style: GoogleFonts.afacad(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOnboardingPage(OnboardingItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
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
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(75),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.4),
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 25,
                          spreadRadius: 5,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: item.assetImage != null
                              ? Image.asset(
                                  item.assetImage!,
                                  width: 75,
                                  height: 75,
                                  fit: BoxFit.contain,
                                )
                              : Icon(
                                  item.icon!,
                                  size: 75,
                                  color: Colors.white,
                                ),
                        ),
                        // Glow effect
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(75),
                              gradient: RadialGradient(
                                center: Alignment.center,
                                radius: 0.8,
                                colors: [
                                  Colors.white.withOpacity(0.2),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 48),

          // Subtitle
          Text(
            item.subtitle,
            style: GoogleFonts.afacad(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppTheme.primaryColor,
              letterSpacing: 3.0,
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Title
          Text(
            item.title,
            textAlign: TextAlign.center,
            style: GoogleFonts.afacad(
              fontSize: 36,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              height: 1.1,
              letterSpacing: -0.5,
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.7),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Description
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              item.description,
              textAlign: TextAlign.center,
              style: GoogleFonts.afacad(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white.withOpacity(0.95),
                height: 1.6,
                letterSpacing: 0.3,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.4),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _goToLogin() {
    AppRouter.pushReplacementNamed(AppRouter.login);
  }

  // Browsing restaurants and menus never requires an account — only checkout does.
  void _continueAsGuest() {
    AppRouter.pushReplacementNamed(AppRouter.home);
  }
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