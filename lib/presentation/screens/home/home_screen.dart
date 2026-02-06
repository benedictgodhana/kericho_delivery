  import 'dart:async';
  import 'package:flutter/cupertino.dart';
  import 'package:flutter/material.dart';
  import 'package:flutter/services.dart';
  import 'package:kericho_delivery/data/models/merchant_model.dart';
  import 'package:kericho_delivery/presentation/providers/app_provider.dart';
  import 'package:kericho_delivery/presentation/providers/location_provider.dart';
  import 'package:kericho_delivery/presentation/providers/merchant_provider.dart';
  import 'package:kericho_delivery/presentation/router/app_router.dart';
  import 'package:kericho_delivery/presentation/screens/explore/explore_screen.dart';
  import 'package:kericho_delivery/presentation/screens/favorites/favorites_screen.dart';
  import 'package:kericho_delivery/presentation/screens/profile/profile_screen.dart';
  import 'package:kericho_delivery/core/theme/app_theme.dart';
  import 'package:provider/provider.dart';
  import 'package:cached_network_image/cached_network_image.dart';
  import 'package:google_fonts/google_fonts.dart';
  import 'package:cupertino_icons/cupertino_icons.dart';
  import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';

  class HomeScreen extends StatefulWidget {
    const HomeScreen({super.key});

    @override
    State<HomeScreen> createState() => _HomeScreenState();
  }

  class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
    int _selectedCategoryIndex = 0;
    final ScrollController _scrollController = ScrollController();
    bool _showSearchBar = false;
    String _searchQuery = '';
    final TextEditingController _searchController = TextEditingController();
    Timer? _searchDebounceTimer;
    double _scrollOffset = 0.0;
    bool _isSearchActive = false;

    // Bottom navigation index (0=Home, 1=Explore, 2=Cart, 3=Favorites, 4=Profile)
    int _bottomNavIndex = 0;

    // Icons list for bottom navigation (no placeholder for FAB)
    // If using gapLocation: GapLocation.center, icon count must be even
    final List<IconData> _bottomNavIcons = [
      CupertinoIcons.house_fill,
      CupertinoIcons.compass_fill,
      CupertinoIcons.cart_fill,
      CupertinoIcons.heart_fill,
    ];

    late AnimationController _fadeController;
    late Animation<double> _fadeAnimation;

    // Enhanced color palette
    static const Color kPrimaryColor = Color(0xFF0F766E);
    static const Color kPrimaryDark = Color(0xFF0D9488);
    static const Color kBackgroundColor = Color(0xFFF8FAFC);
    static const Color kCardColor = Colors.white;
    static const Color kTextPrimary = Color(0xFF0F172A);
    static const Color kTextSecondary = Color(0xFF64748B);
    static const Color kBorderColor = Color(0xFFE2E8F0);
    static const Color kSuccessColor = Color(0xFF10B981);
    static const Color kWarningColor = Color(0xFFF59E0B);
    static const Color kErrorColor = Color(0xFFEF4444);
    static const Color kInfoColor = Color(0xFF3B82F6);
    static const Color kOverlayWhite = Color(0x1AFFFFFF);
    static const Color kGradientStart = Color(0xFF0F766E);
    static const Color kGradientEnd = Color(0xFF115E59);
    static const Color kSurfaceLight = Color(0xFFF1F5F9);
    static const Color kSurfaceDark = Color(0xFF1E293B);
    static const Color kAccentColor = Color(0xFFFBBF24);

    final List<Map<String, dynamic>> _categories = [
      {'emoji': '🍽️', 'label': 'All', 'tag': 'All', 'icon': CupertinoIcons.grid},
      {
        'emoji': '🍔',
        'label': 'Fast Food',
        'tag': 'FastFood',
        'icon': CupertinoIcons.bag
      },
      {
        'emoji': '🛒',
        'label': 'Groceries',
        'tag': 'Grocery',
        'icon': CupertinoIcons.cart
      },
      {
        'emoji': '☕',
        'label': 'Coffee',
        'tag': 'Cafe',
        'icon': CupertinoIcons.mic
      },
      {
        'emoji': '🍕',
        'label': 'Restaurant',
        'tag': 'Restaurant',
        'icon': CupertinoIcons.house
      },
      {
        'emoji': '💊',
        'label': 'Pharmacy',
        'tag': 'Pharmacy',
        'icon': CupertinoIcons.plus
      },
      {
        'emoji': '🍰',
        'label': 'Bakery',
        'tag': 'Bakery',
        'icon': CupertinoIcons.bag
      },
      {
        'emoji': '🍦',
        'label': 'Desserts',
        'tag': 'Dessert',
        'icon': CupertinoIcons.cube_box
      },
    ];

    // Animation for cart button
    double _cartButtonScale = 1.0;

    @override
    void initState() {
      super.initState();
      _fadeController = AnimationController(
        duration: const Duration(milliseconds: 300),
        vsync: this,
      );
      _fadeAnimation =
          Tween<double>(begin: 1.0, end: 0.0).animate(CurvedAnimation(
        parent: _fadeController,
        curve: Curves.easeInOutCubic,
      ));
      _scrollController.addListener(_onScroll);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _initializeData();
      });
    }

    @override
    void dispose() {
      _scrollController.dispose();
      _searchController.dispose();
      _searchDebounceTimer?.cancel();
      _fadeController.dispose();
      super.dispose();
    }

    Future<void> _initializeData() async {
      final locationProvider = context.read<LocationProvider>();
      if (locationProvider.currentLocation == null) {
        await locationProvider.getCurrentLocation();
      }
    }

    void _onScroll() {
      final offset = _scrollController.offset;
      setState(() => _scrollOffset = offset);
      if (offset > 100 && !_showSearchBar) {
        setState(() => _showSearchBar = true);
        _fadeController.reverse();
      } else if (offset <= 100 && _showSearchBar) {
        setState(() => _showSearchBar = false);
        _fadeController.forward();
      }
    }

    void _handleCategorySelected(int index) {
      setState(() => _selectedCategoryIndex = index);
      HapticFeedback.lightImpact();
      final category = _categories[index];
      final merchantProvider = context.read<MerchantProvider>();
      if (category['tag'] == 'All') {
        merchantProvider.clearCategory();
      } else {
        merchantProvider.filterByCategory(category['tag']);
      }
    }

    void _handleSearchChanged(String query) {
      setState(() => _searchQuery = query);
      _searchDebounceTimer?.cancel();
      _searchDebounceTimer = Timer(const Duration(milliseconds: 500), () {
        if (_searchQuery == query && mounted) {
          context.read<MerchantProvider>().searchMerchants(query);
        }
      });
    }

    void _toggleSearch() {
      HapticFeedback.lightImpact();
      setState(() {
        _isSearchActive = !_isSearchActive;
        if (!_isSearchActive) {
          _searchController.clear();
          _handleSearchChanged('');
          FocusScope.of(context).unfocus();
        } else {
          Future.delayed(const Duration(milliseconds: 300), () {
            FocusScope.of(context).requestFocus(FocusNode());
          });
        }
      });
    }

    void _navigateToMerchant(String merchantId, String merchantName) {
      HapticFeedback.mediumImpact();
      AppRouter.pushNamed(
        AppRouter.merchant,
        arguments: {'merchantId': merchantId, 'merchantName': merchantName},
      );
    }

    void _navigateToCart() {
      HapticFeedback.mediumImpact();
      AppRouter.pushNamed(AppRouter.cart);
    }

    void _navigateToNotifications() {
      HapticFeedback.lightImpact();
      AppRouter.pushNamed('notifications');
    }

    void _navigateToExplore() {
      HapticFeedback.lightImpact();
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ExploreScreen()),
      );
    }

    void _navigateToFavorites() {
      HapticFeedback.lightImpact();
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const FavoritesScreen()),
      );
    }

    void _navigateToProfile() {
      HapticFeedback.lightImpact();
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ProfileScreen()),
      );
    }

    Future<void> _refreshLocation() async {
      HapticFeedback.lightImpact();
      try {
        await context.read<LocationProvider>().getCurrentLocation();
        if (mounted) {
          _showSuccessSnackbar('Location updated successfully!');
        }
      } catch (e) {
        if (mounted) {
          _showErrorSnackbar('Failed to update location');
        }
      }
    }

    void _showSuccessSnackbar(String message) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(CupertinoIcons.checkmark_circle_fill, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: GoogleFonts.afacad(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: kSuccessColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 2),
          elevation: 6,
        ),
      );
    }

    void _showErrorSnackbar(String message) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(CupertinoIcons.exclamationmark_circle_fill,
                  color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: GoogleFonts.afacad(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: kErrorColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 2),
          elevation: 6,
        ),
      );
    }

    void _onBottomNavTapped(int index) {
      HapticFeedback.lightImpact();

      if (index == 2) {
        // Cart – only triggered by FAB (no icon in bar at index 2)
        _navigateToCart();
        return;
      }

      setState(() {
        _bottomNavIndex = index;
      });

      switch (index) {
        case 0: // Home
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOutCubic,
          );
          break;
        case 1: // Explore
          _navigateToExplore();
          break;
        case 3: // Favorites
          _navigateToFavorites();
          break;
        case 4: // Profile
          _navigateToProfile();
          break;
      }
    }

    void _animateCartButton() {
      setState(() => _cartButtonScale = 0.92);
      Future.delayed(const Duration(milliseconds: 120), () {
        if (mounted) setState(() => _cartButtonScale = 1.0);
      });
    }

    Widget _buildHomeContent() {
      return Consumer3<LocationProvider, AppProvider, MerchantProvider>(
        builder:
            (context, locationProvider, appProvider, merchantProvider, child) {
          return Stack(
            children: [
              Column(
                children: [
                  SizedBox(height: _isSearchActive ? 140 : 220),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () async {
                        await _refreshLocation();
                        merchantProvider.loadMerchants();
                      },
                      color: kPrimaryColor,
                      backgroundColor: Colors.white,
                      strokeWidth: 3,
                      edgeOffset: 60,
                      displacement: 40,
                      child: CustomScrollView(
                        controller: _scrollController,
                        physics: const BouncingScrollPhysics(
                          parent: AlwaysScrollableScrollPhysics(),
                        ),
                        slivers: [
                          SliverToBoxAdapter(
                            child: _buildCategoriesSection(),
                          ),
                          if (merchantProvider.getFeaturedMerchants().isNotEmpty)
                            SliverToBoxAdapter(
                              child: _buildFeaturedSection(merchantProvider),
                            ),
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(20, 28, 20, 16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Near You',
                                    style: GoogleFonts.afacad(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w800,
                                      color: kTextPrimary,
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          kPrimaryColor.withOpacity(0.1),
                                          kPrimaryColor.withOpacity(0.05),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: kPrimaryColor.withOpacity(0.2),
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(CupertinoIcons.location_solid,
                                            size: 14, color: kPrimaryColor),
                                        const SizedBox(width: 6),
                                        Text(
                                          '${merchantProvider.merchants.length} stores',
                                          style: GoogleFonts.afacad(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            color: kPrimaryColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (merchantProvider.isLoading)
                            SliverToBoxAdapter(child: _buildLoadingState())
                          else if (merchantProvider.merchants.isEmpty)
                            SliverToBoxAdapter(child: _buildEmptyState())
                          else
                            SliverPadding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              sliver: SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                                    final merchant =
                                        merchantProvider.merchants[index];
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 16),
                                      child: _buildMerchantCard(merchant),
                                    );
                                  },
                                  childCount: merchantProvider.merchants.length,
                                ),
                              ),
                            ),
                          const SliverToBoxAdapter(child: SizedBox(height: 100)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              _buildCurvedHeader(locationProvider, appProvider),
            ],
          );
        },
      );
    }

    @override
    Widget build(BuildContext context) {
      Widget bodyContent;
      switch (_bottomNavIndex) {
        case 0:
          bodyContent = _buildHomeContent();
          break;
        case 1:
          bodyContent = const ExploreScreen();
          break;
        case 2:
          bodyContent = const FavoritesScreen();
          break;
        case 3:
          bodyContent = const ProfileScreen();
          break;
        default:
          bodyContent = _buildHomeContent();
      }

      return Scaffold(
        backgroundColor: kBackgroundColor,
        body: bodyContent,
        floatingActionButton: Consumer<AppProvider>(
          builder: (context, appProvider, child) {
            return Listener(
              onPointerDown: (_) => _animateCartButton(),
              child: AnimatedScale(
                scale: _cartButtonScale,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOutBack,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: kPrimaryColor.withOpacity(0.4),
                        blurRadius: 20,
                        spreadRadius: -2,
                        offset: const Offset(0, 12),
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: FloatingActionButton(
                    onPressed: _navigateToCart,
                    backgroundColor: kPrimaryColor,
                    elevation: 0,
                    shape: const CircleBorder(),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [kPrimaryColor, kPrimaryDark],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(CupertinoIcons.cart_fill,
                              color: Colors.white, size: 24),
                        ),
                        if (appProvider.cartItemCount > 0)
                          Positioned(
                            top: 4,
                            right: 4,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: kErrorColor,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 4,
                                    spreadRadius: -1,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              constraints: const BoxConstraints(
                                  minWidth: 24, minHeight: 24),
                              child: Center(
                                child: Text(
                                  appProvider.cartItemCount > 9
                                      ? '9+'
                                      : '${appProvider.cartItemCount}',
                                  style: GoogleFonts.afacad(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
                                    height: 1,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 24,
                spreadRadius: -8,
                offset: const Offset(0, -8),
              ),
            ],
          ),
          child: AnimatedBottomNavigationBar(
            icons: _bottomNavIcons,
            activeIndex: _bottomNavIndex,
            gapLocation: GapLocation.center,
            notchSmoothness: NotchSmoothness.verySmoothEdge,
            leftCornerRadius: 32,
            rightCornerRadius: 32,
            backgroundColor: kCardColor,
            activeColor: kPrimaryColor,
            inactiveColor: kTextSecondary,
            iconSize: 24,
            height: 80,
            elevation: 0,
            splashColor: kPrimaryColor.withOpacity(0.1),
            splashRadius: 20,
            onTap: _onBottomNavTapped,
          ),
        ),
      );
    }

    Widget _buildCurvedHeader(
        LocationProvider locationProvider, AppProvider appProvider) {
      final double scrollPercentage = (_scrollOffset / 100).clamp(0.0, 1.0);
      final double searchBarOpacity = 1.0 - scrollPercentage.clamp(0.0, 0.7);
      final user = appProvider.user;

      return Positioned(
        top: 0,
        left: 0,
        right: 0,
        child: ClipPath(
          clipper: _HeaderCurveClipper(),
          child: Container(
            height: _isSearchActive ? 140 : 280,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  kGradientStart,
                  Color.lerp(kGradientStart, kGradientEnd, scrollPercentage)!,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2 * (1 - scrollPercentage)),
                  blurRadius: 20,
                  spreadRadius: -5,
                  offset: Offset(0, 10 * (1 - scrollPercentage)),
                ),
              ],
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: _navigateToProfile,
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [kPrimaryColor, kPrimaryDark],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 20,
                              backgroundColor: Colors.transparent,
                              backgroundImage: (user?.profileImage != null &&
                                      user!.profileImage!.isNotEmpty)
                                  ? NetworkImage(user.profileImage!)
                                  : null,
                              child: (user?.profileImage == null ||
                                      user!.profileImage!.isEmpty)
                                  ? const Icon(Icons.person,
                                      color: Colors.white, size: 24)
                                  : null,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        if (user != null)
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Welcome back,',
                                  style: GoogleFonts.afacad(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  user.fullName.split(' ')[0],
                                  style: GoogleFonts.afacad(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.4,
                                    height: 1.2,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          )
                        else
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome,',
                                style: GoogleFonts.afacad(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.3,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Guest',
                                style: GoogleFonts.afacad(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.4,
                                  height: 1.2,
                                ),
                              ),
                            ],
                          ),
                        const Spacer(),
                        if (!_isSearchActive) ...[
                          _buildHeaderIconButton(
                            icon: CupertinoIcons.search,
                            onTap: _toggleSearch,
                          ),
                          const SizedBox(width: 12),
                          Stack(
                            children: [
                              _buildHeaderIconButton(
                                icon: CupertinoIcons.bell,
                                onTap: _navigateToNotifications,
                              ),
                              Positioned(
                                right: 4,
                                top: 4,
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: kErrorColor,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: kErrorColor.withOpacity(0.8),
                                        blurRadius: 4,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 12),
                          _buildCartButton(appProvider),
                        ],
                      ],
                    ),
                    if (_isSearchActive) ...[
                      const SizedBox(height: 16),
                      _buildSearchField(1.0),
                    ],
                    if (!_isSearchActive) ...[
                      const Spacer(flex: 1),
                      AnimatedOpacity(
                        opacity: searchBarOpacity,
                        duration: const Duration(milliseconds: 300),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    CupertinoIcons.location_solid,
                                    color: Colors.white.withOpacity(0.95),
                                    size: 16,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Current Location',
                                  style: GoogleFonts.afacad(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            GestureDetector(
                              onTap: _refreshLocation,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.15),
                                    width: 1.5,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            locationProvider
                                                    .currentLocation?.address ??
                                                'Kericho',
                                            style: GoogleFonts.afacad(
                                              color: Colors.white,
                                              fontSize: 20,
                                              fontWeight: FontWeight.w700,
                                              letterSpacing: -0.2,
                                              height: 1.3,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Tap to refresh location',
                                            style: GoogleFonts.afacad(
                                              color:
                                                  Colors.white.withOpacity(0.7),
                                              fontSize: 12,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.white.withOpacity(0.15),
                                            Colors.white.withOpacity(0.05),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        CupertinoIcons.chevron_down,
                                        color: Colors.white.withOpacity(0.9),
                                        size: 20,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                      const Spacer(flex: 2),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    Widget _buildHeaderIconButton(
        {required IconData icon, required VoidCallback onTap}) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.12),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Icon(
              icon,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      );
    }

    Widget _buildSearchField(double opacity) {
      final scrollPercentage = (_scrollOffset / 100).clamp(0.0, 1.0);
      final backgroundColor = Color.lerp(
        Colors.transparent,
        Colors.white.withOpacity(0.12),
        scrollPercentage,
      );

      return AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        height: 52,
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: Colors.white.withOpacity(0.2 + scrollPercentage * 0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15 * scrollPercentage),
              blurRadius: 15,
              offset: Offset(0, 6 * scrollPercentage),
              spreadRadius: -2,
            ),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 18),
            Icon(
              CupertinoIcons.search,
              color: Colors.white.withOpacity(0.95),
              size: 22,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: TextField(
                controller: _searchController,
                onChanged: _handleSearchChanged,
                style: GoogleFonts.afacad(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.1,
                ),
                decoration: InputDecoration(
                  hintText: 'Search restaurants, groceries, pharmacies...',
                  hintStyle: GoogleFonts.afacad(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            if (_searchQuery.isNotEmpty)
              GestureDetector(
                onTap: () {
                  _searchController.clear();
                  _handleSearchChanged('');
                  HapticFeedback.lightImpact();
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    CupertinoIcons.xmark,
                    color: Colors.white.withOpacity(0.9),
                    size: 16,
                  ),
                ),
              ),
            const SizedBox(width: 6),
          ],
        ),
      );
    }

    Widget _buildCartButton(AppProvider appProvider) {
      return GestureDetector(
        onTap: _navigateToCart,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.12),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                CupertinoIcons.cart,
                color: Colors.white,
                size: 20,
              ),
              if (appProvider.cartItemCount > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: kErrorColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: kErrorColor.withOpacity(0.8),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    constraints:
                        const BoxConstraints(minWidth: 18, minHeight: 18),
                    child: Center(
                      child: Text(
                        appProvider.cartItemCount > 9
                            ? '9+'
                            : '${appProvider.cartItemCount}',
                        style: GoogleFonts.afacad(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    }

    Widget _buildCategoriesSection() {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 50),
            SizedBox(
              height: 110,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  final isSelected = index == _selectedCategoryIndex;
                  return Padding(
                    padding: EdgeInsets.only(
                      right: index < _categories.length - 1 ? 12 : 0,
                    ),
                    child: _buildCategoryCard(category, isSelected, index),
                  );
                },
              ),
            ),
          ],
        ),
      );
    }

    Widget _buildCategoryCard(
        Map<String, dynamic> category, bool isSelected, int index) {
      return GestureDetector(
        onTap: () => _handleCategorySelected(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOutBack,
          child: Column(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? LinearGradient(
                          colors: [kPrimaryColor, kPrimaryDark],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : LinearGradient(
                          colors: [Colors.white, kSurfaceLight],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? Colors.white.withOpacity(0.3)
                        : kBorderColor.withOpacity(0.8),
                    width: isSelected ? 3 : 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isSelected
                          ? kPrimaryColor.withOpacity(0.4)
                          : Colors.black.withOpacity(0.08),
                      blurRadius: isSelected ? 20 : 12,
                      offset: Offset(0, isSelected ? 8 : 4),
                      spreadRadius: isSelected ? -4 : 0,
                    ),
                  ],
                ),
                child: Center(
                  child: AnimatedScale(
                    scale: isSelected ? 1.15 : 1.0,
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      category['emoji'],
                      style: const TextStyle(fontSize: 32),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? LinearGradient(
                          colors: [
                            kPrimaryColor.withOpacity(0.15),
                            kPrimaryColor.withOpacity(0.05)
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: isSelected ? null : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                  border: isSelected
                      ? Border.all(color: kPrimaryColor.withOpacity(0.2))
                      : null,
                ),
                child: Text(
                  category['label'],
                  style: GoogleFonts.afacad(
                    fontSize: 12.5,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: isSelected ? kPrimaryColor : kTextSecondary,
                    letterSpacing: isSelected ? -0.1 : 0,
                    height: 1.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      );
    }

    Widget _buildFeaturedSection(MerchantProvider merchantProvider) {
      final featuredMerchants = merchantProvider.getFeaturedMerchants();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [kWarningColor, const Color(0xFFF59E0B)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: kWarningColor.withOpacity(0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                            spreadRadius: -2,
                          ),
                        ],
                      ),
                      child: Icon(CupertinoIcons.star_fill,
                          color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Featured',
                          style: GoogleFonts.afacad(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: kTextPrimary,
                            letterSpacing: -0.4,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Top-rated restaurants & stores',
                          style: GoogleFonts.afacad(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: kTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    // Navigate to all featured
                  },
                  style: TextButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    backgroundColor: kPrimaryColor.withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: BorderSide(
                        color: kPrimaryColor.withOpacity(0.2),
                        width: 1.5,
                      ),
                    ),
                    shadowColor: kPrimaryColor.withOpacity(0.2),
                    elevation: 2,
                  ),
                  child: Row(
                    children: [
                      Text(
                        'View all',
                        style: GoogleFonts.afacad(
                          color: kPrimaryColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 13.5,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        CupertinoIcons.chevron_right,
                        color: kPrimaryColor,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 260,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              physics: const BouncingScrollPhysics(),
              itemCount: featuredMerchants.length,
              itemBuilder: (context, index) {
                final merchant = featuredMerchants[index];
                return Padding(
                  padding: EdgeInsets.only(
                    right: index < featuredMerchants.length - 1 ? 20 : 0,
                  ),
                  child: _buildFeaturedMerchantCard(merchant),
                );
              },
            ),
          ),
        ],
      );
    }

    Widget _buildFeaturedMerchantCard(MerchantModel merchant) {
      return GestureDetector(
        onTap: () => _navigateToMerchant(merchant.id, merchant.name),
        child: Container(
          width: 220,
          decoration: BoxDecoration(
            color: kCardColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: kBorderColor.withOpacity(0.6), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 16,
                offset: const Offset(0, 6),
                spreadRadius: -4,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMerchantImage(merchant, height: 140, radius: 24),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            merchant.name,
                            style: GoogleFonts.afacad(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: kTextPrimary,
                              height: 1.2,
                              letterSpacing: -0.2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                kWarningColor.withOpacity(0.15),
                                kWarningColor.withOpacity(0.05)
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: kWarningColor.withOpacity(0.3),
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                CupertinoIcons.star_fill,
                                size: 12,
                                color: kWarningColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                merchant.rating.toStringAsFixed(1),
                                style: GoogleFonts.afacad(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: kWarningColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: kBackgroundColor,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: kBorderColor, width: 1.5),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                CupertinoIcons.clock,
                                size: 13,
                                color: kTextSecondary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${merchant.deliveryTime} min',
                                style: GoogleFonts.afacad(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: kTextSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: merchant.deliveryFee == 0
                                ? kSuccessColor.withOpacity(0.1)
                                : kBackgroundColor,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: merchant.deliveryFee == 0
                                  ? kSuccessColor.withOpacity(0.3)
                                  : kBorderColor,
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                merchant.deliveryFee == 0
                                    ? CupertinoIcons.checkmark_seal_fill
                                    : CupertinoIcons.car_detailed,
                                size: 13,
                                color: merchant.deliveryFee == 0
                                    ? kSuccessColor
                                    : kTextSecondary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                merchant.deliveryFee == 0
                                    ? 'Free'
                                    : 'KSh ${merchant.deliveryFee.toInt()}',
                                style: GoogleFonts.afacad(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: merchant.deliveryFee == 0
                                      ? kSuccessColor
                                      : kTextSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    Widget _buildMerchantCard(MerchantModel merchant) {
      return GestureDetector(
        onTap: () => _navigateToMerchant(merchant.id, merchant.name),
        child: Container(
          decoration: BoxDecoration(
            color: kCardColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: kBorderColor.withOpacity(0.6), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 12,
                offset: const Offset(0, 4),
                spreadRadius: -2,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMerchantImage(merchant),
              _buildMerchantDetails(merchant),
            ],
          ),
        ),
      );
    }

    Widget _buildMerchantImage(
      MerchantModel merchant, {
      double height = 180,
      double radius = 24,
    }) {
      return Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(radius)),
            child: Container(
              height: height,
              width: double.infinity,
              color: kSurfaceLight,
              child: merchant.imageUrl != null
                  ? (merchant.imageUrl!.startsWith('http')
                      ? CachedNetworkImage(
                          imageUrl: merchant.imageUrl!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => _buildImagePlaceholder(),
                          errorWidget: (context, url, error) =>
                              _buildImagePlaceholder(),
                        )
                      : Image.asset(
                          merchant.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _buildImagePlaceholder(),
                        ))
                  : _buildImagePlaceholder(),
            ),
          ),
          Positioned(
            top: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: merchant.isOpen
                      ? [kSuccessColor, const Color(0xFF34D399)]
                      : [kErrorColor, const Color(0xFFF87171)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: merchant.isOpen
                        ? kSuccessColor.withOpacity(0.4)
                        : kErrorColor.withOpacity(0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                    spreadRadius: -2,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    merchant.isOpen
                        ? CupertinoIcons.checkmark_circle_fill
                        : CupertinoIcons.xmark_circle_fill,
                    size: 13,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    merchant.isOpen ? 'OPEN NOW' : 'CLOSED',
                    style: GoogleFonts.afacad(
                      fontSize: 11,
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (merchant.deliveryFee == 0)
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [kSuccessColor, Color(0xFF10B981)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: kSuccessColor.withOpacity(0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                      spreadRadius: -2,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      CupertinoIcons.checkmark_seal_fill,
                      size: 13,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'FREE DELIVERY',
                      style: GoogleFonts.afacad(
                        fontSize: 11,
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      );
    }

    Widget _buildImagePlaceholder() {
      return Container(
        color: kSurfaceLight,
        child: Center(
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                  spreadRadius: -2,
                ),
              ],
            ),
            child: Icon(
              CupertinoIcons.building_2_fill,
              size: 36,
              color: kTextSecondary.withOpacity(0.4),
            ),
          ),
        ),
      );
    }

    Widget _buildMerchantDetails(MerchantModel merchant) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        merchant.name,
                        style: GoogleFonts.afacad(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          color: kTextPrimary,
                          letterSpacing: -0.3,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        merchant.description,
                        style: GoogleFonts.afacad(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: kTextSecondary,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [kWarningColor, const Color(0xFFF59E0B)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: kWarningColor.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                        spreadRadius: -2,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        CupertinoIcons.star_fill,
                        size: 15,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        merchant.rating.toStringAsFixed(1),
                        style: GoogleFonts.afacad(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: kSurfaceLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: kBorderColor, width: 1.5),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Icon(
                          CupertinoIcons.clock,
                          size: 18,
                          color: kPrimaryColor,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${merchant.deliveryTime} min',
                          style: GoogleFonts.afacad(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: kTextPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Delivery',
                          style: GoogleFonts.afacad(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: kTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: kBorderColor,
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Icon(
                          merchant.deliveryFee == 0
                              ? CupertinoIcons.checkmark_seal_fill
                              : CupertinoIcons.car_detailed,
                          size: 18,
                          color: merchant.deliveryFee == 0
                              ? kSuccessColor
                              : kPrimaryColor,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          merchant.deliveryFee == 0
                              ? 'Free'
                              : 'KSh ${merchant.deliveryFee.toInt()}',
                          style: GoogleFonts.afacad(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: merchant.deliveryFee == 0
                                ? kSuccessColor
                                : kTextPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Fee',
                          style: GoogleFonts.afacad(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: kTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: kBorderColor,
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Icon(
                          CupertinoIcons.bag_fill,
                          size: 18,
                          color: kPrimaryColor,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'KSh ${merchant.minimumOrder?.toInt() ?? 0}',
                          style: GoogleFonts.afacad(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: kTextPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Min order',
                          style: GoogleFonts.afacad(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: kTextSecondary,
                          ),
                        ),
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

    Widget _buildLoadingState() {
      return Container(
        padding: const EdgeInsets.all(60),
        child: Column(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [kPrimaryColor, kPrimaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: kPrimaryColor.withOpacity(0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                    spreadRadius: -4,
                  ),
                ],
              ),
              child: const Padding(
                padding: EdgeInsets.all(14),
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                  strokeWidth: 3,
                ),
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'Finding stores near you...',
              style: GoogleFonts.afacad(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: kTextPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please wait while we fetch the best options',
              style: GoogleFonts.afacad(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: kTextSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    Widget _buildEmptyState() {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: kCardColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: kBorderColor, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, 6),
              spreadRadius: -4,
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [kSurfaceLight, Colors.white],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                    spreadRadius: -2,
                  ),
                ],
              ),
              child: Icon(
                CupertinoIcons.search,
                size: 48,
                color: kTextSecondary.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'No stores found',
              style: GoogleFonts.afacad(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: kTextPrimary,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Try adjusting your filters or\ncheck back later for new stores',
              style: GoogleFonts.afacad(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: kTextSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                setState(() {
                  _selectedCategoryIndex = 0;
                  _searchController.clear();
                  _searchQuery = '';
                });
                context.read<MerchantProvider>().clearCategory();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
                shadowColor: kPrimaryColor.withOpacity(0.3),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(CupertinoIcons.refresh, size: 20),
                  const SizedBox(width: 12),
                  Text(
                    'View All Stores',
                    style: GoogleFonts.afacad(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }

  class _HeaderCurveClipper extends CustomClipper<Path> {
    @override
    Path getClip(Size size) {
      final path = Path();
      path.lineTo(0, size.height - 60);

      final firstControlPoint = Offset(size.width * 0.25, size.height + 10);
      final firstEndPoint = Offset(size.width * 0.5, size.height - 30);
      path.quadraticBezierTo(
        firstControlPoint.dx,
        firstControlPoint.dy,
        firstEndPoint.dx,
        firstEndPoint.dy,
      );

      final secondControlPoint = Offset(size.width * 0.75, size.height - 50);
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
  