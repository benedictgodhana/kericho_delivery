import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kericho_delivery/data/models/merchant_model.dart';
import 'package:kericho_delivery/presentation/providers/app_provider.dart';
import 'package:kericho_delivery/presentation/providers/location_provider.dart';
import 'package:kericho_delivery/presentation/providers/merchant_provider.dart';
import 'package:kericho_delivery/presentation/router/app_router.dart';
import 'package:kericho_delivery/core/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cupertino_icons/cupertino_icons.dart';

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
  // Bottom navigation index
  int _bottomNavIndex = 0;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  // Enhanced color palette
  static const Color kPrimaryColor = Color(0xFF0F766E);
  static const Color kPrimaryDark = Color(0xFF0F172A);
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

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _fadeAnimation =
        Tween<double>(begin: 1.0, end: 0.0).animate(_fadeController);

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
      arguments: {
        'merchantId': merchantId,
        'merchantName': merchantName,
      },
    );
  }

  void _navigateToCart() {
    HapticFeedback.mediumImpact();
    AppRouter.pushNamed(AppRouter.cart);
  }

  void _navigateToNotifications() {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(CupertinoIcons.bell, color: Colors.grey.shade100),
            const SizedBox(width: 12),
            Text(
              'Notifications coming soon!',
              style: GoogleFonts.afacad(color: Colors.white),
            ),
          ],
        ),
        backgroundColor: kInfoColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _refreshLocation() async {
    HapticFeedback.lightImpact();
    try {
      await context.read<LocationProvider>().getCurrentLocation();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(CupertinoIcons.location, color: Colors.grey.shade100),
                const SizedBox(width: 12),
                Text(
                  'Location updated!',
                  style: GoogleFonts.afacad(color: Colors.white),
                ),
              ],
            ),
            backgroundColor: kSuccessColor,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(CupertinoIcons.exclamationmark_circle,
                    color: Colors.grey.shade100),
                const SizedBox(width: 12),
                Text(
                  'Location update failed',
                  style: GoogleFonts.afacad(color: Colors.white),
                ),
              ],
            ),
            backgroundColor: kErrorColor,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _onBottomNavTapped(int index) {
    HapticFeedback.lightImpact();

    if (index == 2) {
      // This is the cart button in the middle
      _navigateToCart();
      return;
    }

    setState(() {
      _bottomNavIndex = index;
    });

    // Handle navigation to different screens
    switch (index) {
      case 0: // Home
        // Already on home, just scroll to top
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        break;
      case 1: // Explore
        AppRouter.pushNamed('explore');
        break;
      case 3: // Favorites
        AppRouter.pushNamed('favorites');
        break;
      case 4: // Profile
        AppRouter.pushNamed(AppRouter.profile);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: Consumer3<LocationProvider, AppProvider, MerchantProvider>(
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
                      child: CustomScrollView(
                        controller: _scrollController,
                        physics: const BouncingScrollPhysics(
                          parent: AlwaysScrollableScrollPhysics(),
                        ),
                        slivers: [
                          SliverToBoxAdapter(
                            child: _buildCategoriesSection(),
                          ),
                          if (merchantProvider
                              .getFeaturedMerchants()
                              .isNotEmpty)
                            SliverToBoxAdapter(
                              child: _buildFeaturedSection(merchantProvider),
                            ),
                          SliverToBoxAdapter(
                            child: Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(20, 28, 20, 16),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                      color: kPrimaryColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(CupertinoIcons.shopping_cart,
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
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              sliver: SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                                    final merchant =
                                        merchantProvider.merchants[index];
                                    return Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 16),
                                      child: _buildMerchantCard(merchant),
                                    );
                                  },
                                  childCount: merchantProvider.merchants.length,
                                ),
                              ),
                            ),
                          const SliverToBoxAdapter(
                              child: SizedBox(height: 100)),
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
      ),
      bottomNavigationBar: _buildFloatingBottomNavBar(),
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
        clipper: HeaderCurveClipper(),
        child: Container(
          height: _isSearchActive ? 140 : 280,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                kPrimaryDark,
                Color.lerp(
                    const Color(0xFF1E293B), kPrimaryDark, scrollPercentage)!,
              ],
            ),
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
                        onTap: () {
                          HapticFeedback.lightImpact();
                          _onBottomNavTapped(4);
                        },
                        child: CircleAvatar(
                          radius: 22,
                          backgroundColor: Colors.white.withOpacity(0.25),
                          backgroundImage: (user?.profileImage != null &&
                                  user!.profileImage!.isNotEmpty)
                              ? NetworkImage(user.profileImage!)
                              : null,
                          child: (user?.profileImage == null ||
                                  user!.profileImage!.isEmpty)
                              ? const Icon(Icons.person,
                                  color: Colors.white, size: 32)
                              : null,
                        ),
                      ),
                      const SizedBox(width: 14),
                      if (user != null)
                        Expanded(
                          child: Text(
                            user.fullName,
                            style: GoogleFonts.afacad(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.4,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        )
                      else
                        const Text(
                          "Welcome",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      const Spacer(),
                      if (!_isSearchActive) ...[
                        GestureDetector(
                          onTap: _toggleSearch,
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: kOverlayWhite,
                            ),
                            child: Icon(
                              CupertinoIcons.search,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Stack(
                          children: [
                            GestureDetector(
                              onTap: _navigateToNotifications,
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: kOverlayWhite,
                                ),
                                child: Icon(
                                  CupertinoIcons.bell,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                            Positioned(
                              right: 0,
                              top: 0,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: kErrorColor,
                                  shape: BoxShape.circle,
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
                    const SizedBox(height: 12),
                    _buildSearchField(1.0),
                  ],
                  if (!_isSearchActive) ...[
                    const Spacer(flex: 1),
                    AnimatedOpacity(
                      opacity: searchBarOpacity,
                      duration: const Duration(milliseconds: 200),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                CupertinoIcons.location_solid,
                                color: Colors.white.withOpacity(0.8),
                                size: 18,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Current Location',
                                style: GoogleFonts.afacad(
                                  color: Colors.white70,
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: _refreshLocation,
                            child: Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    locationProvider.currentLocation?.address ??
                                        'Kericho',
                                    style: GoogleFonts.afacad(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: -0.2,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  CupertinoIcons.chevron_down,
                                  color: Colors.white.withOpacity(0.7),
                                  size: 24,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: kOverlayWhite,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      CupertinoIcons.bag_fill,
                                      color: Colors.white.withOpacity(0.9),
                                      size: 14,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Fast delivery • 20-30 min',
                                      style: GoogleFonts.afacad(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
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

  Widget _buildSearchField(double opacity) {
    final scrollPercentage = (_scrollOffset / 100).clamp(0.0, 1.0);
    final backgroundColor = Color.lerp(
      Colors.transparent,
      Colors.white.withOpacity(0.1),
      scrollPercentage,
    );

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 48,
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: Colors.white.withOpacity(0.12 + scrollPercentage * 0.3),
          width: 1.5,
        ),
        boxShadow: [
          if (scrollPercentage > 0.5)
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          Icon(
            CupertinoIcons.search,
            color: Colors.white.withOpacity(0.9),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: _handleSearchChanged,
              style: GoogleFonts.afacad(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: 'Search restaurants, groceries...',
                hintStyle: GoogleFonts.afacad(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          if (_searchQuery.isNotEmpty)
            GestureDetector(
              onTap: () {
                _searchController.clear();
                _handleSearchChanged('');
              },
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Icon(
                  CupertinoIcons.xmark_circle_fill,
                  color: Colors.white.withOpacity(0.7),
                  size: 20,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCartButton(AppProvider appProvider) {
    return GestureDetector(
      onTap: _navigateToCart,
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: kOverlayWhite,
            ),
            child: Icon(
              CupertinoIcons.cart,
              color: Colors.white,
              size: 20,
            ),
          ),
          if (appProvider.cartItemCount > 0)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: kErrorColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 2,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                child: Center(
                  child: Text(
                    appProvider.cartItemCount > 9
                        ? '9+'
                        : '${appProvider.cartItemCount}',
                    style: GoogleFonts.afacad(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
        ],
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
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: Column(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isSelected
                      ? [
                          kPrimaryColor.withOpacity(0.2),
                          kSuccessColor.withOpacity(0.1)
                        ]
                      : [Colors.white, Colors.white],
                ),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? kPrimaryColor : kBorderColor,
                  width: isSelected ? 2.5 : 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isSelected
                        ? kPrimaryColor.withOpacity(0.3)
                        : Colors.black.withOpacity(0.05),
                    blurRadius: isSelected ? 15 : 8,
                    offset: Offset(0, isSelected ? 6 : 2),
                    spreadRadius: isSelected ? -2 : 0,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  category['emoji'],
                  style: const TextStyle(fontSize: 32),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isSelected
                    ? kPrimaryColor.withOpacity(0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                category['label'],
                style: GoogleFonts.afacad(
                  fontSize: 12.5,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                  color: isSelected ? kPrimaryColor : kTextSecondary,
                  letterSpacing: isSelected ? -0.1 : 0,
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
          padding: const EdgeInsets.fromLTRB(20, 28, 20, 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [kWarningColor, const Color(0xFFFBBF24)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: kWarningColor.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(CupertinoIcons.star_fill,
                        color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Featured',
                    style: GoogleFonts.afacad(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: kTextPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  // Navigate to all featured - implement if needed
                },
                style: TextButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  backgroundColor: kPrimaryColor.withOpacity(0.08),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      'View all',
                      style: GoogleFonts.afacad(
                        color: kPrimaryColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      CupertinoIcons.chevron_right,
                      color: kPrimaryColor,
                      size: 14,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 240,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            physics: const BouncingScrollPhysics(),
            itemCount: featuredMerchants.length,
            itemBuilder: (context, index) {
              final merchant = featuredMerchants[index];
              return Padding(
                padding: EdgeInsets.only(
                  right: index < featuredMerchants.length - 1 ? 16 : 0,
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
        width: 200,
        decoration: BoxDecoration(
          color: kCardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: kBorderColor.withOpacity(0.5), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMerchantImage(merchant, height: 130, radius: 20),
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
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: kTextPrimary,
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: kWarningColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
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
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        CupertinoIcons.clock,
                        size: 14,
                        color: kTextSecondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${merchant.deliveryTime} min',
                        style: GoogleFonts.afacad(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: kTextSecondary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        merchant.deliveryFee == 0
                            ? CupertinoIcons.checkmark_seal_fill
                            : CupertinoIcons.car_detailed,
                        size: 14,
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
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: merchant.deliveryFee == 0
                              ? kSuccessColor
                              : kTextSecondary,
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
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: kBorderColor.withOpacity(0.5), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
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
    double height = 160,
    double radius = 20,
  }) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.vertical(top: Radius.circular(radius)),
          child: Container(
            height: height,
            width: double.infinity,
            color: Colors.grey[50],
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
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: merchant.isOpen
                      ? kSuccessColor.withOpacity(0.3)
                      : kErrorColor.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
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
                  size: 12,
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
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: kSuccessColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    CupertinoIcons.checkmark_seal_fill,
                    size: 12,
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
      color: Colors.grey[50],
      child: Center(
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            CupertinoIcons.building_2_fill,
            size: 36,
            color: Colors.grey[300],
          ),
        ),
      ),
    );
  }

  Widget _buildMerchantDetails(MerchantModel merchant) {
    return Padding(
      padding: const EdgeInsets.all(16),
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
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: kTextPrimary,
                        letterSpacing: -0.2,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      merchant.description,
                      style: GoogleFonts.afacad(
                        fontSize: 13.5,
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
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [kWarningColor, const Color(0xFFF59E0B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(
                      CupertinoIcons.star_fill,
                      size: 14,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      merchant.rating.toStringAsFixed(1),
                      style: GoogleFonts.afacad(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: kBackgroundColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: kBorderColor, width: 1),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        CupertinoIcons.clock,
                        size: 14,
                        color: kPrimaryColor,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${merchant.deliveryTime} min',
                        style: GoogleFonts.afacad(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: kPrimaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: kBackgroundColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: kBorderColor, width: 1),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        merchant.deliveryFee == 0
                            ? CupertinoIcons.checkmark_seal_fill
                            : CupertinoIcons.car_detailed,
                        size: 14,
                        color: merchant.deliveryFee == 0
                            ? kSuccessColor
                            : kPrimaryColor,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        merchant.deliveryFee == 0
                            ? 'Free'
                            : 'KSh ${merchant.deliveryFee.toInt()}',
                        style: GoogleFonts.afacad(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: merchant.deliveryFee == 0
                              ? kSuccessColor
                              : kPrimaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: kBackgroundColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: kBorderColor, width: 1),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        CupertinoIcons.bag_fill,
                        size: 14,
                        color: kPrimaryColor,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'KSh ${merchant.minimumOrder?.toInt() ?? 0}',
                        style: GoogleFonts.afacad(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: kPrimaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
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
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [kPrimaryColor, const Color(0xFF0D9488)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: kPrimaryColor.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Padding(
              padding: EdgeInsets.all(12),
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Colors.white),
                strokeWidth: 3,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Finding stores near you...',
            style: GoogleFonts.afacad(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: kTextPrimary,
            ),
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
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kBorderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
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
                colors: [kBackgroundColor, Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              CupertinoIcons.search,
              size: 48,
              color: kTextSecondary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No stores found',
            style: GoogleFonts.afacad(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: kTextPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Try adjusting your filters or\ncheck back later',
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
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
              shadowColor: kPrimaryColor.withOpacity(0.3),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(CupertinoIcons.refresh, size: 20),
                const SizedBox(width: 10),
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

  Widget _buildFloatingBottomNavBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      height: 70,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: kCardColor,
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: kBorderColor, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 25,
                  offset: const Offset(0, 8),
                  spreadRadius: -5,
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildNavItem(
                    0,
                    CupertinoIcons.house_fill,
                    'Home',
                  ),
                ),
                Expanded(
                  child: _buildNavItem(
                    1,
                    CupertinoIcons.compass_fill,
                    'Explore',
                  ),
                ),
                const SizedBox(width: 70), // Space for center button
                Expanded(
                  child: _buildNavItem(
                    3,
                    CupertinoIcons.heart,
                    'Favorites',
                  ),
                ),
                Expanded(
                  child: _buildNavItem(
                    4,
                    CupertinoIcons.person_fill,
                    'Profile',
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: MediaQuery.of(context).size.width / 2 - 35,
            top: -20,
            child: GestureDetector(
              onTap: () => _onBottomNavTapped(2),
              child: Consumer<AppProvider>(
                builder: (context, appProvider, child) {
                  return Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [kPrimaryColor, const Color(0xFF0D9488)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: kPrimaryColor.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        const Center(
                          child: Icon(
                            CupertinoIcons.cart_fill,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        if (appProvider.cartItemCount > 0)
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: kErrorColor,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 3,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 24,
                                minHeight: 24,
                              ),
                              child: Center(
                                child: Text(
                                  appProvider.cartItemCount > 9
                                      ? '9+'
                                      : '${appProvider.cartItemCount}',
                                  style: GoogleFonts.afacad(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _bottomNavIndex == index;

    return GestureDetector(
      onTap: () => _onBottomNavTapped(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color:
              isSelected ? kPrimaryColor.withOpacity(0.08) : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              transform: Matrix4.translationValues(
                0,
                isSelected ? -4 : 0,
                0,
              ),
              child: Icon(
                icon,
                color: isSelected ? kPrimaryColor : kTextSecondary,
                size: isSelected ? 26 : 22,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.afacad(
                color: isSelected ? kPrimaryColor : kTextSecondary,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                fontSize: 11,
                letterSpacing: isSelected ? -0.2 : 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HeaderCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 50);

    final firstControlPoint = Offset(size.width * 0.25, size.height);
    final firstEndPoint = Offset(size.width * 0.5, size.height - 20);
    path.quadraticBezierTo(
      firstControlPoint.dx,
      firstControlPoint.dy,
      firstEndPoint.dx,
      firstEndPoint.dy,
    );

    final secondControlPoint = Offset(size.width * 0.75, size.height - 40);
    final secondEndPoint = Offset(size.width, size.height - 50);
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
