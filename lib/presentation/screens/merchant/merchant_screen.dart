import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kericho_delivery/data/models/cart_model.dart';
import 'package:kericho_delivery/data/models/product_model.dart';
import 'package:provider/provider.dart';
import 'package:kericho_delivery/presentation/providers/merchant_provider.dart';
import 'package:kericho_delivery/presentation/providers/app_provider.dart';
import 'package:kericho_delivery/presentation/router/app_router.dart';
import 'package:kericho_delivery/presentation/screens/product/product_detail_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';

// KulaHub brand palette (matches home/menu/cart/rewards screens)
const Color kPrimaryColor = Color(0xFFFF5A36);
const Color kSecondaryColor = Color(0xFFFFB020);
const Color kBackgroundColor = Color(0xFFFFF8F1);
const Color kCardColor = Colors.white;
const Color kTextPrimary = Color(0xFF16181D);
const Color kTextSecondary = Color(0xFF6C757D);
const Color kBorderColor = Color(0xFFF0E4D8);
const Color kSuccessColor = Color(0xFF2EAD6C);
const Color kErrorColor = Color(0xFFE5484D);

// Refined accents used on this screen
const Color kInk = Color(0xFF1B1816);
const Color kHairline = Color(0xFFE9DCCB);

const double _kHeroHeight = 320;

class MerchantScreen extends StatefulWidget {
  final String merchantId;
  final String merchantName;
  final String? merchantImageUrl;

  const MerchantScreen({
    super.key,
    required this.merchantId,
    required this.merchantName,
    this.merchantImageUrl,
  });

  @override
  State<MerchantScreen> createState() => _MerchantScreenState();
}

class _MerchantScreenState extends State<MerchantScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MerchantProvider>(context, listen: false)
          .selectMerchant(widget.merchantId);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _addToCart(ProductModel product) {
    HapticFeedback.mediumImpact();
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    appProvider.addToCart(CartItem(product: product, quantity: 1));

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(CupertinoIcons.checkmark_alt_circle_fill,
                color: kPrimaryColor, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text('${product.name} added to cart',
                  style: GoogleFonts.afacad(
                      color: Colors.white,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600)),
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

  void _navigateToCart() {
    HapticFeedback.mediumImpact();
    AppRouter.pushNamed(AppRouter.cart);
  }

  @override
  Widget build(BuildContext context) {
    final merchantProvider = Provider.of<MerchantProvider>(context);
    final appProvider = Provider.of<AppProvider>(context);
    final merchant = merchantProvider.selectedMerchant;
    final isFavorite = merchant != null &&
        appProvider.favorites.any((m) => m.id == merchant.id);

    if (merchant == null || merchantProvider.isLoading) {
      return Scaffold(
        backgroundColor: kInk,
        body: Stack(
          fit: StackFit.expand,
          children: [
            if (widget.merchantImageUrl != null)
              widget.merchantImageUrl!.startsWith('http')
                  ? CachedNetworkImage(imageUrl: widget.merchantImageUrl!, fit: BoxFit.cover)
                  : Image.asset(widget.merchantImageUrl!, fit: BoxFit.cover),
            Container(color: kInk.withValues(alpha: 0.6)),
            const Center(
              child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation(kPrimaryColor)),
            ),
          ],
        ),
      );
    }

    final categories = [
      'All',
      ...merchantProvider.merchantProducts.map((p) => p.category).toSet(),
    ];

    final filteredProducts = merchantProvider.merchantProducts.where((p) {
      final matchesCategory =
          _selectedCategory == 'All' || p.category == _selectedCategory;
      final matchesSearch = _searchQuery.isEmpty ||
          p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.description.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildHeroAppBar(merchant, isFavorite, appProvider),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAbout(merchant),
                  const SizedBox(height: 14),
                ],
              ),
            ),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: _StickyHeaderDelegate(
              height: 124,
              child: _buildSearchAndCategories(categories),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 26, 24, 4),
              child: _buildSectionTitle(filteredProducts.length),
            ),
          ),
          filteredProducts.isEmpty
              ? SliverToBoxAdapter(child: _buildEmptyState())
              : SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _AnimatedEntry(
                        key: ValueKey(
                            '${_selectedCategory}_${filteredProducts[index].name}_$index'),
                        index: index,
                        child: _buildProductRow(
                          filteredProducts[index],
                          isLast: index == filteredProducts.length - 1,
                        ),
                      ),
                      childCount: filteredProducts.length,
                    ),
                  ),
                ),
          SliverToBoxAdapter(
              child:
                  SizedBox(height: appProvider.cartItemCount > 0 ? 120 : 40)),
        ],
      ),
      floatingActionButton:
          appProvider.cartItemCount > 0 ? _buildCartBar(appProvider) : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  // ───────────────────────── HERO ─────────────────────────

  Widget _roundIconButton({
    required IconData icon,
    required VoidCallback onTap,
    Color color = kTextPrimary,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.92),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.14),
                blurRadius: 12,
                offset: const Offset(0, 4)),
          ],
        ),
        child: Icon(icon, color: color, size: 19),
      ),
    );
  }

  Widget _buildHeroAppBar(merchant, bool isFavorite, AppProvider appProvider) {
    final topPad = MediaQuery.of(context).padding.top;
    final collapsedHeight = kToolbarHeight + topPad;

    return SliverAppBar(
      pinned: true,
      stretch: true,
      automaticallyImplyLeading: false,
      expandedHeight: _kHeroHeight,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      toolbarHeight: kToolbarHeight,
      collapsedHeight: kToolbarHeight,
      flexibleSpace: LayoutBuilder(
        builder: (context, constraints) {
          final t = ((constraints.maxHeight - collapsedHeight) /
                  (_kHeroHeight - collapsedHeight))
              .clamp(0.0, 1.0);

          return ClipRRect(
            // Curved bottom edge; eases to square as the bar pins
            borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(36 * Curves.easeOut.transform(t))),
            child: Stack(
            fit: StackFit.expand,
            children: [
              // Image with parallax-like scale
              Transform.scale(
                scale: 1.0 + (1 - t) * 0.08,
                child: merchant.imageUrl != null
                    ? (merchant.imageUrl.startsWith('http')
                        ? CachedNetworkImage(
                            imageUrl: merchant.imageUrl,
                            fit: BoxFit.cover,
                            placeholder: (context, url) =>
                                Container(color: kInk.withValues(alpha: 0.9)),
                            errorWidget: (context, url, error) =>
                                _buildHeaderPlaceholder(),
                          )
                        : Image.asset(merchant.imageUrl, fit: BoxFit.cover))
                    : _buildHeaderPlaceholder(),
              ),
              // Rich gradient scrim
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.0, 0.35, 1.0],
                    colors: [
                      Colors.black.withValues(alpha: 0.45),
                      Colors.black.withValues(alpha: 0.05),
                      Colors.black.withValues(alpha: 0.85),
                    ],
                  ),
                ),
              ),
              // Solid ink wash as it collapses
              Container(color: kInk.withValues(alpha: (1 - t) * 0.96)),

              // Hero text
              Positioned(
                left: 24,
                right: 24,
                bottom: 26,
                child: Opacity(
                  opacity: Curves.easeOut.transform(t),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStatusPill(merchant.isOpen),
                      const SizedBox(height: 12),
                      Text(
                        merchant.name,
                        style: GoogleFonts.afacad(
                          fontSize: 34,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: -0.5,
                          height: 1.05,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(CupertinoIcons.location_solid,
                              size: 13, color: kPrimaryColor),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              merchant.address ?? 'Kericho, Kenya',
                              style: GoogleFonts.afacad(
                                  fontSize: 14,
                                  letterSpacing: 0.2,
                                  color: Colors.white.withValues(alpha: 0.88)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Collapsed title
              Positioned(
                left: 76,
                right: 76,
                top: topPad,
                height: kToolbarHeight,
                child: Opacity(
                  opacity: Curves.easeIn.transform(((1 - t) * 1.4 - 0.4)
                      .clamp(0.0, 1.0)),
                  child: Center(
                    child: Text(
                      merchant.name,
                      style: GoogleFonts.afacad(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),

              // Action buttons
              Positioned(
                top: topPad + 4,
                left: 20,
                right: 20,
                height: 42,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _roundIconButton(
                      icon: CupertinoIcons.back,
                      onTap: () => Navigator.of(context).maybePop(),
                    ),
                    _roundIconButton(
                      icon: isFavorite
                          ? CupertinoIcons.heart_fill
                          : CupertinoIcons.heart,
                      color: isFavorite ? kPrimaryColor : kTextPrimary,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        appProvider.toggleFavorite(merchant);
                      },
                    ),
                  ],
                ),
              ),
            ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusPill(bool isOpen) {
    final color = isOpen ? kSuccessColor : kErrorColor;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.35),
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
            isOpen ? 'OPEN NOW' : 'CLOSED',
            style: GoogleFonts.afacad(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderPlaceholder() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2B2623), kInk],
        ),
      ),
      child: Icon(CupertinoIcons.bag_fill,
          size: 56, color: Colors.white.withValues(alpha: 0.2)),
    );
  }

  // ───────────────────────── INFO ─────────────────────────

  Widget _buildAbout(merchant) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ABOUT',
          style: GoogleFonts.afacad(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
            color: kPrimaryColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          merchant.description,
          style: GoogleFonts.afacad(
              fontSize: 15.5, color: kTextSecondary, height: 1.5),
        ),
      ],
    );
  }

  // ───────────────────────── SEARCH + CATEGORIES ─────────────────────────

  Widget _buildSearchAndCategories(List<String> categories) {
    return Container(
      decoration: const BoxDecoration(
        color: kBackgroundColor,
        border: Border(bottom: BorderSide(color: kHairline, width: 0.8)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildSearchField(),
          const SizedBox(height: 12),
          _buildCategoryChips(categories),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(23),
        border: Border.all(color: kHairline, width: 1.2),
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          const Icon(CupertinoIcons.search, color: kTextSecondary, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchQuery = value),
              cursorColor: kPrimaryColor,
              style: GoogleFonts.afacad(color: kTextPrimary, fontSize: 15),
              decoration: InputDecoration(
                hintText: 'Search the menu',
                hintStyle:
                    GoogleFonts.afacad(color: kTextSecondary, fontSize: 15),
                filled: false,
                isDense: true,
                isCollapsed: true,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
            ),
          ),
          if (_searchQuery.isNotEmpty)
            GestureDetector(
              onTap: () {
                _searchController.clear();
                setState(() => _searchQuery = '');
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 14),
                child: Icon(CupertinoIcons.xmark_circle_fill,
                    color: kTextSecondary, size: 17),
              ),
            )
          else
            const SizedBox(width: 14),
        ],
      ),
    );
  }

  Widget _buildCategoryChips(List<String> categories) {
    return SizedBox(
      height: 36,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category == _selectedCategory;
          return Padding(
            padding:
                EdgeInsets.only(right: index < categories.length - 1 ? 8 : 0),
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _selectedCategory = category);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 18),
                decoration: BoxDecoration(
                  color: isSelected ? kPrimaryColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                      color: isSelected ? kPrimaryColor : kHairline, width: 1),
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
    );
  }

  // ───────────────────────── MENU ─────────────────────────

  Widget _buildSectionTitle(int count) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _selectedCategory == 'All' ? 'The Menu' : _selectedCategory,
                style: GoogleFonts.afacad(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: kInk,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 8),
              Container(width: 36, height: 2, color: kPrimaryColor),
            ],
          ),
        ),
        Text(
          '$count ${count == 1 ? 'item' : 'items'}',
          style: GoogleFonts.afacad(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: kTextSecondary),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 56, horizontal: 24),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: kHairline),
            ),
            child: const Icon(CupertinoIcons.search,
                size: 28, color: kTextSecondary),
          ),
          const SizedBox(height: 20),
          Text('Nothing here yet',
              style: GoogleFonts.afacad(
                  fontSize: 21, fontWeight: FontWeight.w700, color: kInk)),
          const SizedBox(height: 8),
          Text('Try a different category or search term.',
              textAlign: TextAlign.center,
              style: GoogleFonts.afacad(fontSize: 14.5, color: kTextSecondary)),
        ],
      ),
    );
  }

  Widget _buildProductImage(ProductModel product) {
    Widget fallback() => Container(
          color: kBorderColor.withValues(alpha: 0.6),
          child: const Icon(CupertinoIcons.cube_box,
              color: kTextSecondary, size: 26),
        );

    if (product.imageUrl == null) return fallback();
    if (product.imageUrl!.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: product.imageUrl!,
        fit: BoxFit.cover,
        placeholder: (context, url) =>
            Container(color: kBorderColor.withValues(alpha: 0.6)),
        errorWidget: (context, url, error) => fallback(),
      );
    }
    return Image.asset(product.imageUrl!, fit: BoxFit.cover);
  }

  Widget _buildProductRow(ProductModel product, {required bool isLast}) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _showProductDetails(product),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : const Border(bottom: BorderSide(color: kHairline, width: 1)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: GoogleFonts.afacad(
                          fontSize: 17.5,
                          fontWeight: FontWeight.w700,
                          color: kInk,
                          height: 1.2),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      product.description,
                      style: GoogleFonts.afacad(
                          fontSize: 13.5, color: kTextSecondary, height: 1.4),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Text(
                          'KSh ',
                          style: GoogleFonts.afacad(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                              color: kPrimaryColor),
                        ),
                        Text(
                          product.price.toStringAsFixed(0),
                          style: GoogleFonts.afacad(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: kInk),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: 108,
              height: 116,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    left: 0,
                    top: 0,
                    child: Container(
                      width: 108,
                      height: 108,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 14,
                              offset: const Offset(0, 6)),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: _buildProductImage(product),
                      ),
                    ),
                  ),
                  Positioned(
                    right: -6,
                    bottom: 0,
                    child: GestureDetector(
                      onTap: () => _addToCart(product),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: kInk,
                          shape: BoxShape.circle,
                          border: Border.all(color: kBackgroundColor, width: 3),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withValues(alpha: 0.25),
                                blurRadius: 8,
                                offset: const Offset(0, 3)),
                          ],
                        ),
                        child: const Icon(CupertinoIcons.add,
                            color: Colors.white, size: 17),
                      ),
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

  // ───────────────────────── CART BAR ─────────────────────────

  Widget _buildCartBar(AppProvider appProvider) {
    final count = appProvider.cartItemCount;
    return GestureDetector(
      onTap: _navigateToCart,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(10, 10, 22, 10),
        decoration: BoxDecoration(
          color: kInk,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: kPrimaryColor.withValues(alpha: 0.35), width: 1),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 24,
                offset: const Offset(0, 10)),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                  color: kPrimaryColor, shape: BoxShape.circle),
              alignment: Alignment.center,
              child: Text(
                '$count',
                style: GoogleFonts.afacad(
                    color: kInk, fontWeight: FontWeight.w800, fontSize: 16),
              ),
            ),
            const SizedBox(width: 14),
            Text(
              'View cart',
              style: GoogleFonts.afacad(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                  fontSize: 16),
            ),
            const Spacer(),
            Text(
              'KSh ${appProvider.cartTotal.toStringAsFixed(0)}',
              style: GoogleFonts.afacad(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 17),
            ),
            const SizedBox(width: 10),
            const Icon(CupertinoIcons.arrow_right, color: kPrimaryColor, size: 18),
          ],
        ),
      ),
    );
  }

  void _showProductDetails(ProductModel product) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product)),
    );
  }
}

// ───────────────────────── HELPERS ─────────────────────────

/// Pins a fixed-height child at the top while scrolling.
class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double height;
  final Widget child;

  _StickyHeaderDelegate({required this.height, required this.child});

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
          BuildContext context, double shrinkOffset, bool overlapsContent) =>
      SizedBox.expand(child: child);

  @override
  bool shouldRebuild(covariant _StickyHeaderDelegate oldDelegate) => true;
}

/// Soft fade + rise-in for list rows, lightly staggered.
class _AnimatedEntry extends StatelessWidget {
  final int index;
  final Widget child;

  const _AnimatedEntry({super.key, required this.index, required this.child});

  @override
  Widget build(BuildContext context) {
    final delay = index.clamp(0, 6) * 50;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 380 + delay),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, (1 - value) * 18),
          child: child,
        ),
      ),
      child: child,
    );
  }
}