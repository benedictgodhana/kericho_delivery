import 'package:flutter/material.dart';
import 'package:kericho_delivery/data/models/merchant_model.dart';
import 'package:provider/provider.dart';
import 'package:kericho_delivery/presentation/providers/app_provider.dart';
import 'package:kericho_delivery/presentation/providers/location_provider.dart';
import 'package:kericho_delivery/presentation/providers/merchant_provider.dart';
import 'package:kericho_delivery/presentation/router/app_router.dart';
import 'package:kericho_delivery/core/theme/app_theme.dart';
import 'package:carousel_slider/carousel_slider.dart' as carousel_slider;
import 'package:cached_network_image/cached_network_image.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _currentCarouselIndex = 0;
  int _selectedCategoryIndex = 0;
  bool _isRefreshingLocation = false;

  final List<CategoryItem> _categories = [
    CategoryItem(
      name: 'Fast Food',
      icon: Icons.fastfood,
      emoji: '🍔',
      image: 'assets/images/fast_food.jpg',
      tag: 'FastFood',
      color: Color(0xFFFF6B35),
    ),
    CategoryItem(
      name: 'Groceries',
      icon: Icons.shopping_basket,
      emoji: '🛒',
      image: 'assets/images/a776e7d9-d788-4112-810a-dc0945c0071e.jpg',
      tag: 'Grocery',
      color: Color(0xFF34C759),
    ),
    CategoryItem(
      name: 'Tea & Coffee',
      icon: Icons.local_cafe,
      emoji: '☕',
      image: 'assets/images/tea.jpg',
      tag: 'Cafe',
      color: Color(0xFF8B4513),
    ),
    CategoryItem(
      name: 'Restaurants',
      icon: Icons.restaurant,
      emoji: '🍽️',
      image: 'assets/images/fresh-vegetables-fruit-market-stall.jpg',
      tag: 'Restaurant',
      color: Color(0xFFFF9500),
    ),
    CategoryItem(
      name: 'Pharmacy',
      icon: Icons.local_pharmacy,
      emoji: '💊',
      image: 'assets/images/fresh-vegetables-fruit-market-stall.jpg',
      tag: 'Pharmacy',
      color: Color(0xFF5856D6),
    ),
    CategoryItem(
      name: 'Bakery',
      icon: Icons.cake,
      emoji: '🍰',
      image: 'assets/images/a776e7d9-d788-4112-810a-dc0945c0071e.jpg',
      tag: 'Bakery',
      color: Color(0xFFFFD700),
    ),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeLocation();
    });
  }

  void _initializeLocation() async {
    final locationProvider =
        Provider.of<LocationProvider>(context, listen: false);
    if (locationProvider.currentLocation == null) {
      await locationProvider.getCurrentLocation();
    }
  }

  Future<void> _refreshLocation() async {
    setState(() {
      _isRefreshingLocation = true;
    });
    
    final locationProvider =
        Provider.of<LocationProvider>(context, listen: false);
    
    try {
      await locationProvider.getCurrentLocation();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Location updated successfully!',
            style: TextStyle(
              fontFamily: 'Legend',
              fontWeight: FontWeight.w500,
            ),
          ),
          backgroundColor: AppTheme.primaryColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to update location: $e',
            style: TextStyle(
              fontFamily: 'Legend',
              fontWeight: FontWeight.w500,
            ),
          ),
          backgroundColor: Color(0xFFFF3B30),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } finally {
      setState(() {
        _isRefreshingLocation = false;
      });
    }
  }

  void _navigateToMerchant(String merchantId, String merchantName) {
    AppRouter.pushNamed(
      AppRouter.merchant,
      arguments: {
        'merchantId': merchantId,
        'merchantName': merchantName,
      },
    );
  }

  void _navigateToCart() {
    AppRouter.pushNamed(AppRouter.cart);
  }

  void _navigateToProfile() {
    AppRouter.pushNamed(AppRouter.profile);
  }

  void _navigateToOrderHistory() {
    if (AppRouter.orderHistory != null) {
      AppRouter.pushNamed(AppRouter.orderHistory!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final locationProvider = Provider.of<LocationProvider>(context);
    final merchantProvider = Provider.of<MerchantProvider>(context);

    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // TALLER Curved Header with Enhanced Location
              Stack(
                children: [
                  // TALLER Curved Background Image - INCREASED HEIGHT
                  ClipPath(
                    clipper: CurvedHeaderClipper(),
                    child: Container(
                      height: 280, // INCREASED from 240 to 280
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/images/fast_food.jpg'),
                          fit: BoxFit.cover,
                          colorFilter: ColorFilter.mode(
                            Colors.black.withOpacity(0.6),
                            BlendMode.darken,
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  // Content Overlay
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20), // Increased vertical padding
                    child: Column(
                      children: [
                        // Enhanced App Bar with Location
                        Row(
                          children: [
                            // Location with Enhanced Features
                            Expanded(
                              child: GestureDetector(
                                onTap: _refreshLocation,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 14), // Increased vertical padding
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.4),
                                      width: 1.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 15,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      Stack(
                                        children: [
                                          Icon(
                                            Icons.location_on,
                                            color: Colors.white,
                                            size: 22, // Slightly larger icon
                                          ),
                                          if (_isRefreshingLocation)
                                            Positioned(
                                              right: 0,
                                              top: 0,
                                              child: Container(
                                                width: 8,
                                                height: 8,
                                                decoration: BoxDecoration(
                                                  color: AppTheme.primaryColor,
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  '📍 DELIVERING TO',
                                                  style: TextStyle(
                                                    fontFamily: 'Legend',
                                                    fontSize: 11, // Slightly larger
                                                    fontWeight: FontWeight.w700,
                                                    color: Colors.white.withOpacity(0.9),
                                                    letterSpacing: 1.0,
                                                  ),
                                                ),
                                                const SizedBox(width: 6),
                                                // Check if location is accurate
                                                if (_isRefreshingLocation == false && 
                                                    locationProvider.currentLocation != null)
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(
                                                        horizontal: 8, vertical: 3), // Slightly larger
                                                    decoration: BoxDecoration(
                                                      color: Color(0xFF34C759).withOpacity(0.8),
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                    child: Text(
                                                      'ACTIVE',
                                                      style: TextStyle(
                                                        fontFamily: 'Legend',
                                                        fontSize: 9, // Slightly larger
                                                        fontWeight: FontWeight.w700,
                                                        color: Colors.white,
                                                        letterSpacing: 0.8,
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                            const SizedBox(height: 6), // Increased spacing
                                            Text(
                                              locationProvider.currentLocation?.address ??
                                                  'Kericho, Kenya',
                                              style: TextStyle(
                                                fontFamily: 'Legend',
                                                fontSize: 16, // Increased from 14
                                                fontWeight: FontWeight.w800,
                                                color: Colors.white,
                                                letterSpacing: 0.2,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 4), // Increased spacing
                                            Text(
                                              'Tap to refresh location',
                                              style: TextStyle(
                                                fontFamily: 'Legend',
                                                fontSize: 11, // Slightly larger
                                                fontWeight: FontWeight.w500,
                                                color: Colors.white.withOpacity(0.8),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (!_isRefreshingLocation)
                                        Icon(
                                          Icons.refresh,
                                          color: Colors.white.withOpacity(0.8),
                                          size: 20, // Slightly larger
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(width: 12),

                            // Enhanced Action Buttons
                            Row(
                              children: [
                                // Notification Bell
                                Container(
                                  width: 46, // Increased size
                                  height: 46, // Increased size
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(14), // Slightly larger
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.4),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Stack(
                                    children: [
                                      Center(
                                        child: Icon(
                                          Icons.notifications_outlined,
                                          color: Colors.white,
                                          size: 22, // Slightly larger
                                        ),
                                      ),
                                      Positioned(
                                        right: 7,
                                        top: 7,
                                        child: Container(
                                          width: 9, // Slightly larger
                                          height: 9, // Slightly larger
                                          decoration: BoxDecoration(
                                            color: Color(0xFFFF3B30),
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Colors.white,
                                              width: 1.5,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(width: 12),

                                // Cart Button
                                Stack(
                                  children: [
                                    Container(
                                      width: 46, // Increased size
                                      height: 46, // Increased size
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(14), // Slightly larger
                                        border: Border.all(
                                          color: Colors.white.withOpacity(0.4),
                                          width: 1.5,
                                        ),
                                      ),
                                      child: IconButton(
                                        icon: Icon(
                                          Icons.shopping_bag_outlined,
                                          color: Colors.white,
                                          size: 22, // Slightly larger
                                        ),
                                        onPressed: _navigateToCart,
                                      ),
                                    ),
                                    if (appProvider.cartItemCount > 0)
                                      Positioned(
                                        right: -2,
                                        top: -2,
                                        child: Container(
                                          padding: const EdgeInsets.all(5), // Slightly larger
                                          decoration: BoxDecoration(
                                            color: Color(0xFFFF3B30),
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Colors.white,
                                              width: 2,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.red.withOpacity(0.3),
                                                blurRadius: 6,
                                                spreadRadius: 1,
                                              ),
                                            ],
                                          ),
                                          child: Text(
                                            appProvider.cartItemCount > 9
                                                ? '9+'
                                                : appProvider.cartItemCount.toString(),
                                            style: TextStyle(
                                              fontFamily: 'Legend',
                                              fontSize: 9, // Slightly larger
                                              color: Colors.white,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 32), // Increased spacing

                        // Welcome Section - ENHANCED for taller header
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: 'HELLO, ',
                                            style: TextStyle(
                                              fontFamily: 'Legend',
                                              fontSize: 30, // Increased from 26
                                              fontWeight: FontWeight.w900,
                                              color: Colors.white,
                                              letterSpacing: 0.6,
                                              shadows: [
                                                Shadow(
                                                  color: Colors.black.withOpacity(0.4),
                                                  blurRadius: 15,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                          ),
                                          TextSpan(
                                            text: appProvider.user?.fullName
                                                        ?.split(' ')
                                                        .first
                                                        .toUpperCase() ??
                                                'FOODIE',
                                            style: TextStyle(
                                              fontFamily: 'Legend',
                                              fontSize: 30, // Increased from 26
                                              fontWeight: FontWeight.w900,
                                              color: Color(0xFFFFD600),
                                              letterSpacing: 0.6,
                                              shadows: [
                                                Shadow(
                                                  color: Colors.black.withOpacity(0.4),
                                                  blurRadius: 15,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                          ),
                                          TextSpan(
                                            text: '!',
                                            style: TextStyle(
                                              fontFamily: 'Legend',
                                              fontSize: 30, // Increased from 26
                                              fontWeight: FontWeight.w900,
                                              color: Colors.white,
                                              letterSpacing: 0.6,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 10), // Increased spacing
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.star,
                                          size: 16, // Slightly larger
                                          color: Color(0xFFFFD600),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Premium Member',
                                          style: TextStyle(
                                            fontFamily: 'Legend',
                                            fontSize: 14, // Increased from 12
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white.withOpacity(0.9),
                                            letterSpacing: 0.2,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8), // Increased spacing
                                    Text(
                                      '🍕 What delicious meal are you craving today? 🍔',
                                      style: TextStyle(
                                        fontFamily: 'Legend',
                                        fontSize: 14, // Increased from 12
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white.withOpacity(0.9),
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: 80, // Increased from 65
                                height: 80, // Increased from 65
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.25),
                                  borderRadius: BorderRadius.circular(22), // Slightly larger
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.4),
                                    width: 2.5, // Thicker border
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
                                      blurRadius: 15,
                                      spreadRadius: 3,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.local_pizza,
                                  color: Colors.white,
                                  size: 38, // Larger icon
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

              // Search Bar with Enhanced Design - ADJUSTED MARGIN
              Padding(
                padding: const EdgeInsets.only(
                    left: 20, right: 20, top: 30, bottom: 8), // Increased top margin
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryColor.withOpacity(0.12),
                        blurRadius: 20,
                        spreadRadius: 2,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: '🔍 Search restaurants, groceries, pizza...',
                      hintStyle: TextStyle(
                        fontFamily: 'Legend',
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[500],
                        letterSpacing: 0.2,
                      ),
                      prefixIcon: Container(
                        margin: const EdgeInsets.only(left: 12),
                        child: Icon(
                          Icons.search_rounded,
                          color: AppTheme.primaryColor,
                          size: 22,
                        ),
                      ),
                      suffixIcon: Container(
                        margin: const EdgeInsets.only(right: 8),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.qr_code_scanner_rounded,
                                color: AppTheme.primaryColor,
                                size: 20,
                              ),
                              onPressed: () {
                                // TODO: Open QR Scanner
                              },
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.tune_rounded,
                                color: AppTheme.primaryColor,
                                size: 20,
                              ),
                              onPressed: () {
                                // TODO: Open filters
                              },
                            ),
                          ],
                        ),
                      ),
                      border: InputBorder.none,
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 16,
                      ),
                    ),
                    style: TextStyle(
                      fontFamily: 'Legend',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                    onChanged: (value) {
                      merchantProvider.searchMerchants(value);
                    },
                  ),
                ),
              ),

              // Quick Action Chips
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: SizedBox(
                  height: 36,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    children: [
                      _buildQuickActionChip('🚚 Free Delivery', Icons.local_shipping),
                      const SizedBox(width: 8),
                      _buildQuickActionChip('⭐ Top Rated', Icons.star),
                      const SizedBox(width: 8),
                      _buildQuickActionChip('⚡ Fast', Icons.flash_on),
                      const SizedBox(width: 8),
                      _buildQuickActionChip('💳 Pay', Icons.credit_card),
                    ],
                  ),
                ),
              ),

              // Food Promo Carousel
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  children: [
                    carousel_slider.CarouselSlider(
                      options: carousel_slider.CarouselOptions(
                        height: 160,
                        viewportFraction: 0.88,
                        autoPlay: true,
                        autoPlayInterval: const Duration(seconds: 6),
                        autoPlayCurve: Curves.fastOutSlowIn,
                        onPageChanged: (index, reason) {
                          setState(() => _currentCarouselIndex = index);
                        },
                      ),
                      items: [
                        _buildFoodPromoCard(
                          '🎉 FREE DELIVERY',
                          'First order • Use code: WELCOME50',
                          Color(0xFFFF6B35),
                          Icons.local_shipping,
                        ),
                        _buildFoodPromoCard(
                          '🍕 30% OFF PIZZA',
                          'Order above KSh 500 • Until Friday',
                          Color(0xFF5856D6),
                          Icons.local_pizza,
                        ),
                        _buildFoodPromoCard(
                          '☕ BUY 1 GET 1',
                          'Kericho Tea • All day offer',
                          AppTheme.primaryColor,
                          Icons.local_cafe,
                        ),
                      ],
                    ),

                    // Enhanced Carousel Indicators
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [0, 1, 2].map((index) {
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: _currentCarouselIndex == index ? 28 : 10,
                          height: 6,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            gradient: _currentCarouselIndex == index
                                ? LinearGradient(
                                    colors: [
                                      AppTheme.primaryColor,
                                      Color(0xFFFFD600),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  )
                                : LinearGradient(
                                    colors: [
                                      Colors.grey[300]!,
                                      Colors.grey[400]!,
                                    ],
                                  ),
                            boxShadow: _currentCarouselIndex == index
                                ? [
                                    BoxShadow(
                                      color: AppTheme.primaryColor.withOpacity(0.3),
                                      blurRadius: 8,
                                      spreadRadius: 1,
                                    ),
                                  ]
                                : null,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

              // Food Categories
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '🍴 CATEGORIES',
                          style: TextStyle(
                            fontFamily: 'Legend',
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: Colors.grey[900],
                            letterSpacing: 0.6,
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () {
                            // TODO: View all categories
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppTheme.primaryColor.withOpacity(0.1),
                                  Color(0xFF34C759).withOpacity(0.1),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  'VIEW ALL',
                                  style: TextStyle(
                                    fontFamily: 'Legend',
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.primaryColor,
                                    letterSpacing: 0.6,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  size: 12,
                                  color: AppTheme.primaryColor,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 140,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        children: _categories.asMap().entries.map((entry) {
                          final index = entry.key;
                          final category = entry.value;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedCategoryIndex = index;
                              });
                              merchantProvider.filterByCategory(category.tag);
                            },
                            child: Container(
                              width: 120,
                              margin: EdgeInsets.only(
                                right: index == _categories.length - 1 ? 0 : 15,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(
                                        _selectedCategoryIndex == index
                                            ? 0.2
                                            : 0.1),
                                    blurRadius: 15,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Stack(
                                  children: [
                                    // Background with Gradient
                                    Positioned.fill(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              category.color.withOpacity(0.9),
                                              category.color.withOpacity(0.7),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),

                                    // Image Overlay
                                    Positioned.fill(
                                      child: Opacity(
                                        opacity: 0.15,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            image: DecorationImage(
                                              image: AssetImage(category.image),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),

                                    // Content
                                    Positioned.fill(
                                      child: Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              Colors.transparent,
                                              Colors.black.withOpacity(0.4),
                                            ],
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(
                                              width: 45,
                                              height: 45,
                                              decoration: BoxDecoration(
                                                color: Colors.white
                                                    .withOpacity(0.25),
                                                borderRadius:
                                                    BorderRadius.circular(14),
                                                border: Border.all(
                                                  color: Colors.white
                                                      .withOpacity(0.4),
                                                  width: 1.5,
                                                ),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  category.emoji,
                                                  style: TextStyle(
                                                    fontSize: 26,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  category.name,
                                                  style: TextStyle(
                                                    fontFamily:
                                                        'Legend',
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w900,
                                                    color: Colors.white,
                                                    letterSpacing: 0.4,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  'Discover →',
                                                  style: TextStyle(
                                                    fontFamily:
                                                        'Legend',
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.white
                                                        .withOpacity(0.9),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),

                                    // Selection Effect
                                    if (_selectedCategoryIndex == index)
                                      Positioned.fill(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            border: Border.all(
                                              color: Colors.white,
                                              width: 3,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.white
                                                    .withOpacity(0.3),
                                                blurRadius: 15,
                                                spreadRadius: 3,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),

              // Featured Restaurants with Enhanced Design
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '⭐ FEATURED',
                          style: TextStyle(
                            fontFamily: 'Legend',
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: Colors.grey[900],
                            letterSpacing: 0.6,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppTheme.primaryColor,
                                Color(0xFFFFD600),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Text(
                                'VIEW ALL',
                                style: TextStyle(
                                  fontFamily: 'Legend',
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 11,
                                  letterSpacing: 0.6,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.arrow_forward_rounded,
                                color: Colors.white,
                                size: 14,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ...merchantProvider.getFeaturedMerchants().map((merchant) {
                      return _buildFoodMerchantCard(merchant);
                    }),
                  ],
                ),
              ),

              // All Restaurants by Category
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '🍽️ NEAR YOU',
                          style: TextStyle(
                            fontFamily: 'Legend',
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: Colors.grey[900],
                            letterSpacing: 0.6,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: AppTheme.primaryColor.withOpacity(0.2),
                              width: 1.2,
                            ),
                          ),
                          child: Text(
                            '${merchantProvider.merchants.length} SHOPS',
                            style: TextStyle(
                              fontFamily: 'Legend',
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.primaryColor,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Enhanced Category Filter
                    SizedBox(
                      height: 55,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        children: merchantProvider.categories.map((category) {
                          final icon = _getCategoryIcon(category);
                          final isSelected =
                              merchantProvider.selectedCategory == category;
                          return GestureDetector(
                            onTap: () {
                              merchantProvider.filterByCategory(category);
                            },
                            child: Container(
                              margin: const EdgeInsets.only(right: 10),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 18, vertical: 12),
                              decoration: BoxDecoration(
                                gradient: isSelected
                                    ? LinearGradient(
                                        colors: [
                                          AppTheme.primaryColor,
                                          Color(0xFFFFD600),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      )
                                    : LinearGradient(
                                        colors: [
                                          Colors.white,
                                          Colors.grey[50]!,
                                        ],
                                      ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(
                                        isSelected ? 0.15 : 0.06),
                                    blurRadius: 12,
                                    spreadRadius: 1,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                                border: Border.all(
                                  color: isSelected
                                      ? AppTheme.primaryColor.withOpacity(0.2)
                                      : Colors.grey[200]!,
                                  width: 1.2,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    icon,
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    category.toUpperCase(),
                                    style: TextStyle(
                                      fontFamily: 'Legend',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.grey[700],
                                      letterSpacing: 0.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Merchant List
                    merchantProvider.isLoading
                        ? _buildFoodLoadingState()
                        : merchantProvider.merchants.isEmpty
                            ? _buildFoodEmptyState()
                            : Column(
                                children:
                                    merchantProvider.merchants.map((merchant) {
                                  return _buildFoodMerchantCard(merchant);
                                }).toList(),
                              ),
                  ],
                ),
              ),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),

      // Enhanced Bottom Navigation Bar
      bottomNavigationBar: Container(
        height: 80,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 25,
              spreadRadius: 3,
              offset: const Offset(0, -8),
            ),
          ],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildEnhancedBottomNavItem(Icons.home_filled, 'Home', true),
            _buildEnhancedBottomNavItem(Icons.history, 'Orders', false,
                onTap: _navigateToOrderHistory),
            _buildEnhancedBottomNavItem(Icons.explore, 'Explore', false),
            _buildEnhancedBottomNavItem(Icons.person, 'Profile', false,
                onTap: _navigateToProfile),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionChip(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primaryColor.withOpacity(0.2),
          width: 1.2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: AppTheme.primaryColor,
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontFamily: 'Legend',
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppTheme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodPromoCard(
      String title, String subtitle, Color color, IconData icon) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color,
            color.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: 25,
            spreadRadius: 3,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Legend',
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 0.4,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: 'Legend',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withOpacity(0.9),
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.25),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: Colors.white.withOpacity(0.4),
                  width: 2,
                ),
              ),
              child: Icon(
                icon,
                size: 32,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFoodMerchantCard(MerchantModel merchant) {
    return GestureDetector(
      onTap: () => _navigateToMerchant(merchant.id, merchant.name),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              spreadRadius: 2,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Merchant Image with Enhanced Badges
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(25),
                    topRight: Radius.circular(25),
                  ),
                  child: Container(
                    height: 180,
                    width: double.infinity,
                    color: Colors.grey[200],
                    child: merchant.imageUrl != null
                        ? CachedNetworkImage(
                            imageUrl: merchant.imageUrl!,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.grey[200]!,
                                    Colors.grey[300]!,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.grey[200]!,
                                    Colors.grey[300]!,
                                  ],
                                ),
                              ),
                              child: const Icon(
                                Icons.restaurant,
                                size: 60,
                                color: Colors.grey,
                              ),
                            ),
                          )
                        : Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.grey[200]!,
                                  Colors.grey[300]!,
                                ],
                              ),
                            ),
                            child: const Icon(
                              Icons.restaurant,
                              size: 60,
                              color: Colors.grey,
                            ),
                          ),
                  ),
                ),

                // Gradient Overlay
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(25),
                        topRight: Radius.circular(25),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.4),
                        ],
                      ),
                    ),
                  ),
                ),

                // Status Badge
                Positioned(
                  top: 16,
                  left: 16,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: merchant.isOpen
                          ? LinearGradient(
                              colors: [
                                Color(0xFF34C759),
                                Color(0xFF2ECC71),
                              ],
                            )
                          : LinearGradient(
                              colors: [
                                Color(0xFFFF3B30),
                                Color(0xFFFF6B6B),
                              ],
                            ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.25),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(
                          merchant.isOpen
                              ? Icons.check_circle
                              : Icons.cancel_rounded,
                          size: 14,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          merchant.isOpen ? 'OPEN' : 'CLOSED',
                          style: TextStyle(
                            fontFamily: 'Legend',
                            fontSize: 11,
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Featured Badge
                if (merchant.isFeatured)
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFFFFD600),
                            Color(0xFFFF9500),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.orange.withOpacity(0.3),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.star_rounded,
                            size: 14,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'FEATURED',
                            style: TextStyle(
                              fontFamily: 'Legend',
                              fontSize: 11,
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Bottom Info Bar
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Rating
                      Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.12),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.star_rounded,
                              size: 16,
                              color: Color(0xFFFF9500),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              merchant.rating.toStringAsFixed(1),
                              style: TextStyle(
                                fontFamily: 'Legend',
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                color: Colors.grey[900],
                              ),
                            ),
                            Text(
                              ' (${merchant.ratingCount})',
                              style: TextStyle(
                                fontFamily: 'Legend',
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Delivery Info
                      Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.primaryColor,
                              Color(0xFF34C759),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryColor.withOpacity(0.3),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.delivery_dining_rounded,
                              size: 16,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${merchant.deliveryTime} MIN',
                              style: TextStyle(
                                fontFamily: 'Legend',
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
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

            // Merchant Details
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              merchant.name.toUpperCase(),
                              style: TextStyle(
                                fontFamily: 'Legend',
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: Colors.grey[900],
                                letterSpacing: 0.4,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  size: 14,
                                  color: AppTheme.primaryColor,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    'Kericho, Kenya',
                                    style: TextStyle(
                                      fontFamily: 'Legend',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey[600],
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Favorite Button
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: Provider.of<AppProvider>(context)
                                  .isFavorite(merchant.id)
                              ? Color(0xFFFF3B30).withOpacity(0.1)
                              : Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey[200]!,
                            width: 1.2,
                          ),
                        ),
                        child: IconButton(
                          icon: Icon(
                            Provider.of<AppProvider>(context)
                                    .isFavorite(merchant.id)
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            color: Provider.of<AppProvider>(context)
                                    .isFavorite(merchant.id)
                                ? Color(0xFFFF3B30)
                                : Colors.grey[400],
                            size: 22,
                          ),
                          onPressed: () {
                            Provider.of<AppProvider>(context, listen: false)
                                .toggleFavorite(merchant);
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  Text(
                    merchant.description,
                    style: TextStyle(
                      fontFamily: 'Legend',
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 16),

                  // Food Tags
                  if (merchant.tags != null && merchant.tags!.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: merchant.tags!.map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppTheme.primaryColor.withOpacity(0.2),
                              width: 1.2,
                            ),
                          ),
                          child: Text(
                            '#${tag.toUpperCase()}',
                            style: TextStyle(
                              fontFamily: 'Legend',
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.primaryColor,
                              letterSpacing: 0.4,
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                  // Additional Info - FIXED OVERFLOW
                  const SizedBox(height: 16),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildEnhancedInfoChip(
                          Icons.monetization_on_rounded,
                          'Delivery: KSh ${merchant.deliveryFee.toInt()}',
                          Color(0xFF34C759),
                        ),
                        const SizedBox(width: 12),
                        _buildEnhancedInfoChip(
                          Icons.shopping_bag_rounded,
                          'Min: KSh ${merchant.minimumOrder?.toInt() ?? 0}',
                          Color(0xFF5856D6),
                        ),
                        const SizedBox(width: 12),
                        _buildEnhancedInfoChip(
                          Icons.phone,
                          'Call Now',
                          Color(0xFFFF9500),
                        ),
                      ],
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

  Widget _buildFoodLoadingState() {
    return Container(
      padding: const EdgeInsets.all(50),
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryColor,
                  Color(0xFFFFD600),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 3,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            '🍳 PREPARING YOUR FOOD OPTIONS...',
            style: TextStyle(
              fontFamily: 'Legend',
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: Colors.grey[800],
              letterSpacing: 0.8,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Fresh meals are being prepared!',
            style: TextStyle(
              fontFamily: 'Legend',
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
              letterSpacing: 0.2,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFoodEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.grey[100]!,
                  Colors.grey[200]!,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '🍕',
                style: TextStyle(fontSize: 70),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'NO RESTAURANTS FOUND',
            style: TextStyle(
              fontFamily: 'Legend',
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Colors.grey[900],
              letterSpacing: 0.8,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Try adjusting your search or explore different categories',
            style: TextStyle(
              fontFamily: 'Legend',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
              letterSpacing: 0.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Provider.of<MerchantProvider>(context, listen: false)
                  .clearCategory();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 25, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 6,
              shadowColor: AppTheme.primaryColor.withOpacity(0.3),
            ),
            child: Text(
              'EXPLORE ALL',
              style: TextStyle(
                fontFamily: 'Legend',
                fontSize: 13,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.8,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedBottomNavItem(
      IconData icon, String label, bool isActive,
      {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        decoration: BoxDecoration(
          gradient: isActive
              ? LinearGradient(
                  colors: [
                    AppTheme.primaryColor.withOpacity(0.15),
                    AppTheme.primaryColor.withOpacity(0.05),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                )
              : null,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                gradient: isActive
                    ? LinearGradient(
                        colors: [
                          AppTheme.primaryColor,
                          Color(0xFFFFD600),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : LinearGradient(
                        colors: [
                          Colors.grey.withOpacity(0.1),
                          Colors.grey.withOpacity(0.05),
                        ],
                      ),
                shape: BoxShape.circle,
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: AppTheme.primaryColor.withOpacity(0.3),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                icon,
                color: isActive ? Colors.white : Colors.grey[500],
                size: 22,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Legend',
                fontSize: 11,
                color: isActive ? AppTheme.primaryColor : Colors.grey[500],
                fontWeight: isActive ? FontWeight.w900 : FontWeight.w600,
                letterSpacing: 0.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedInfoChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1.2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                fontFamily: 'Legend',
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: color,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'fastfood':
        return '🍔';
      case 'grocery':
        return '🛒';
      case 'cafe':
        return '☕';
      case 'restaurant':
        return '🍽️';
      case 'pharmacy':
        return '💊';
      case 'bakery':
        return '🍰';
      default:
        return '🏪';
    }
  }
}

class CategoryItem {
  final String name;
  final IconData icon;
  final String emoji;
  final String image;
  final String tag;
  final Color color;

  CategoryItem({
    required this.name,
    required this.icon,
    required this.emoji,
    required this.image,
    required this.tag,
    required this.color,
  });
}

// Custom clipper for curved header - ADJUSTED for taller curve
class CurvedHeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 50); // Increased curve height
    path.quadraticBezierTo(
      size.width / 2,
      size.height + 10, // More pronounced curve
      size.width,
      size.height - 50, // Increased curve height
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}