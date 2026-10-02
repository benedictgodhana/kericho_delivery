import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kericho_delivery/data/models/cart_model.dart';
import 'package:kericho_delivery/data/models/merchant_model.dart';
import 'package:kericho_delivery/data/models/product_model.dart';
import 'package:kericho_delivery/presentation/providers/app_provider.dart';
import 'package:kericho_delivery/presentation/providers/location_provider.dart';
import 'package:kericho_delivery/presentation/providers/merchant_provider.dart';
import 'package:kericho_delivery/presentation/router/app_router.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedCategoryIndex = 0;
  bool _showSearchBar = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounceTimer;

  // KulaHub brand palette
  static const Color kPrimaryColor = Color(0xFFFF5A36);
  static const Color kPrimaryDark = Color(0xFFC73F22);
  static const Color kSecondaryColor = Color(0xFFFFB020);
  static const Color kBackgroundColor = Color(0xFFFFF8F1);
  static const Color kCardColor = Colors.white;
  static const Color kTextPrimary = Color(0xFF16181D);
  static const Color kTextSecondary = Color(0xFF6C757D);
  static const Color kBorderColor = Color(0xFFF0E4D8);
  static const Color kSuccessColor = Color(0xFF2EAD6C);
  static const Color kErrorColor = Color(0xFFE5484D);

  final List<Map<String, dynamic>> _categories = [
    {'label': 'Featured', 'tag': 'All', 'icon': CupertinoIcons.star_fill},
    {'label': 'Fast Food', 'tag': 'FastFood', 'icon': CupertinoIcons.bag_fill},
    {'label': 'Groceries', 'tag': 'Grocery', 'icon': CupertinoIcons.cart_fill},
    {'label': 'Restaurant', 'tag': 'Restaurant', 'icon': CupertinoIcons.house_fill},
    {'label': 'Pharmacy', 'tag': 'Pharmacy', 'icon': CupertinoIcons.plus_circle_fill},
    {'label': 'Desserts', 'tag': 'Dessert', 'icon': CupertinoIcons.sparkles},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  @override
  void dispose() {
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

  void _toggleSearchBar() {
    HapticFeedback.lightImpact();
    setState(() {
      _showSearchBar = !_showSearchBar;
      if (!_showSearchBar) {
        _searchController.clear();
        _handleSearchChanged('');
        FocusScope.of(context).unfocus();
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

  void _navigateToProfile() {
    HapticFeedback.lightImpact();
    AppRouter.pushNamed(AppRouter.profile);
  }

  void _navigateToRewards() {
    HapticFeedback.lightImpact();
    AppRouter.pushNamed(AppRouter.promotions);
  }

  void _navigateToMenu() {
    HapticFeedback.lightImpact();
    AppRouter.pushNamed(AppRouter.menu);
  }

  void _showComingSoon(String label) {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$label coming soon!',
          style: GoogleFonts.afacad(color: Colors.white),
        ),
        backgroundColor: kTextPrimary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _addProductToCart(ProductModel product) {
    HapticFeedback.mediumImpact();
    context.read<AppProvider>().addToCart(CartItem(product: product, quantity: 1));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${product.name} added to cart',
          style: GoogleFonts.afacad(color: Colors.white),
        ),
        backgroundColor: kSuccessColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  Future<void> _refreshLocation() async {
    HapticFeedback.lightImpact();
    await context.read<LocationProvider>().getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: Consumer3<LocationProvider, AppProvider, MerchantProvider>(
        builder: (context, locationProvider, appProvider, merchantProvider, _) {
          return SafeArea(
            child: RefreshIndicator(
              onRefresh: _refreshLocation,
              color: kPrimaryColor,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                slivers: [
                  SliverToBoxAdapter(
                    child: _buildTopBar(appProvider),
                  ),
                  SliverToBoxAdapter(
                    child: _buildDeliveryBar(locationProvider),
                  ),
                  if (_showSearchBar)
                    SliverToBoxAdapter(child: _buildSearchField()),
                  SliverToBoxAdapter(child: _buildHeroBanner()),
                  SliverToBoxAdapter(child: _buildCategoriesSection()),
                  SliverToBoxAdapter(
                    child: _buildPopularPicksSection(merchantProvider),
                  ),
                  SliverToBoxAdapter(child: _buildRewardsBanner()),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 28, 20, 16),
                      child: Text(
                        'Stores Near You',
                        style: GoogleFonts.afacad(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: kTextPrimary,
                          letterSpacing: -0.3,
                        ),
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
                            final merchant = merchantProvider.merchants[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: _buildMerchantCard(merchant),
                            );
                          },
                          childCount: merchantProvider.merchants.length,
                        ),
                      ),
                    ),
                  const SliverToBoxAdapter(child: SizedBox(height: 110)),
                ],
              ),
            ),
          );
        },
      ),
      extendBody: true,
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  // ==================== TOP BAR ====================
  Widget _buildTopBar(AppProvider appProvider) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: kPrimaryColor,
              shape: BoxShape.circle,
            ),
            child: const Icon(CupertinoIcons.bag_fill, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 10),
          Text(
            'KulaHub',
            style: GoogleFonts.afacad(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: kTextPrimary,
              letterSpacing: -0.3,
            ),
          ),
          const Spacer(),
          _buildIconButton(
            icon: CupertinoIcons.bell,
            onTap: () => _showComingSoon('Notifications'),
          ),
          const SizedBox(width: 10),
          _buildIconButton(
            icon: CupertinoIcons.person,
            onTap: _navigateToProfile,
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: kCardColor,
          shape: BoxShape.circle,
          border: Border.all(color: kBorderColor, width: 1.2),
        ),
        child: Icon(icon, color: kTextPrimary, size: 20),
      ),
    );
  }

  // ==================== DELIVERY BAR ====================
  Widget _buildDeliveryBar(LocationProvider locationProvider) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
      child: Row(
        children: [
          Icon(CupertinoIcons.location_solid, color: kPrimaryColor, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: GestureDetector(
              onTap: _refreshLocation,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Deliver to',
                    style: GoogleFonts.afacad(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                      color: kTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          locationProvider.currentLocation?.address ??
                              'Kericho, Kenya',
                          style: GoogleFonts.afacad(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: kTextPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(CupertinoIcons.chevron_down, size: 16, color: kTextSecondary),
                    ],
                  ),
                ],
              ),
            ),
          ),
          _buildIconButton(icon: CupertinoIcons.search, onTap: _toggleSearchBar),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: kCardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: kBorderColor, width: 1.2),
        ),
        child: Row(
          children: [
            const SizedBox(width: 14),
            Icon(CupertinoIcons.search, color: kTextSecondary, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _searchController,
                autofocus: true,
                onChanged: _handleSearchChanged,
                style: GoogleFonts.afacad(color: kTextPrimary, fontSize: 15),
                decoration: InputDecoration(
                  hintText: 'Search stores or dishes...',
                  hintStyle: GoogleFonts.afacad(color: kTextSecondary, fontSize: 15),
                  border: InputBorder.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== HERO BANNER ====================
  Widget _buildHeroBanner() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [kPrimaryColor, kPrimaryDark],
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'FRESH MADE.\nFLAVOR PERFECTED.',
                    style: GoogleFonts.afacad(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Big flavor. Bold choices.',
                    style: GoogleFonts.afacad(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () => _showComingSoon('Featured deals'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Order Now',
                            style: GoogleFonts.afacad(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: kPrimaryColor,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(CupertinoIcons.arrow_right, size: 16, color: kPrimaryColor),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Image.asset(
                'assets/images/meat.jpg',
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== CATEGORIES SECTION ====================
  Widget _buildCategoriesSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
      child: SizedBox(
        height: 92,
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
    );
  }

  Widget _buildCategoryCard(Map<String, dynamic> category, bool isSelected, int index) {
    return GestureDetector(
      onTap: () => _handleCategorySelected(index),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: isSelected ? kPrimaryColor : kCardColor,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? kPrimaryColor : kBorderColor,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: isSelected
                      ? kPrimaryColor.withValues(alpha: 0.25)
                      : Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(
              category['icon'],
              color: isSelected ? Colors.white : kTextSecondary,
              size: 26,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 72,
            child: Text(
              category['label'],
              style: GoogleFonts.afacad(
                fontSize: 12.5,
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
    );
  }

  // ==================== POPULAR PICKS SECTION ====================
  Widget _buildPopularPicksSection(MerchantProvider merchantProvider) {
    final picks = merchantProvider.getPopularProducts();
    if (picks.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 28, 20, 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Popular Picks',
                style: GoogleFonts.afacad(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: kTextPrimary,
                  letterSpacing: -0.3,
                ),
              ),
              GestureDetector(
                onTap: () => _showComingSoon('Popular Picks catalog'),
                child: Text(
                  'View All',
                  style: GoogleFonts.afacad(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: kPrimaryColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 210,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            physics: const BouncingScrollPhysics(),
            itemCount: picks.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(right: index < picks.length - 1 ? 14 : 0),
                child: _buildProductCard(picks[index]),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProductCard(ProductModel product) {
    return Container(
      width: 148,
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: kBorderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                child: product.imageUrl != null
                    ? Image.asset(
                        product.imageUrl!,
                        width: double.infinity,
                        height: 100,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        height: 100,
                        color: kBackgroundColor,
                        child: Icon(CupertinoIcons.cube_box, color: kTextSecondary),
                      ),
              ),
              Positioned(
                right: 10,
                bottom: -14,
                child: GestureDetector(
                  onTap: () => _addProductToCart(product),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: kPrimaryColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: kPrimaryColor.withValues(alpha: 0.35),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(CupertinoIcons.add, color: Colors.white, size: 18),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 20, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: GoogleFonts.afacad(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: kTextPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'KSh ${product.price.toStringAsFixed(0)}',
                  style: GoogleFonts.afacad(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: kPrimaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== REWARDS BANNER ====================
  Widget _buildRewardsBanner() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: kCardColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: kBorderColor, width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: kSecondaryColor.withValues(alpha: 0.18),
                shape: BoxShape.circle,
              ),
              child: const Icon(CupertinoIcons.gift_fill, color: kSecondaryColor, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'KULAHUB REWARDS',
                    style: GoogleFonts.afacad(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                      color: kPrimaryColor,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Earn points with every order and unlock exclusive rewards.',
                    style: GoogleFonts.afacad(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: kTextSecondary,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: _navigateToRewards,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: kPrimaryColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Join Now',
                  style: GoogleFonts.afacad(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
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
              color: Colors.black.withValues(alpha: 0.03),
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

  Widget _buildMerchantImage(MerchantModel merchant) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
          child: Container(
            height: 150,
            width: double.infinity,
            color: kBackgroundColor,
            child: merchant.imageUrl != null
                ? (merchant.imageUrl!.startsWith('http')
                    ? CachedNetworkImage(
                        imageUrl: merchant.imageUrl!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => _buildImagePlaceholder(),
                        errorWidget: (context, url, error) => _buildImagePlaceholder(),
                      )
                    : Image.asset(
                        merchant.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => _buildImagePlaceholder(),
                      ))
                : _buildImagePlaceholder(),
          ),
        ),
        Positioned(top: 12, left: 12, child: _buildStatusBadge(merchant.isOpen)),
      ],
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: kBackgroundColor,
      child: Center(
        child: Icon(CupertinoIcons.building_2_fill, size: 44, color: kTextSecondary.withValues(alpha: 0.5)),
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
      child: Text(
        isOpen ? 'OPEN' : 'CLOSED',
        style: GoogleFonts.afacad(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w700),
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
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: kTextPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Icon(CupertinoIcons.star_fill, size: 14, color: kSecondaryColor),
              const SizedBox(width: 4),
              Text(
                merchant.rating.toStringAsFixed(1),
                style: GoogleFonts.afacad(fontSize: 13, fontWeight: FontWeight.w700, color: kTextPrimary),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            merchant.description,
            style: GoogleFonts.afacad(fontSize: 13.5, color: kTextSecondary, height: 1.3),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(CupertinoIcons.clock, size: 14, color: kTextSecondary),
              const SizedBox(width: 4),
              Text(
                '${merchant.deliveryTime} min',
                style: GoogleFonts.afacad(fontSize: 12.5, fontWeight: FontWeight.w600, color: kTextSecondary),
              ),
              const SizedBox(width: 14),
              Icon(CupertinoIcons.car_detailed, size: 14, color: kTextSecondary),
              const SizedBox(width: 4),
              Text(
                merchant.deliveryFee == 0 ? 'Free delivery' : 'KSh ${merchant.deliveryFee.toInt()}',
                style: GoogleFonts.afacad(fontSize: 12.5, fontWeight: FontWeight.w600, color: kTextSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==================== STATE WIDGETS ====================
  Widget _buildLoadingState() {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation(kPrimaryColor),
          strokeWidth: 3,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: kBorderColor),
      ),
      child: Column(
        children: [
          Icon(CupertinoIcons.search, size: 44, color: kTextSecondary),
          const SizedBox(height: 16),
          Text(
            'No stores found',
            style: GoogleFonts.afacad(fontSize: 18, fontWeight: FontWeight.w700, color: kTextPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters or check back later',
            style: GoogleFonts.afacad(fontSize: 14, color: kTextSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ==================== BOTTOM NAV BAR ====================
  Widget _buildBottomNavBar() {
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: SafeArea(
        top: false,
        child: Container(
          height: 68,
          decoration: BoxDecoration(
            color: kCardColor,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.10), blurRadius: 20, offset: const Offset(0, 8)),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(CupertinoIcons.house_fill, 'Home', true, () {}),
              _buildNavItem(CupertinoIcons.square_grid_2x2, 'Menu', false, _navigateToMenu),
              _buildCartNavItem(),
              _buildNavItem(CupertinoIcons.gift, 'Rewards', false, _navigateToRewards),
              _buildNavItem(CupertinoIcons.person_fill, 'Profile', false, _navigateToProfile),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: selected ? kPrimaryColor : kTextSecondary, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.afacad(
                color: selected ? kPrimaryColor : kTextSecondary,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 11.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartNavItem() {
    final appProvider = context.watch<AppProvider>();
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        _navigateToCart();
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: kPrimaryColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: kPrimaryColor.withValues(alpha: 0.35), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                const Center(
                  child: Icon(CupertinoIcons.cart_fill, color: Colors.white, size: 22),
                ),
                if (appProvider.cartItemCount > 0)
                  Positioned(
                    right: -4,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(color: kErrorColor, shape: BoxShape.circle),
                      constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                      child: Center(
                        child: Text(
                          appProvider.cartItemCount > 9 ? '9+' : '${appProvider.cartItemCount}',
                          style: GoogleFonts.afacad(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
                        ),
                      ),
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
