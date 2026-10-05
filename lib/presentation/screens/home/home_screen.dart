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
import 'package:kericho_delivery/presentation/screens/product/product_detail_screen.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  int _selectedCategoryIndex = 0;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounceTimer;
  late final AnimationController _bellController;

  // KulaHub brand palette
  static const Color kPrimaryColor = Color(0xFFFF5A36);
  static const Color kBackgroundColor = Color(0xFFFFF8F1);
  static const Color kCardColor = Colors.white;
  static const Color kTextPrimary = Color(0xFF16181D);
  static const Color kTextSecondary = Color(0xFF6C757D);
  static const Color kBorderColor = Color(0xFFF0E4D8);
  static const Color kSuccessColor = Color(0xFF2EAD6C);
  static const Color kErrorColor = Color(0xFFE5484D);

  // Refined accents (shared with merchant + cart screens)
  static const Color kInk = kTextPrimary;
  static const Color kGold = kPrimaryColor;
  static const Color kHairline = kBorderColor;

  final List<Map<String, dynamic>> _categories = [
    {'label': 'Featured', 'tag': 'All', 'icon': CupertinoIcons.star_fill},
    {'label': 'Fast Food', 'tag': 'FastFood', 'icon': CupertinoIcons.bag_fill},
    {'label': 'Groceries', 'tag': 'Grocery', 'icon': CupertinoIcons.cart_fill},
    {
      'label': 'Restaurant',
      'tag': 'Restaurant',
      'icon': CupertinoIcons.house_fill
    },
    {
      'label': 'Pharmacy',
      'tag': 'Pharmacy',
      'icon': CupertinoIcons.plus_circle_fill
    },
    {'label': 'Desserts', 'tag': 'Dessert', 'icon': CupertinoIcons.sparkles},
  ];

  @override
  void initState() {
    super.initState();
    _bellController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchDebounceTimer?.cancel();
    _bellController.dispose();
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

  void _navigateToMerchant(String merchantId, String merchantName,
      {String? merchantImageUrl}) {
    HapticFeedback.mediumImpact();
    AppRouter.pushNamed(
      AppRouter.merchant,
      arguments: {
        'merchantId': merchantId,
        'merchantName': merchantName,
        'merchantImageUrl': merchantImageUrl,
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
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(CupertinoIcons.sparkles, color: kGold, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '$label coming soon',
                style: GoogleFonts.afacad(
                    color: Colors.white,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: kInk,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      ),
    );
  }

  void _addProductToCart(ProductModel product) {
    HapticFeedback.mediumImpact();
    context
        .read<AppProvider>()
        .addToCart(CartItem(product: product, quantity: 1));
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(CupertinoIcons.checkmark_alt_circle_fill,
                color: kGold, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '${product.name} added to cart',
                style: GoogleFonts.afacad(
                    color: Colors.white,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: kInk,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  Future<void> _refreshLocation() async {
    HapticFeedback.lightImpact();
    await context.read<LocationProvider>().getCurrentLocation();
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: Consumer3<LocationProvider, AppProvider, MerchantProvider>(
        builder: (context, locationProvider, appProvider, merchantProvider, _) {
          return SafeArea(
            bottom: false,
            child: RefreshIndicator(
              onRefresh: _refreshLocation,
              color: kPrimaryColor,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                slivers: [
                  SliverToBoxAdapter(child: _buildTopBar(appProvider)),
                  SliverToBoxAdapter(child: _buildGreeting()),
                  SliverToBoxAdapter(child: _buildSearchField()),
                  SliverToBoxAdapter(child: _buildHeroBanner()),
                  SliverToBoxAdapter(child: _buildCategoriesSection()),
                  SliverToBoxAdapter(
                    child: _buildPopularPicksSection(merchantProvider),
                  ),
                  SliverToBoxAdapter(child: _buildRewardsBanner()),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 34, 24, 18),
                      child: _buildSectionTitle(
                        'Stores Near You',
                        trailing: merchantProvider.isLoading
                            ? null
                            : Text(
                                '${merchantProvider.merchants.length} '
                                '${merchantProvider.merchants.length == 1 ? 'store' : 'stores'}',
                                style: GoogleFonts.afacad(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w600,
                                    color: kTextSecondary),
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
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final merchant = merchantProvider.merchants[index];
                            return _AnimatedEntry(
                              key: ValueKey('merchant_${merchant.id}'),
                              index: index,
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 22),
                                child: _buildMerchantCard(merchant),
                              ),
                            );
                          },
                          childCount: merchantProvider.merchants.length,
                        ),
                      ),
                    ),
                  const SliverToBoxAdapter(child: SizedBox(height: 120)),
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

  // ==================== SHARED ====================
  Widget _buildSectionTitle(String title, {Widget? trailing}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.afacad(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: kInk,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 8),
              Container(width: 36, height: 2, color: kGold),
            ],
          ),
        ),
        if (trailing != null) trailing,
      ],
    );
  }

  Widget _outlinedCircle({required Widget child, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: kCardColor,
          shape: BoxShape.circle,
          border: Border.all(color: kHairline, width: 1),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 3)),
          ],
        ),
        child: Center(child: child),
      ),
    );
  }

  // ==================== TOP BAR ====================
  Widget _buildTopBar(AppProvider appProvider) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
      child: Row(
        children: [
          Image.asset(
            'assets/LOGO/logo.png',
            height: 48,
            fit: BoxFit.contain,
          ),
          const Spacer(),
          _outlinedCircle(
            onTap: () => _showComingSoon('Notifications'),
            child: AnimatedBuilder(
              animation: _bellController,
              builder: (context, child) {
                final swing = (_bellController.value * 2 - 1);
                return Transform.rotate(
                  angle: swing * 0.22,
                  alignment: Alignment.topCenter,
                  child: child,
                );
              },
              child: const Icon(CupertinoIcons.bell_fill,
                  color: kPrimaryColor, size: 20),
            ),
          ),
          const SizedBox(width: 12),
          _outlinedCircle(
            onTap: _navigateToProfile,
            child: const Icon(CupertinoIcons.person, color: kInk, size: 20),
          ),
        ],
      ),
    );
  }

  // ==================== GREETING ====================
  Widget _buildGreeting() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 26, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _greeting().toUpperCase(),
            style: GoogleFonts.afacad(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 2.2,
              color: kGold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'What are you\ncraving today?',
            style: GoogleFonts.afacad(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: kInk,
              letterSpacing: -0.6,
              height: 1.12,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== SEARCH FIELD ====================
  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 22, 24, 0),
      child: Container(
        height: 54,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: kCardColor,
          borderRadius: BorderRadius.circular(27),
          border: Border.all(color: kHairline, width: 1),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 14,
                offset: const Offset(0, 5)),
          ],
        ),
        child: Row(
          children: [
            const Icon(CupertinoIcons.search, color: kTextSecondary, size: 19),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _searchController,
                onChanged: _handleSearchChanged,
                cursorColor: kPrimaryColor,
                textAlignVertical: TextAlignVertical.center,
                style: GoogleFonts.afacad(color: kTextPrimary, fontSize: 15.5),
                decoration: InputDecoration(
                  isDense: true,
                  isCollapsed: true,
                  filled: false,
                  hintText: 'Search stores or dishes',
                  hintStyle: GoogleFonts.afacad(
                      color: kTextSecondary, fontSize: 15.5),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                ),
              ),
            ),
            if (_searchQuery.isNotEmpty)
              GestureDetector(
                onTap: () {
                  _searchController.clear();
                  _handleSearchChanged('');
                },
                child: const Icon(CupertinoIcons.xmark_circle_fill,
                    color: kTextSecondary, size: 18),
              ),
          ],
        ),
      ),
    );
  }

  // ==================== HERO BANNER ====================
  Widget _buildHeroBanner() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 22, 24, 0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF2B2623), kInk],
            ),
          ),
          child: Stack(
            children: [
              // Warm glow accents
              Positioned(
                right: -50,
                top: -50,
                child: Container(
                  width: 190,
                  height: 190,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: kPrimaryColor.withValues(alpha: 0.28),
                  ),
                ),
              ),
              Positioned(
                left: -40,
                bottom: -60,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: kGold.withValues(alpha: 0.12),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(22),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "TODAY'S SPECIAL",
                            style: GoogleFonts.afacad(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 2,
                              color: kGold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Fresh made.\nFlavor perfected.',
                            style: GoogleFonts.afacad(
                              fontSize: 23,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              height: 1.18,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Big flavor. Bold choices.',
                            style: GoogleFonts.afacad(
                              fontSize: 13.5,
                              color: Colors.white.withValues(alpha: 0.7),
                            ),
                          ),
                          const SizedBox(height: 18),
                          GestureDetector(
                            onTap: () => _showComingSoon('Featured deals'),
                            child: Container(
                              padding: const EdgeInsets.fromLTRB(18, 10, 10, 10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(26),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Order Now',
                                    style: GoogleFonts.afacad(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.3,
                                      color: kInk,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: const BoxDecoration(
                                        color: kGold, shape: BoxShape.circle),
                                    child: const Icon(
                                        CupertinoIcons.arrow_right,
                                        size: 13,
                                        color: kInk),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                            color: kGold.withValues(alpha: 0.6), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withValues(alpha: 0.35),
                              blurRadius: 18,
                              offset: const Offset(0, 8)),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(22),
                        child: Image.asset(
                          'assets/images/meat.jpg',
                          width: 104,
                          height: 124,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 104,
                            height: 124,
                            color: Colors.white.withValues(alpha: 0.08),
                            child: const Icon(CupertinoIcons.flame_fill,
                                color: kGold, size: 30),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== CATEGORIES SECTION ====================
  Widget _buildCategoriesSection() {
    return Padding(
      padding: const EdgeInsets.only(top: 28),
      child: SizedBox(
        height: 96,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          physics: const BouncingScrollPhysics(),
          itemCount: _categories.length,
          itemBuilder: (context, index) {
            final category = _categories[index];
            final isSelected = index == _selectedCategoryIndex;
            return Padding(
              padding: EdgeInsets.only(
                right: index < _categories.length - 1 ? 18 : 0,
              ),
              child: _buildCategoryCard(category, isSelected, index),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCategoryCard(
      Map<String, dynamic> category, bool isSelected, int index) {
    return GestureDetector(
      onTap: () => _handleCategorySelected(index),
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: isSelected ? kInk : kCardColor,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? kInk : kHairline,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: isSelected
                      ? Colors.black.withValues(alpha: 0.22)
                      : Colors.black.withValues(alpha: 0.03),
                  blurRadius: isSelected ? 14 : 8,
                  offset: Offset(0, isSelected ? 6 : 2),
                ),
              ],
            ),
            child: Icon(
              category['icon'],
              color: isSelected ? kGold : kTextSecondary,
              size: 25,
            ),
          ),
          const SizedBox(height: 9),
          SizedBox(
            width: 74,
            child: Text(
              category['label'],
              style: GoogleFonts.afacad(
                fontSize: 13,
                letterSpacing: 0.2,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? kInk : kTextSecondary,
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
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 18),
          child: _buildSectionTitle(
            'Popular Picks',
            trailing: GestureDetector(
              onTap: () => _showComingSoon('Popular Picks catalog'),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'View all',
                    style: GoogleFonts.afacad(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                      color: kPrimaryColor,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(CupertinoIcons.chevron_right,
                      size: 12, color: kPrimaryColor),
                ],
              ),
            ),
          ),
        ),
        SizedBox(
          height: 232,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            physics: const BouncingScrollPhysics(),
            itemCount: picks.length,
            itemBuilder: (context, index) {
              return Padding(
                padding:
                    EdgeInsets.only(right: index < picks.length - 1 ? 16 : 0),
                child: _buildProductCard(picks[index]),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProductImage(ProductModel product) {
    Widget fallback() => Container(
          color: kBorderColor.withValues(alpha: 0.6),
          child: const Center(
            child: Icon(CupertinoIcons.cube_box,
                color: kTextSecondary, size: 28),
          ),
        );

    final url = product.imageUrl;
    if (url == null) return fallback();
    if (url.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.cover,
        placeholder: (context, _) =>
            Container(color: kBorderColor.withValues(alpha: 0.6)),
        errorWidget: (context, _, __) => fallback(),
      );
    }
    return Image.asset(
      url,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => fallback(),
    );
  }

  Widget _buildProductCard(ProductModel product) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product)),
      ),
      child: Container(
        width: 160,
        decoration: BoxDecoration(
          color: kCardColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 18,
              offset: const Offset(0, 8),
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
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(24)),
                  child: SizedBox(
                    width: double.infinity,
                    height: 124,
                    child: _buildProductImage(product),
                  ),
                ),
                Positioned(
                  right: 12,
                  bottom: -17,
                  child: GestureDetector(
                    onTap: () => _addProductToCart(product),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: kInk,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.25),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Icon(CupertinoIcons.add,
                          color: Colors.white, size: 17),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 18, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: GoogleFonts.afacad(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w700,
                      color: kInk,
                      height: 1.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        'KSh ',
                        style: GoogleFonts.afacad(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                          color: kGold,
                        ),
                      ),
                      Text(
                        product.price.toStringAsFixed(0),
                        style: GoogleFonts.afacad(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: kInk,
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

  // ==================== REWARDS BANNER ====================
  Widget _buildRewardsBanner() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 30, 24, 0),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: kCardColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: kGold.withValues(alpha: 0.4), width: 1),
          boxShadow: [
            BoxShadow(
                color: kGold.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 8)),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: kGold.withValues(alpha: 0.14),
                shape: BoxShape.circle,
                border: Border.all(color: kGold.withValues(alpha: 0.35)),
              ),
              child:
                  const Icon(CupertinoIcons.gift_fill, color: kGold, size: 23),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'KulaHub Rewards',
                    style: GoogleFonts.afacad(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: kInk,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Earn points with every order and unlock exclusive rewards.',
                    style: GoogleFonts.afacad(
                      fontSize: 12.5,
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                decoration: BoxDecoration(
                  color: kInk,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Text(
                  'Join',
                  style: GoogleFonts.afacad(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
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
      onTap: () => _navigateToMerchant(merchant.id, merchant.name,
          merchantImageUrl: merchant.imageUrl),
      child: Container(
        decoration: BoxDecoration(
          color: kCardColor,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.07),
              blurRadius: 22,
              offset: const Offset(0, 10),
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
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          child: SizedBox(
            height: 176,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                merchant.imageUrl != null
                    ? (merchant.imageUrl!.startsWith('http')
                        ? CachedNetworkImage(
                            imageUrl: merchant.imageUrl!,
                            fit: BoxFit.cover,
                            placeholder: (context, url) =>
                                _buildImagePlaceholder(),
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
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.45, 1.0],
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.45),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
            top: 14, left: 14, child: _buildStatusBadge(merchant.isOpen)),
        Positioned(
          top: 14,
          right: 14,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(CupertinoIcons.star_fill, size: 12, color: kGold),
                const SizedBox(width: 5),
                Text(
                  merchant.rating.toStringAsFixed(1),
                  style: GoogleFonts.afacad(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: kInk),
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
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2B2623), kInk],
        ),
      ),
      child: Center(
        child: Icon(CupertinoIcons.building_2_fill,
            size: 40, color: Colors.white.withValues(alpha: 0.2)),
      ),
    );
  }

  Widget _buildStatusBadge(bool isOpen) {
    final color = isOpen ? kSuccessColor : kErrorColor;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 7),
          Text(
            isOpen ? 'OPEN' : 'CLOSED',
            style: GoogleFonts.afacad(
              fontSize: 11,
              color: Colors.white,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMerchantDetails(MerchantModel merchant) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            merchant.name,
            style: GoogleFonts.afacad(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: kInk,
              letterSpacing: -0.2,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Text(
            merchant.description,
            style: GoogleFonts.afacad(
                fontSize: 14, color: kTextSecondary, height: 1.4),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, thickness: 1, color: kHairline),
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(CupertinoIcons.clock, size: 15, color: kInk),
              const SizedBox(width: 6),
              Text(
                '${merchant.deliveryTime} min',
                style: GoogleFonts.afacad(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: kInk),
              ),
              Container(
                width: 1,
                height: 14,
                margin: const EdgeInsets.symmetric(horizontal: 14),
                color: kHairline,
              ),
              const Icon(CupertinoIcons.car_detailed, size: 15, color: kInk),
              const SizedBox(width: 6),
              Text(
                merchant.deliveryFee == 0
                    ? 'Free delivery'
                    : 'KSh ${merchant.deliveryFee.toInt()}',
                style: GoogleFonts.afacad(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: merchant.deliveryFee == 0 ? kSuccessColor : kInk),
              ),
              const Spacer(),
              const Icon(CupertinoIcons.arrow_right, size: 16, color: kGold),
            ],
          ),
        ],
      ),
    );
  }

  // ==================== STATE WIDGETS ====================
  Widget _buildLoadingState() {
    return const Padding(
      padding: EdgeInsets.all(40),
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation(kPrimaryColor),
          strokeWidth: 2.5,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: kHairline),
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: kBackgroundColor,
              border: Border.all(color: kHairline),
            ),
            child: const Icon(CupertinoIcons.search,
                size: 28, color: kTextSecondary),
          ),
          const SizedBox(height: 20),
          Text(
            'No stores found',
            style: GoogleFonts.afacad(
                fontSize: 21, fontWeight: FontWeight.w700, color: kInk),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters or check back later.',
            style: GoogleFonts.afacad(fontSize: 14.5, color: kTextSecondary),
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
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      child: SafeArea(
        top: false,
        child: Container(
          height: 72,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: kInk,
            borderRadius: BorderRadius.circular(36),
            border: Border.all(color: kGold.withValues(alpha: 0.25), width: 1),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.28),
                  blurRadius: 26,
                  offset: const Offset(0, 12)),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(CupertinoIcons.house_fill, 'Home', true, () {}),
              _buildNavItem(CupertinoIcons.square_grid_2x2, 'Menu', false,
                  _navigateToMenu),
              _buildCartNavItem(),
              _buildNavItem(
                  CupertinoIcons.gift, 'Rewards', false, _navigateToRewards),
              _buildNavItem(CupertinoIcons.person_fill, 'Profile', false,
                  _navigateToProfile),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
      IconData icon, String label, bool selected, VoidCallback onTap) {
    final color = selected ? kGold : Colors.white.withValues(alpha: 0.55);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 23),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.afacad(
                color: color,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                letterSpacing: 0.3,
                fontSize: 11.5,
              ),
            ),
            const SizedBox(height: 3),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: selected ? 14 : 0,
              height: 2,
              color: kGold,
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
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: kGold,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
                color: kGold.withValues(alpha: 0.4),
                blurRadius: 14,
                offset: const Offset(0, 5)),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            const Center(
              child:
                  Icon(CupertinoIcons.cart_fill, color: kInk, size: 22),
            ),
            if (appProvider.cartItemCount > 0)
              Positioned(
                right: -4,
                top: -4,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: kPrimaryColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: kInk, width: 2),
                  ),
                  constraints:
                      const BoxConstraints(minWidth: 20, minHeight: 20),
                  child: Center(
                    child: Text(
                      appProvider.cartItemCount > 9
                          ? '9+'
                          : '${appProvider.cartItemCount}',
                      style: GoogleFonts.afacad(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Soft fade + rise-in for list rows, lightly staggered.
class _AnimatedEntry extends StatelessWidget {
  final int index;
  final Widget child;

  const _AnimatedEntry({super.key, required this.index, required this.child});

  @override
  Widget build(BuildContext context) {
    final delay = index.clamp(0, 5) * 60;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 400 + delay),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, (1 - value) * 20),
          child: child,
        ),
      ),
      child: child,
    );
  }
}