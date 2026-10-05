import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kericho_delivery/data/models/cart_model.dart';
import 'package:kericho_delivery/data/models/product_model.dart';
import 'package:kericho_delivery/presentation/providers/app_provider.dart';
import 'package:kericho_delivery/presentation/providers/merchant_provider.dart';
import 'package:kericho_delivery/presentation/router/app_router.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> with TickerProviderStateMixin {
  // ─── Theme ────────────────────────────────────────────────
  static const Color kPrimaryColor = Color(0xFFFF5A36);
  static const Color kBackgroundColor = Color(0xFFFFF8F1);
  static const Color kCardColor = Colors.white;
  static const Color kTextPrimary = Color(0xFF16181D);
  static const Color kTextSecondary = Color(0xFF6C757D);
  static const Color kBorderColor = Color(0xFFF0E4D8);

  // Refined accents (shared with home, cart + merchant screens)
  static const Color kInk = kTextPrimary;
  static const Color kGold = kPrimaryColor;
  static const Color kHairline = kBorderColor;

  // ─── State ────────────────────────────────────────────────
  String _selectedCategory = 'All';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  Timer? _searchDebounceTimer;

  late final AnimationController _entryController;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    )..forward();
    _searchFocus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    _searchDebounceTimer?.cancel();
    _entryController.dispose();
    super.dispose();
  }

  // ─── Handlers ─────────────────────────────────────────────
  void _handleSearchChanged(String query) {
    _searchDebounceTimer?.cancel();
    _searchDebounceTimer = Timer(const Duration(milliseconds: 280), () {
      if (mounted) setState(() => _searchQuery = query);
    });
  }

  void _clearSearch() {
    HapticFeedback.selectionClick();
    _searchController.clear();
    setState(() => _searchQuery = '');
  }

  void _addToCart(ProductModel product, {bool silent = false}) {
    HapticFeedback.mediumImpact();
    context.read<AppProvider>().addToCart(
          CartItem(product: product, quantity: 1),
        );
    if (silent) return;
    _showSnack('${product.name} added to cart');
  }

  void _removeFromCart(ProductModel product) {
    HapticFeedback.selectionClick();
    final app = context.read<AppProvider>();
    app.removeFromCart(product.id);
    _showSnack('${product.name} removed');
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(CupertinoIcons.checkmark_alt_circle_fill,
                  color: kGold, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(message,
                    style: GoogleFonts.afacad(
                        color: Colors.white,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          backgroundColor: kInk,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          duration: const Duration(milliseconds: 1400),
        ),
      );
  }

  List<ProductModel> _filterProducts(List<ProductModel> products) {
    final q = _searchQuery.toLowerCase();
    return products.where((p) {
      final matchesCategory =
          _selectedCategory == 'All' || p.category == _selectedCategory;
      final matchesSearch = q.isEmpty ||
          p.name.toLowerCase().contains(q) ||
          p.description.toLowerCase().contains(q);
      return matchesCategory && matchesSearch;
    }).toList();
  }

  void _openProductSheet(ProductModel product) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _ProductDetailSheet(
        product: product,
        onAdd: () => _addToCart(product),
      ),
    );
  }

  // ─── Build ────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final merchantProvider = context.watch<MerchantProvider>();
    final appProvider = context.watch<AppProvider>();
    final categories = merchantProvider.getProductCategories();
    final products = _filterProducts(merchantProvider.getAllProducts());

    return Scaffold(
      backgroundColor: kBackgroundColor,
      extendBody: true,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchField(),
            _buildCategoryChips(categories),
            _buildResultCount(products.length),
            Expanded(
              child: products.isEmpty
                  ? _buildEmptyState()
                  : GridView.builder(
                      padding: EdgeInsets.fromLTRB(24, 14, 24,
                          appProvider.cartItemCount > 0 ? 200 : 130),
                      physics: const BouncingScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 20,
                        crossAxisSpacing: 16,
                        childAspectRatio: 0.64,
                      ),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        // Staggered entrance
                        final start = (index * 0.05).clamp(0.0, 0.5);
                        final end = (start + 0.5).clamp(0.0, 1.0);
                        final anim = CurvedAnimation(
                          parent: _entryController,
                          curve:
                              Interval(start, end, curve: Curves.easeOutCubic),
                        );
                        return FadeTransition(
                          opacity: anim,
                          child: SlideTransition(
                            position: Tween(
                              begin: const Offset(0, 0.12),
                              end: Offset.zero,
                            ).animate(anim),
                            child: _buildProductCard(products[index]),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (appProvider.cartItemCount > 0) _buildCartBar(appProvider),
          _buildBottomNavBar(),
        ],
      ),
    );
  }

  // ─── Header ───────────────────────────────────────────────
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
      child: Row(
        children: [
          _CircleIconButton(
            icon: CupertinoIcons.back,
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.of(context).maybePop();
            },
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'The Menu',
                  style: GoogleFonts.afacad(
                    fontSize: 27,
                    fontWeight: FontWeight.w700,
                    color: kInk,
                    letterSpacing: -0.4,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'FRESH PICKS, JUST FOR YOU',
                  style: GoogleFonts.afacad(
                    fontSize: 11,
                    color: kGold,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.8,
                  ),
                ),
              ],
            ),
          ),
          _CircleIconButton(
            icon: CupertinoIcons.heart,
            onTap: () => HapticFeedback.selectionClick(),
          ),
        ],
      ),
    );
  }

  // ─── Search ───────────────────────────────────────────────
  Widget _buildSearchField() {
    final focused = _searchFocus.hasFocus;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 52,
        decoration: BoxDecoration(
          color: kCardColor,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(
            color: focused ? kGold : kHairline,
            width: focused ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: focused
                  ? kGold.withValues(alpha: 0.18)
                  : Colors.black.withValues(alpha: 0.04),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 16),
            Icon(
              CupertinoIcons.search,
              color: focused ? kInk : kTextSecondary,
              size: 19,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocus,
                onChanged: _handleSearchChanged,
                textInputAction: TextInputAction.search,
                cursorColor: kPrimaryColor,
                style: GoogleFonts.afacad(
                    color: kTextPrimary,
                    fontSize: 15.5,
                    fontWeight: FontWeight.w500),
                decoration: InputDecoration(
                  hintText: 'Search the menu',
                  hintStyle: GoogleFonts.afacad(
                      color: kTextSecondary, fontSize: 15.5),
                  filled: false,
                  isDense: true,
                  isCollapsed: true,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                ),
              ),
            ),
            if (_searchController.text.isNotEmpty)
              GestureDetector(
                onTap: _clearSearch,
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14),
                  child: Icon(CupertinoIcons.xmark_circle_fill,
                      size: 18, color: kTextSecondary),
                ),
              )
            else
              const SizedBox(width: 14),
          ],
        ),
      ),
    );
  }

  // ─── Categories ───────────────────────────────────────────
  Widget _buildCategoryChips(List<String> categories) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: SizedBox(
        height: 38,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          physics: const BouncingScrollPhysics(),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            final isSelected = category == _selectedCategory;
            return Padding(
              padding: EdgeInsets.only(
                  right: index < categories.length - 1 ? 8 : 0),
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _selectedCategory = category);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected ? kInk : Colors.transparent,
                    borderRadius: BorderRadius.circular(19),
                    border: Border.all(
                      color: isSelected ? kInk : kHairline,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    category,
                    style: GoogleFonts.afacad(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                      color: isSelected ? Colors.white : kTextSecondary,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildResultCount(int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 0),
      child: Row(
        children: [
          Container(width: 3, height: 14, color: kGold),
          const SizedBox(width: 10),
          Text(
            '$count ${count == 1 ? 'item' : 'items'} available',
            style: GoogleFonts.afacad(
              fontSize: 13.5,
              color: kTextSecondary,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Product Card ─────────────────────────────────────────
  Widget _buildProductCard(ProductModel product) {
    final app = context.watch<AppProvider>();
    final inCart = app.getQuantityForProduct(product.id);

    return _PressableCard(
      onTap: () => _openProductSheet(product),
      child: Container(
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
            // ── Image ──
            Stack(
              clipBehavior: Clip.none,
              children: [
                Hero(
                  tag: 'product-${product.id}',
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                    child: _menuImage(product.imageUrl, height: 124),
                  ),
                ),
                // Soft bottom scrim
                Positioned.fill(
                  child: IgnorePointer(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            stops: const [0.5, 1.0],
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.18),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // Category tag
                Positioned(
                  left: 10,
                  top: 10,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.25)),
                    ),
                    child: Text(
                      product.category.toUpperCase(),
                      style: GoogleFonts.afacad(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.1,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                // Add / stepper
                Positioned(
                  right: 10,
                  bottom: -17,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    transitionBuilder: (child, anim) =>
                        ScaleTransition(scale: anim, child: child),
                    child: inCart > 0
                        ? _QuantityStepper(
                            key: const ValueKey('stepper'),
                            quantity: inCart,
                            onAdd: () => _addToCart(product, silent: true),
                            onRemove: () => _removeFromCart(product),
                          )
                        : _AddButton(
                            key: const ValueKey('add'),
                            onTap: () => _addToCart(product),
                          ),
                  ),
                ),
              ],
            ),
            // ── Info ──
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 22, 14, 14),
              child: Column(
                mainAxisSize: MainAxisSize.min,
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
                  const SizedBox(height: 4),
                  Text(
                    product.description,
                    style: GoogleFonts.afacad(
                      fontSize: 12.5,
                      color: kTextSecondary,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
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
                      const Spacer(),
                      if (inCart > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: kGold.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '$inCart in cart',
                            style: GoogleFonts.afacad(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              color: kPrimaryColor,
                            ),
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

  // ─── Empty state ──────────────────────────────────────────
  Widget _buildEmptyState() {
    final hasFilters = _selectedCategory != 'All' || _searchQuery.isNotEmpty;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: kCardColor,
                shape: BoxShape.circle,
                border: Border.all(color: kHairline),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 22,
                      offset: const Offset(0, 8)),
                ],
              ),
              child: const Icon(CupertinoIcons.search, size: 36, color: kGold),
            ),
            const SizedBox(height: 24),
            Text(
              'Nothing here yet',
              style: GoogleFonts.afacad(
                  fontSize: 23, fontWeight: FontWeight.w700, color: kInk),
            ),
            const SizedBox(height: 12),
            Container(width: 36, height: 2, color: kGold),
            const SizedBox(height: 14),
            Text(
              hasFilters
                  ? 'Try a different search or category.'
                  : 'The menu is empty right now.',
              style: GoogleFonts.afacad(fontSize: 14.5, color: kTextSecondary),
              textAlign: TextAlign.center,
            ),
            if (hasFilters) ...[
              const SizedBox(height: 22),
              GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  _searchController.clear();
                  setState(() {
                    _searchQuery = '';
                    _selectedCategory = 'All';
                  });
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 13),
                  decoration: BoxDecoration(
                    color: kInk,
                    borderRadius: BorderRadius.circular(26),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(CupertinoIcons.refresh,
                          size: 15, color: kGold),
                      const SizedBox(width: 8),
                      Text(
                        'Clear filters',
                        style: GoogleFonts.afacad(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ─── Cart Bar ─────────────────────────────────────────────
  Widget _buildCartBar(AppProvider app) {
    final count = app.cartItemCount;
    final total = app.cartTotal;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 10),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.mediumImpact();
          AppRouter.pushNamed(AppRouter.cart);
        },
        child: Container(
          padding: const EdgeInsets.fromLTRB(10, 10, 20, 10),
          decoration: BoxDecoration(
            color: kInk,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: kGold.withValues(alpha: 0.35)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration:
                    const BoxDecoration(color: kGold, shape: BoxShape.circle),
                child: Text(
                  '$count',
                  style: GoogleFonts.afacad(
                    color: kInk,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'View cart',
                      style: GoogleFonts.afacad(
                        color: Colors.white,
                        fontSize: 15.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                    Text(
                      '$count ${count == 1 ? 'item' : 'items'} in your order',
                      style: GoogleFonts.afacad(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                'KSh ${total.toStringAsFixed(0)}',
                style: GoogleFonts.afacad(
                  color: Colors.white,
                  fontSize: 16.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 10),
              const Icon(CupertinoIcons.arrow_right, color: kGold, size: 17),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Bottom Nav ───────────────────────────────────────────
  Widget _buildBottomNavBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      child: SafeArea(
        top: false,
        child: Container(
          height: 72,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: kInk,
            borderRadius: BorderRadius.circular(36),
            border: Border.all(color: kGold.withValues(alpha: 0.25)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.28),
                blurRadius: 26,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(CupertinoIcons.house_fill, 'Home', false,
                  () => Navigator.of(context).maybePop()),
              _buildNavItem(
                  CupertinoIcons.square_grid_2x2, 'Menu', true, () {}),
              _buildCartNavItem(),
              _buildNavItem(CupertinoIcons.gift, 'Rewards', false,
                  () => AppRouter.pushNamed(AppRouter.promotions)),
              _buildNavItem(CupertinoIcons.person_fill, 'Profile', false,
                  () => AppRouter.pushNamed(AppRouter.profile)),
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
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      behavior: HitTestBehavior.opaque,
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
        AppRouter.pushNamed(AppRouter.cart);
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
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            const Center(
              child: Icon(CupertinoIcons.cart_fill, color: kInk, size: 22),
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
                        fontWeight: FontWeight.w800,
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
}

// ═══════════════════════════════════════════════════════════
//  Supporting Widgets
// ═══════════════════════════════════════════════════════════

/// Product image that handles asset paths, network URLs and missing images.
Widget _menuImage(String? url, {required double height}) {
  Widget fallback() => Container(
        height: height,
        width: double.infinity,
        color: _MenuScreenState.kBorderColor.withValues(alpha: 0.6),
        child: const Icon(CupertinoIcons.cube_box,
            color: _MenuScreenState.kTextSecondary, size: 30),
      );

  if (url == null) return fallback();
  if (url.startsWith('http')) {
    return CachedNetworkImage(
      imageUrl: url,
      width: double.infinity,
      height: height,
      fit: BoxFit.cover,
      placeholder: (context, _) => Container(
        height: height,
        color: _MenuScreenState.kBorderColor.withValues(alpha: 0.6),
      ),
      errorWidget: (context, _, __) => fallback(),
    );
  }
  return Image.asset(
    url,
    width: double.infinity,
    height: height,
    fit: BoxFit.cover,
    errorBuilder: (_, __, ___) => fallback(),
  );
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CircleIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: _MenuScreenState.kCardColor,
          shape: BoxShape.circle,
          border: Border.all(color: _MenuScreenState.kHairline, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Icon(icon, color: _MenuScreenState.kInk, size: 20),
      ),
    );
  }
}

/// Card wrapper with press-scale feedback.
class _PressableCard extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  const _PressableCard({required this.child, required this.onTap});

  @override
  State<_PressableCard> createState() => _PressableCardState();
}

class _PressableCardState extends State<_PressableCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AddButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: _MenuScreenState.kInk,
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
        child: const Icon(CupertinoIcons.add, color: Colors.white, size: 17),
      ),
    );
  }
}

class _QuantityStepper extends StatelessWidget {
  final int quantity;
  final VoidCallback onAdd;
  final VoidCallback onRemove;
  const _QuantityStepper({
    super.key,
    required this.quantity,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: _MenuScreenState.kInk,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepBtn(icon: CupertinoIcons.minus, onTap: onRemove),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Text(
              '$quantity',
              style: GoogleFonts.afacad(
                color: _MenuScreenState.kGold,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          _StepBtn(icon: CupertinoIcons.plus, onTap: onAdd),
        ],
      ),
    );
  }
}

class _StepBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _StepBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: SizedBox(
        width: 22,
        height: 24,
        child: Icon(icon, color: Colors.white, size: 13),
      ),
    );
  }
}

/// Bottom sheet for product detail.
class _ProductDetailSheet extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onAdd;
  const _ProductDetailSheet({required this.product, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.74,
      minChildSize: 0.5,
      maxChildSize: 0.92,
      expand: false,
      builder: (_, controller) {
        return Container(
          decoration: const BoxDecoration(
            color: _MenuScreenState.kBackgroundColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: _MenuScreenState.kHairline,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: controller,
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
                  children: [
                    Hero(
                      tag: 'product-${product.id}',
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.12),
                              blurRadius: 24,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(28),
                          child: _menuImage(product.imageUrl, height: 230),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      product.category.toUpperCase(),
                      style: GoogleFonts.afacad(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2,
                        color: _MenuScreenState.kGold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            product.name,
                            style: GoogleFonts.afacad(
                              fontSize: 27,
                              fontWeight: FontWeight.w700,
                              color: _MenuScreenState.kInk,
                              letterSpacing: -0.4,
                              height: 1.15,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                'KSh ',
                                style: GoogleFonts.afacad(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                  color: _MenuScreenState.kGold,
                                ),
                              ),
                              Text(
                                product.price.toStringAsFixed(0),
                                style: GoogleFonts.afacad(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: _MenuScreenState.kInk,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Container(
                        width: 36, height: 2, color: _MenuScreenState.kGold),
                    const SizedBox(height: 16),
                    Text(
                      product.description,
                      style: GoogleFonts.afacad(
                        fontSize: 15.5,
                        color: _MenuScreenState.kTextSecondary,
                        height: 1.55,
                      ),
                    ),
                    const SizedBox(height: 28),
                    GestureDetector(
                      onTap: () {
                        onAdd();
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(26, 10, 10, 10),
                        decoration: BoxDecoration(
                          color: _MenuScreenState.kInk,
                          borderRadius: BorderRadius.circular(32),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.25),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Text(
                              'Add to cart',
                              style: GoogleFonts.afacad(
                                fontSize: 16.5,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.3,
                                color: Colors.white,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              width: 42,
                              height: 42,
                              decoration: const BoxDecoration(
                                color: _MenuScreenState.kGold,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                CupertinoIcons.cart_badge_plus,
                                color: _MenuScreenState.kInk,
                                size: 19,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}