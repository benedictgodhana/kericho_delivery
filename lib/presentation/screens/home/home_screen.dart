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
              // Header with Food Background
              Container(
                height: 220,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/fast_food.jpg'),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(0.5),
                      BlendMode.darken,
                    ),
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Column(
                    children: [
                      // App Bar
                      Row(
                        children: [
                          // Location with food icon
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                // TODO: Open location picker
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 10),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.3),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.location_on,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'DELIVERING TO',
                                            style: TextStyle(
                                              fontFamily: 'BrandonGrotesque',
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white.withOpacity(0.8),
                                              letterSpacing: 1.0,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            locationProvider.currentLocation?.address ??
                                                'Kericho, Kenya',
                                            style: TextStyle(
                                              fontFamily: 'BrandonGrotesque',
                                              fontSize: 15,
                                              fontWeight: FontWeight.w800,
                                              color: Colors.white,
                                              letterSpacing: 0.3,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 12),

                          // Cart & Profile
                          Row(
                            children: [
                              // Cart with food-themed badge
                              Stack(
                                children: [
                                  Container(
                                    width: 45,
                                    height: 45,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.3),
                                      ),
                                    ),
                                    child: IconButton(
                                      icon: Icon(
                                        Icons.shopping_bag_outlined,
                                        color: Colors.white,
                                        size: 22,
                                      ),
                                      onPressed: _navigateToCart,
                                    ),
                                  ),
                                  if (appProvider.cartItemCount > 0)
                                    Positioned(
                                      right: -2,
                                      top: -2,
                                      child: Container(
                                        padding: const EdgeInsets.all(6),
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
                                              blurRadius: 5,
                                              spreadRadius: 1,
                                            ),
                                          ],
                                        ),
                                        child: Text(
                                          appProvider.cartItemCount > 9
                                              ? '9+'
                                              : appProvider.cartItemCount.toString(),
                                          style: TextStyle(
                                            fontFamily: 'BrandonGrotesque',
                                            fontSize: 10,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),

                              const SizedBox(width: 12),

                              // Profile with food avatar
                              GestureDetector(
                                onTap: _navigateToProfile,
                                child: Container(
                                  width: 45,
                                  height: 45,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.3),
                                    ),
                                  ),
                                  child: appProvider.user?.profileImage != null
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(12),
                                          child: Image.network(
                                            appProvider.user!.profileImage!,
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : Icon(
                                          Icons.person,
                                          color: Colors.white,
                                          size: 22,
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Welcome Text with Food Theme
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
                                            fontFamily: 'BrandonGrotesque',
                                            fontSize: 28,
                                            fontWeight: FontWeight.w900,
                                            color: Colors.white,
                                            letterSpacing: 0.5,
                                            shadows: [
                                              Shadow(
                                                color: Colors.black.withOpacity(0.3),
                                                blurRadius: 10,
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
                                            fontFamily: 'BrandonGrotesque',
                                            fontSize: 28,
                                            fontWeight: FontWeight.w900,
                                            color: Color(0xFFFFD600),
                                            letterSpacing: 0.5,
                                            shadows: [
                                              Shadow(
                                                color: Colors.black.withOpacity(0.3),
                                                blurRadius: 10,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                        ),
                                        TextSpan(
                                          text: '!',
                                          style: TextStyle(
                                            fontFamily: 'BrandonGrotesque',
                                            fontSize: 28,
                                            fontWeight: FontWeight.w900,
                                            color: Colors.white,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '🍕 What delicious meal are you craving today? 🍔',
                                    style: TextStyle(
                                      fontFamily: 'BrandonGrotesque',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white.withOpacity(0.9),
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.local_pizza,
                                color: Colors.white,
                                size: 36,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Search Bar - Food Themed
              Padding(
                padding: const EdgeInsets.only(
                    left: 20, right: 20, top: 25, bottom: 8),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        spreadRadius: 2,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: '🔍 Search for restaurants, groceries, pizza...',
                      hintStyle: TextStyle(
                        fontFamily: 'BrandonGrotesque',
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[500],
                        letterSpacing: 0.3,
                      ),
                      prefixIcon: Container(
                        margin: const EdgeInsets.only(left: 15),
                        child: Icon(
                          Icons.search_rounded,
                          color: AppTheme.primaryColor,
                          size: 24,
                        ),
                      ),
                      suffixIcon: Container(
                        margin: const EdgeInsets.only(right: 10),
                        child: IconButton(
                          icon: Icon(
                            Icons.tune_rounded,
                            color: AppTheme.primaryColor,
                            size: 24,
                          ),
                          onPressed: () {
                            // TODO: Open filters
                          },
                        ),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 18,
                        horizontal: 20,
                      ),
                    ),
                    style: TextStyle(
                      fontFamily: 'BrandonGrotesque',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                    onChanged: (value) {
                      merchantProvider.searchMerchants(value);
                    },
                  ),
                ),
              ),

              // Food Promo Carousel
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 25),
                child: Column(
                  children: [
                    carousel_slider.CarouselSlider(
                      options: carousel_slider.CarouselOptions(
                        height: 170,
                        viewportFraction: 0.88,
                        autoPlay: true,
                        autoPlayInterval: const Duration(seconds: 5),
                        autoPlayCurve: Curves.fastOutSlowIn,
                        onPageChanged: (index, reason) {
                          setState(() => _currentCarouselIndex = index);
                        },
                      ),
                      items: [
                        _buildFoodPromoCard(
                          '🎉 FIRST ORDER FREE DELIVERY',
                          'Use code: FOODLOVE',
                          Color(0xFFFF6B35),
                          Icons.local_shipping,
                        ),
                        _buildFoodPromoCard(
                          '🍕 20% OFF ON PIZZA ORDERS',
                          'Valid until Friday',
                          Color(0xFF5856D6),
                          Icons.local_pizza,
                        ),
                        _buildFoodPromoCard(
                          '☕ FREE TEA WITH KSH 500+ ORDER',
                          'Kericho Special Blend',
                          AppTheme.primaryColor,
                          Icons.local_cafe,
                        ),
                      ],
                    ),

                    // Food-themed Carousel Indicators
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [0, 1, 2].map((index) {
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: _currentCarouselIndex == index ? 30 : 10,
                          height: 8,
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
                          '🍴 EXPLORE CATEGORIES',
                          style: TextStyle(
                            fontFamily: 'BrandonGrotesque',
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Colors.grey[900],
                            letterSpacing: 0.5,
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 16,
                          color: Colors.grey[500],
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      height: 150,
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
                              width: 130,
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
                                    // Background Image with Gradient
                                    Positioned.fill(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              category.color.withOpacity(0.8),
                                              category.color.withOpacity(0.6),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),

                                    // Food Pattern Overlay
                                    Positioned.fill(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                            image: AssetImage(category.image),
                                            fit: BoxFit.cover,
                                            colorFilter: ColorFilter.mode(
                                              Colors.black.withOpacity(0.2),
                                              BlendMode.darken,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),

                                    // Content
                                    Positioned.fill(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              Colors.transparent,
                                              Colors.black.withOpacity(0.3),
                                            ],
                                          ),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(18),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                width: 50,
                                                height: 50,
                                                decoration: BoxDecoration(
                                                  color: Colors.white
                                                      .withOpacity(0.2),
                                                  borderRadius:
                                                      BorderRadius.circular(15),
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    category.emoji,
                                                    style: TextStyle(
                                                      fontSize: 28,
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
                                                          'BrandonGrotesque',
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w800,
                                                      color: Colors.white,
                                                      letterSpacing: 0.5,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    'Order Now →',
                                                    style: TextStyle(
                                                      fontFamily:
                                                          'BrandonGrotesque',
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w600,
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
                                    ),

                                    // Selection Border
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
                                                spreadRadius: 2,
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

              // Featured Restaurants
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '⭐ FEATURED IN KERICHO',
                          style: TextStyle(
                            fontFamily: 'BrandonGrotesque',
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Colors.grey[900],
                            letterSpacing: 0.5,
                          ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () {
                            // TODO: View all featured
                          },
                          child: Row(
                            children: [
                              Text(
                                'VIEW ALL',
                                style: TextStyle(
                                  fontFamily: 'BrandonGrotesque',
                                  color: AppTheme.primaryColor,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                  letterSpacing: 0.8,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.arrow_forward_rounded,
                                color: AppTheme.primaryColor,
                                size: 16,
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
                          '🍽️ ALL RESTAURANTS',
                          style: TextStyle(
                            fontFamily: 'BrandonGrotesque',
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Colors.grey[900],
                            letterSpacing: 0.5,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${merchantProvider.merchants.length} SHOPS',
                            style: TextStyle(
                              fontFamily: 'BrandonGrotesque',
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primaryColor,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Category Filter Chips with Food Icons
                    SizedBox(
                      height: 60,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        children: merchantProvider.categories.map((category) {
                          final icon = _getCategoryIcon(category);
                          return Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: ChoiceChip(
                              label: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(icon),
                                  const SizedBox(width: 6),
                                  Text(
                                    category.toUpperCase(),
                                    style: TextStyle(
                                      fontFamily: 'BrandonGrotesque',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                              selected: merchantProvider.selectedCategory ==
                                  category,
                              onSelected: (_) {
                                merchantProvider.filterByCategory(category);
                              },
                              selectedColor: AppTheme.primaryColor,
                              backgroundColor: Colors.white,
                              labelStyle: TextStyle(
                                fontFamily: 'BrandonGrotesque',
                                color: merchantProvider.selectedCategory ==
                                        category
                                    ? Colors.white
                                    : Colors.grey[700],
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: BorderSide(
                                  color: Colors.grey[200]!,
                                  width: 1,
                                ),
                              ),
                              elevation: 2,
                              shadowColor: Colors.grey.withOpacity(0.2),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: 25),

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

      // Food-themed Bottom Navigation Bar
      bottomNavigationBar: Container(
        height: 85,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 25,
              spreadRadius: 5,
              offset: const Offset(0, -5),
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
            _buildFoodBottomNavItem(Icons.home_filled, 'HOME', true),
            _buildFoodBottomNavItem(Icons.history, 'ORDERS', false,
                onTap: _navigateToOrderHistory),
            _buildFoodBottomNavItem(Icons.explore, 'EXPLORE', false),
            _buildFoodBottomNavItem(Icons.person, 'PROFILE', false,
                onTap: _navigateToProfile),
          ],
        ),
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
        padding: const EdgeInsets.all(22),
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
                      fontFamily: 'BrandonGrotesque',
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 0.5,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: 'BrandonGrotesque',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withOpacity(0.9),
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.25),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Icon(
                icon,
                size: 36,
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
            // Merchant Image with Food Badges
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(25),
                    topRight: Radius.circular(25),
                  ),
                  child: Container(
                    height: 190,
                    width: double.infinity,
                    color: Colors.grey[200],
                    child: merchant.imageUrl != null
                        ? CachedNetworkImage(
                            imageUrl: merchant.imageUrl!,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Center(
                              child: CircularProgressIndicator(
                                color: AppTheme.primaryColor,
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: Colors.grey[200],
                              child: const Icon(
                                Icons.restaurant,
                                size: 80,
                                color: Colors.grey,
                              ),
                            ),
                          )
                        : Container(
                            color: Colors.grey[200],
                            child: const Icon(
                              Icons.restaurant,
                              size: 80,
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

                // Open/Closed Badge
                Positioned(
                  top: 16,
                  left: 16,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: merchant.isOpen ? Color(0xFF34C759) : Color(0xFFFF3B30),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(
                          merchant.isOpen ? Icons.check_circle : Icons.cancel,
                          size: 14,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          merchant.isOpen ? 'OPEN NOW' : 'CLOSED',
                          style: TextStyle(
                            fontFamily: 'BrandonGrotesque',
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
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
                          const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
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
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.star,
                            size: 14,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'FEATURED',
                            style: TextStyle(
                              fontFamily: 'BrandonGrotesque',
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Rating & Delivery Time at bottom
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
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 5,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.star_rounded,
                              size: 18,
                              color: Color(0xFFFF9500),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              merchant.rating.toStringAsFixed(1),
                              style: TextStyle(
                                fontFamily: 'BrandonGrotesque',
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: Colors.grey[900],
                              ),
                            ),
                            Text(
                              ' (${merchant.ratingCount})',
                              style: TextStyle(
                                fontFamily: 'BrandonGrotesque',
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Delivery Time
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
                              blurRadius: 5,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.delivery_dining_rounded,
                              size: 18,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${merchant.deliveryTime} MIN',
                              style: TextStyle(
                                fontFamily: 'BrandonGrotesque',
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
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
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          merchant.name.toUpperCase(),
                          style: TextStyle(
                            fontFamily: 'BrandonGrotesque',
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Colors.grey[900],
                            letterSpacing: 0.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Favorite Button
                      IconButton(
                        icon: Icon(
                          Provider.of<AppProvider>(context)
                                  .isFavorite(merchant.id)
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          color: Color(0xFFFF3B30),
                          size: 28,
                        ),
                        onPressed: () {
                          Provider.of<AppProvider>(context, listen: false)
                              .toggleFavorite(merchant);
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  Text(
                    merchant.description,
                    style: TextStyle(
                      fontFamily: 'BrandonGrotesque',
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                      height: 1.6,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 16),

                  // Food Tags
                  if (merchant.tags != null && merchant.tags!.isNotEmpty)
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: merchant.tags!.map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.grey[200]!,
                              width: 1.5,
                            ),
                          ),
                          child: Text(
                            '#${tag.toUpperCase()}',
                            style: TextStyle(
                              fontFamily: 'BrandonGrotesque',
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.grey[700],
                              letterSpacing: 0.5,
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                  // Delivery Fee & Minimum Order
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildInfoChip(
                        Icons.monetization_on_rounded,
                        'Delivery: KSh ${merchant.deliveryFee.toInt()}',
                        Color(0xFF34C759),
                      ),
                      const SizedBox(width: 12),
                      _buildInfoChip(
                        Icons.shopping_bag_rounded,
                        'Min: KSh ${merchant.minimumOrder?.toInt() ?? 0}',
                        Color(0xFF5856D6),
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

  Widget _buildFoodLoadingState() {
    return Container(
      padding: const EdgeInsets.all(60),
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
            child: const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 3,
              ),
            ),
          ),
          const SizedBox(height: 25),
          Text(
            '🍳 PREPARING YOUR FOOD OPTIONS...',
            style: TextStyle(
              fontFamily: 'BrandonGrotesque',
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.grey[700],
              letterSpacing: 1.0,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Fresh meals coming right up!',
            style: TextStyle(
              fontFamily: 'BrandonGrotesque',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[500],
              letterSpacing: 0.3,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFoodEmptyState() {
    return Container(
      padding: const EdgeInsets.all(50),
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
                style: TextStyle(
                  fontSize: 70,
                ),
              ),
            ),
          ),
          const SizedBox(height: 25),
          Text(
            'NO RESTAURANTS FOUND',
            style: TextStyle(
              fontFamily: 'BrandonGrotesque',
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.grey[800],
              letterSpacing: 1.0,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Try adjusting your search or explore different categories',
            style: TextStyle(
              fontFamily: 'BrandonGrotesque',
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
              letterSpacing: 0.3,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 25),
         // ...existing code...
ElevatedButton(
  onPressed: () {
    Provider.of<MerchantProvider>(context, listen: false).clearCategory();
  },
// ...existing code...
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 5,
              shadowColor: AppTheme.primaryColor.withOpacity(0.3),
            ),
            child: Text(
              'EXPLORE ALL RESTAURANTS',
              style: TextStyle(
                fontFamily: 'BrandonGrotesque',
                fontSize: 14,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodBottomNavItem(
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
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isActive
                    ? AppTheme.primaryColor
                    : Colors.grey.withOpacity(0.1),
                shape: BoxShape.circle,
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: AppTheme.primaryColor.withOpacity(0.3),
                          blurRadius: 10,
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
                fontFamily: 'BrandonGrotesque',
                fontSize: 11,
                color: isActive ? AppTheme.primaryColor : Colors.grey[500],
                fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1.5,
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
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontFamily: 'BrandonGrotesque',
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: color,
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