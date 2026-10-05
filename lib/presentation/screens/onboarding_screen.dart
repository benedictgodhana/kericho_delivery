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
      description:
          'Discover restaurants, cafés, bakeries and cloud kitchens near you — all in a single marketplace.',
      assetImage: AppIcons.deliveryMan,
      color: Colors.white,
      subtitle: 'ONE MARKETPLACE, MANY VENDORS',
    ),
    OnboardingItem(
      title: 'Browse Before You Buy',
      description:
          'Explore menus, prices and ratings instantly — no account needed until you\'re ready to order.',
      assetImage: AppIcons.shopping,
      color: Colors.white,
      subtitle: 'NO LOGIN REQUIRED',
    ),
    OnboardingItem(
      title: 'Easy M-Pesa Payments',
      description:
          'Pay securely with M-Pesa, card or wallet. Cash on delivery also available for your convenience.',
      icon: Icons.phone_android,
      color: Colors.white,
      subtitle: 'SECURE & CONVENIENT',
    ),
    OnboardingItem(
      title: 'Real-Time Tracking',
      description:
          'Track your order live on the map. Know exactly when your delivery arrives.',
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
          // Background Image with a simple dark scrim
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                    'assets/images/fresh-vegetables-fruit-market-stall.jpg',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.35),
                      Colors.black.withOpacity(0.75),
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
                      Image.asset(
                        'assets/LOGO/logo.png',
                        height: 64,
                        fit: BoxFit.contain,
                      ),
                      const Spacer(),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: TextButton(
                          onPressed: _continueAsGuest,
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Column(
                    children: [
                      // Page Indicators
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _onboardingItems.length,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 400),
                            width: _currentPage == index ? 28 : 8,
                            height: 8,
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color: _currentPage == index
                                  ? AppTheme.primaryColor
                                  : Colors.white.withOpacity(0.4),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Next / Get Started Button
                      SizedBox(
                        width: double.infinity,
                        child: GestureDetector(
                          onTap: () {
                            if (_currentPage < _onboardingItems.length - 1) {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 600),
                                curve: Curves.easeInOutCubic,
                              );
                            } else {
                              _continueAsGuest();
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 17),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor,
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      AppTheme.primaryColor.withOpacity(0.35),
                                  blurRadius: 14,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _currentPage < _onboardingItems.length - 1
                                      ? 'Continue'
                                      : 'Start Browsing',
                                  style: GoogleFonts.afacad(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                if (_currentPage <
                                    _onboardingItems.length - 1) ...[
                                  const SizedBox(width: 8),
                                  AnimatedBuilder(
                                    animation: _iconController,
                                    builder: (context, child) {
                                      return Transform.translate(
                                        offset: Offset(
                                            _iconController.value * 8, 0),
                                        child: const Icon(
                                          Icons.arrow_forward_rounded,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Sign in prompt
                      if (_currentPage == _onboardingItems.length - 1)
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Already have an account? ',
                                style: GoogleFonts.afacad(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 14,
                                ),
                              ),
                              GestureDetector(
                                onTap: _goToLogin,
                                child: Text(
                                  'Sign In',
                                  style: GoogleFonts.afacad(
                                    color: AppTheme.primaryColor,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
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
          // Animated Icon Badge
          AnimatedBuilder(
            animation: _iconAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: 0.85 + (_iconAnimation.value * 0.15),
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Center(
                    child: item.assetImage != null
                        ? Image.asset(
                            item.assetImage!,
                            width: 60,
                            height: 60,
                            fit: BoxFit.contain,
                          )
                        : Icon(
                            item.icon!,
                            size: 56,
                            color: AppTheme.primaryColor,
                          ),
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 36),

          // Subtitle badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.18),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              item.subtitle,
              style: GoogleFonts.afacad(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: AppTheme.primaryColor,
                letterSpacing: 0.5,
              ),
            ),
          ),

          const SizedBox(height: 18),

          // Title
          Text(
            item.title,
            textAlign: TextAlign.center,
            style: GoogleFonts.afacad(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1.15,
            ),
          ),

          const SizedBox(height: 14),

          // Description
          Text(
            item.description,
            textAlign: TextAlign.center,
            style: GoogleFonts.afacad(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.white.withOpacity(0.85),
              height: 1.5,
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
