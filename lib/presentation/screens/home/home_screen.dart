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

class _HomeScreenState extends State<HomeScreen> {
  int _selectedCategoryIndex = 0;
  final ScrollController _scrollController = ScrollController();
  bool _showSearchBar = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounceTimer;

  // Simplified color palette
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
    if (offset > 60 && !_showSearchBar) {
      setState(() => _showSearchBar = true);
    } else if (offset <= 60 && _showSearchBar) {
      setState(() => _showSearchBar = false);
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

    // Cancel previous timer
    _searchDebounceTimer?.cancel();

    // Start new timer
    _searchDebounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (_searchQuery == query && mounted) {
        context.read<MerchantProvider>().searchMerchants(query);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: Consumer3<LocationProvider, AppProvider, MerchantProvider>(
        builder: (context, locationProvider, appProvider, merchantProvider, _) {
          return Stack(
            children: [
              // Main content
              Column(
                children: [
                  const SizedBox(height: 200), // Reserve space for header
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () async {
                        await _refreshLocation();
                        // Reload merchants if needed
                      },
                      color: kPrimaryColor,
                      child: CustomScrollView(
                        controller: _scrollController,
                        physics: const BouncingScrollPhysics(
                          parent: AlwaysScrollableScrollPhysics(),
                        ),
                        slivers: [
                          // Categories Section
                          SliverToBoxAdapter(
                            child: _buildCategoriesSection(),
                          ),

                          // Featured Merchants Section
                          if (merchantProvider
                              .getFeaturedMerchants()
                              .isNotEmpty)
                            SliverToBoxAdapter(
                              child: _buildFeaturedSection(merchantProvider),
                            ),

                          // Near You Section Header
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

                          // Merchants Grid/List
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

              // Curved Header
              _buildCurvedHeader(locationProvider, appProvider),
            ],
          );
        },
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  // ==================== CURVED HEADER ====================
  Widget _buildCurvedHeader(
      LocationProvider locationProvider, AppProvider appProvider) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: ClipPath(
        clipper: HeaderCurveClipper(),
        child: Container(
          height: 220,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                kPrimaryDark,
                Color(0xFF1E293B),
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  // Top Bar
                  Row(
                    children: [
                      if (_showSearchBar) ...[
                        IconButton(
                          icon: Icon(
                            CupertinoIcons.arrow_left,
                            color: Colors.white70,
                            size: 24,
                          ),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                              _showSearchBar = false;
                            });
                            FocusScope.of(context).unfocus();
                          },
                        ),
                        const SizedBox(width: 4),
                      ] else
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
                            style: GoogleFonts.afacad(
                              color: Colors.white70,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      Expanded(
                        child: AnimatedOpacity(
                          opacity: _showSearchBar ? 1 : 0,
                          duration: const Duration(milliseconds: 280),
                          child: _showSearchBar
                              ? _buildSearchField()
                              : const SizedBox.shrink(),
                        ),
                      ),
                      if (!_showSearchBar) ...[
                        IconButton(
                          icon: Icon(
                            CupertinoIcons.bell,
                            color: Colors.white,
                            size: 24,
                          ),
                          onPressed: _navigateToNotifications,
                        ),
                        const SizedBox(width: 4),
                      ],
                      _buildCartButton(appProvider),
                    ],
                  ),
                  if (!_showSearchBar) ...[
                    const Spacer(flex: 1),
                    // Location Section
                    Column(
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
                                      'Kericho, Kenya',
                                  style: GoogleFonts.afacad(
                                    color: Colors.white,
                                    fontSize: 24,
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
                            Icon(
                              CupertinoIcons.bag_fill,
                              color: Colors.white.withOpacity(0.7),
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Fast delivery • 20-30 min',
                              style: GoogleFonts.afacad(
                                color: Colors.white70,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
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

  Widget _buildSearchField() {
    return Container(
      height: 48,
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: Colors.white.withOpacity(0.12),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          Icon(
            CupertinoIcons.search,
            color: Colors.white.withOpacity(0.8),
            size: 22,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: _handleSearchChanged,
              style: GoogleFonts.afacad(color: Colors.white, fontSize: 15),
              decoration: InputDecoration(
                hintText: 'Search for "Grocery"...',
                hintStyle: GoogleFonts.afacad(
                  color: Colors.white60,
                  fontSize: 15,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          if (_searchQuery.isNotEmpty)
            IconButton(
              icon: Icon(
                CupertinoIcons.xmark,
                color: Colors.white.withOpacity(0.7),
                size: 20,
              ),
              onPressed: () {
                _searchController.clear();
                _handleSearchChanged('');
              },
            ),
        ],
      ),
    );
  }

  Widget _buildCartButton(AppProvider appProvider) {
    return Stack(
      children: [
        IconButton(
          icon: Icon(
            CupertinoIcons.cart,
            color: Colors.white,
            size: 26,
          ),
          onPressed: _navigateToCart,
        ),
        if (appProvider.cartItemCount > 0)
          Positioned(
            right: 6,
            top: 6,
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: const BoxDecoration(
                color: kErrorColor,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
              child: Center(
                child: Text(
                  appProvider.cartItemCount > 9
                      ? '9+'
                      : '${appProvider.cartItemCount}',
                  style: GoogleFonts.afacad(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  // ==================== CATEGORIES SECTION ====================
  Widget _buildCategoriesSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
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
                    right: index < _categories.length - 1 ? 16 : 0,
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
    Map<String, dynamic> category,
    bool isSelected,
    int index,
  ) {
    return GestureDetector(
      onTap: () => _handleCategorySelected(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: Column(
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: kCardColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? kSuccessColor : kBorderColor,
                  width: isSelected ? 3 : 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isSelected
                        ? kSuccessColor.withOpacity(0.2)
                        : Colors.black.withOpacity(0.04),
                    blurRadius: isSelected ? 12 : 8,
                    offset: Offset(0, isSelected ? 4 : 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  category['emoji'],
                  style: const TextStyle(fontSize: 38),
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: 76,
              child: Text(
                category['label'],
                style: GoogleFonts.afacad(
                  fontSize: 13.5,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? kPrimaryColor : kTextSecondary,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== FEATURED SECTION ====================
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
                  Icon(CupertinoIcons.star_fill,
                      color: kWarningColor, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Featured',
                    style: GoogleFonts.afacad(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: kTextPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {
                  // Navigate to all featured
                },
                child: Row(
                  children: [
                    Text(
                      'See all',
                      style: GoogleFonts.afacad(
                        color: kErrorColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      CupertinoIcons.arrow_right,
                      color: kErrorColor,
                      size: 18,
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
                  right: index < featuredMerchants.length - 1 ? 14 : 0,
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
        width: 190,
        decoration: BoxDecoration(
          color: kCardColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: kBorderColor, width: 1),
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
            _buildMerchantImage(merchant, height: 120, radius: 18),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    merchant.name,
                    style: GoogleFonts.afacad(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: kTextPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        CupertinoIcons.star_fill,
                        size: 16,
                        color: kWarningColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        merchant.rating.toStringAsFixed(1),
                        style: GoogleFonts.afacad(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: kTextPrimary,
                        ),
                      ),
                      Text(
                        ' • ${merchant.deliveryTime} min',
                        style: GoogleFonts.afacad(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: kTextSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        CupertinoIcons.car_detailed,
                        size: 16,
                        color: kSuccessColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        merchant.deliveryFee == 0
                            ? 'Free delivery'
                            : 'KSh ${merchant.deliveryFee.toInt()}',
                        style: GoogleFonts.afacad(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: kSuccessColor,
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

  // ==================== MERCHANT CARD ====================
  Widget _buildMerchantCard(MerchantModel merchant) {
    return GestureDetector(
      onTap: () => _navigateToMerchant(merchant.id, merchant.name),
      child: Container(
        decoration: BoxDecoration(
          color: kCardColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: kBorderColor, width: 1),
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
    double radius = 18,
  }) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.vertical(top: Radius.circular(radius)),
          child: Container(
            height: height,
            width: double.infinity,
            color: Colors.grey[100],
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
          child: _buildStatusBadge(merchant.isOpen),
        ),
        if (merchant.deliveryFee == 0)
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: kSuccessColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    CupertinoIcons.car_detailed,
                    size: 12,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Free delivery',
                    style: GoogleFonts.afacad(
                      fontSize: 11,
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
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
      color: Colors.grey[100],
      child: Center(
        child: Icon(
          CupertinoIcons.building_2_fill,
          size: 48,
          color: Colors.grey[300],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(bool isOpen) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isOpen ? kSuccessColor : kErrorColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isOpen ? CupertinoIcons.circle_fill : CupertinoIcons.circle,
            size: 10,
            color: Colors.white,
          ),
          const SizedBox(width: 6),
          Text(
            isOpen ? 'OPEN' : 'CLOSED',
            style: GoogleFonts.afacad(
              fontSize: 11,
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
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
            children: [
              Expanded(
                child: Text(
                  merchant.name,
                  style: GoogleFonts.afacad(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: kTextPrimary,
                    letterSpacing: -0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: kWarningColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      CupertinoIcons.star_fill,
                      size: 14,
                      color: kWarningColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      merchant.rating.toStringAsFixed(1),
                      style: GoogleFonts.afacad(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: kWarningColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
          const SizedBox(height: 12),
          Row(
            children: [
              _buildInfoChip(
                '${merchant.deliveryTime} min',
                CupertinoIcons.clock,
              ),
              const SizedBox(width: 8),
              _buildInfoChip(
                merchant.deliveryFee == 0
                    ? 'Free'
                    : 'KSh ${merchant.deliveryFee.toInt()}',
                CupertinoIcons.car_detailed,
              ),
              const SizedBox(width: 8),
              _buildInfoChip(
                'Min ${merchant.minimumOrder?.toInt() ?? 0}',
                CupertinoIcons.bag,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String text, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: kBackgroundColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: kBorderColor, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: kTextSecondary),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                text,
                style: GoogleFonts.afacad(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: kTextSecondary,
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

  // ==================== STATE WIDGETS ====================
  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.all(60),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: kPrimaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Padding(
              padding: EdgeInsets.all(12),
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(kPrimaryColor),
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
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: kBorderColor),
      ),
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: const BoxDecoration(
              color: kBackgroundColor,
              shape: BoxShape.circle,
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
              fontWeight: FontWeight.w700,
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
              setState(() => _selectedCategoryIndex = 0);
              context.read<MerchantProvider>().clearCategory();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 16,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
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

  // ==================== BOTTOM NAV BAR ====================
  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: kCardColor,
        border: Border(top: BorderSide(color: kBorderColor)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(CupertinoIcons.house_fill, 'Home', true),
              _buildNavItem(CupertinoIcons.compass_fill, 'Explore', false),
              _buildNavItem(CupertinoIcons.heart, 'Favorites', false),
              _buildNavItem(CupertinoIcons.person_fill, 'Profile', false),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool selected) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        // Handle navigation
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: selected ? kPrimaryColor : kTextSecondary,
              size: 26,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.afacad(
                color: selected ? kPrimaryColor : kTextSecondary,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== CUSTOM CLIPPER ====================
class HeaderCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 40);

    final firstControlPoint = Offset(size.width * 0.25, size.height);
    final firstEndPoint = Offset(size.width * 0.5, size.height);

    path.quadraticBezierTo(
      firstControlPoint.dx,
      firstControlPoint.dy,
      firstEndPoint.dx,
      firstEndPoint.dy,
    );

    final secondControlPoint = Offset(size.width * 0.75, size.height);
    final secondEndPoint = Offset(size.width, size.height - 40);

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
