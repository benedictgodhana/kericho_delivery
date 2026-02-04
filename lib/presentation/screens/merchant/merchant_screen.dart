import 'package:flutter/material.dart';
import 'package:kericho_delivery/data/models/cart_model.dart';
import 'package:kericho_delivery/data/models/product_model.dart';
import 'package:provider/provider.dart';
import 'package:kericho_delivery/presentation/providers/merchant_provider.dart';
import 'package:kericho_delivery/presentation/providers/app_provider.dart';
import 'package:kericho_delivery/presentation/router/app_router.dart';
import 'package:kericho_delivery/core/theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class MerchantScreen extends StatefulWidget {
  final String merchantId;
  final String merchantName;

  const MerchantScreen({
    super.key,
    required this.merchantId,
    required this.merchantName,
  });

  @override
  State<MerchantScreen> createState() => _MerchantScreenState();
}

class _MerchantScreenState extends State<MerchantScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0.0;
  bool _showSearchBar = false;

  // Color palette from home screen
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

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MerchantProvider>(context, listen: false)
        .selectMerchant(widget.merchantId);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final offset = _scrollController.offset;
    setState(() => _scrollOffset = offset);
    
    if (offset > 100 && !_showSearchBar) {
      setState(() => _showSearchBar = true);
    } else if (offset <= 100 && _showSearchBar) {
      setState(() => _showSearchBar = false);
    }
  }

  void _addToCart(ProductModel product) {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    
    appProvider.addToCart(CartItem(
      product: product,
      quantity: 1,
    ));
    
    HapticFeedback.lightImpact();
    
    // Show styled snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(CupertinoIcons.checkmark_circle, color: Colors.grey.shade100),
            const SizedBox(width: 12),
            Text(
              '${product.name} added to cart',
              style: GoogleFonts.afacad(color: Colors.white),
            ),
          ],
        ),
        backgroundColor: kSuccessColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
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

    if (merchant == null || merchantProvider.isLoading) {
      return Scaffold(
        backgroundColor: kBackgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
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
                ),
                child: const Padding(
                  padding: EdgeInsets.all(12),
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                    strokeWidth: 3,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Loading menu...',
                style: GoogleFonts.afacad(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: kTextPrimary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Get unique categories from products
    final categories = ['All', ...merchantProvider.merchantProducts
      .map((p) => p.category)
      .toSet()
      .toList()];

    // Filter products by selected category
    final filteredProducts = _selectedCategory == 'All'
        ? merchantProvider.merchantProducts
        : merchantProvider.merchantProducts
            .where((p) => p.category == _selectedCategory)
            .toList();

    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              // App Bar with Hero Image
              SliverAppBar(
                expandedHeight: 280,
                floating: false,
                pinned: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                systemOverlayStyle: SystemUiOverlayStyle.light,
                leading: Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withOpacity(0.3),
                    ),
                    child: IconButton(
                      icon: const Icon(CupertinoIcons.arrow_left, size: 22),
                      color: Colors.white,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _buildCartButton(appProvider),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    children: [
                      // Hero Image with gradient overlay
                      Positioned.fill(
                        child: merchant.imageUrl != null
                            ? CachedNetworkImage(
                                imageUrl: merchant.imageUrl!,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  color: kPrimaryDark,
                                ),
                                errorWidget: (context, url, error) => Container(
                                  color: kPrimaryDark,
                                  child: Icon(
                                    CupertinoIcons.building_2_fill,
                                    size: 60,
                                    color: Colors.white.withOpacity(0.3),
                                  ),
                                ),
                              )
                            : Container(
                                color: kPrimaryDark,
                                child: Icon(
                                  CupertinoIcons.building_2_fill,
                                  size: 60,
                                  color: Colors.white.withOpacity(0.3),
                                ),
                              ),
                      ),
                      // Gradient overlay
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withOpacity(0.8),
                              Colors.transparent,
                              Colors.transparent,
                              Colors.black.withOpacity(0.4),
                            ],
                          ),
                        ),
                      ),
                      // Merchant name and status
                      Positioned(
                        bottom: 100,
                        left: 20,
                        right: 20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: merchant.isOpen 
                                  ? kSuccessColor.withOpacity(0.9)
                                  : kErrorColor.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
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
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    merchant.isOpen ? 'OPEN NOW' : 'CLOSED',
                                    style: GoogleFonts.afacad(
                                      fontSize: 13,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              merchant.name,
                              style: GoogleFonts.afacad(
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: -0.5,
                                height: 1.2,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Merchant Details
              SliverToBoxAdapter(
                child: Container(
                  decoration: BoxDecoration(
                    color: kBackgroundColor,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Rating and Details Row
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: kPrimaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: kBorderColor, width: 1),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    CupertinoIcons.star_fill,
                                    size: 16,
                                    color: kWarningColor,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    merchant.rating.toStringAsFixed(1),
                                    style: GoogleFonts.afacad(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      color: kWarningColor,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    ' (${merchant.ratingCount})',
                                    style: GoogleFonts.afacad(
                                      fontSize: 14,
                                      color: kTextSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
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
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Description
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: kCardColor,
                            borderRadius: BorderRadius.circular(16),
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
                              Row(
                                children: [
                                  Icon(
                                    CupertinoIcons.info_circle_fill,
                                    size: 18,
                                    color: kPrimaryColor,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'About',
                                    style: GoogleFonts.afacad(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: kTextPrimary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                merchant.description,
                                style: GoogleFonts.afacad(
                                  fontSize: 14.5,
                                  color: kTextSecondary,
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Icon(
                                    CupertinoIcons.location,
                                    size: 16,
                                    color: kTextSecondary,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      merchant.address ?? 'Kericho, Kenya',
                                      style: GoogleFonts.afacad(
                                        fontSize: 14,
                                        color: kTextSecondary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Category Filter
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Menu Categories',
                              style: GoogleFonts.afacad(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: kTextPrimary,
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              height: 50,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: categories.length,
                                itemBuilder: (context, index) {
                                  final category = categories[index];
                                  final isSelected = _selectedCategory == category;
                                  return Padding(
                                    padding: EdgeInsets.only(
                                      right: index < categories.length - 1 ? 8 : 0,
                                    ),
                                    child: GestureDetector(
                                      onTap: () {
                                        HapticFeedback.lightImpact();
                                        setState(() {
                                          _selectedCategory = category;
                                        });
                                      },
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 200),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          gradient: isSelected
                                              ? LinearGradient(
                                                  colors: [
                                                    kPrimaryColor,
                                                    const Color(0xFF0D9488),
                                                  ],
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                )
                                              : null,
                                          color: isSelected ? null : kCardColor,
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                            color: isSelected
                                                ? kPrimaryColor
                                                : kBorderColor,
                                            width: 1.5,
                                          ),
                                          boxShadow: [
                                            if (isSelected)
                                              BoxShadow(
                                                color: kPrimaryColor.withOpacity(0.3),
                                                blurRadius: 8,
                                                offset: const Offset(0, 3),
                                              ),
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.05),
                                              blurRadius: 6,
                                              offset: const Offset(0, 1),
                                            ),
                                          ],
                                        ),
                                        child: Text(
                                          category,
                                          style: GoogleFonts.afacad(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: isSelected
                                                ? Colors.white
                                                : kTextPrimary,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Products Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Menu Items',
                              style: GoogleFonts.afacad(
                                fontSize: 22,
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
                                  Icon(CupertinoIcons.bag_fill,
                                      size: 14, color: kPrimaryColor),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${filteredProducts.length} items',
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
                      ],
                    ),
                  ),
                ),
              ),

              // Products Grid
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                sliver: filteredProducts.isEmpty
                    ? SliverToBoxAdapter(
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 40),
                          padding: const EdgeInsets.all(40),
                          decoration: BoxDecoration(
                            color: kCardColor,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: kBorderColor),
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
                                'No items found',
                                style: GoogleFonts.afacad(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: kTextPrimary,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Try a different category',
                                style: GoogleFonts.afacad(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400,
                                  color: kTextSecondary,
                                  height: 1.5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final product = filteredProducts[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: _buildProductCard(product),
                            );
                          },
                          childCount: filteredProducts.length,
                        ),
                      ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),

          // Floating Order Summary
          if (appProvider.cartItemCount > 0) 
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: _buildOrderSummary(appProvider),
            ),
        ],
      ),

      // Floating Action Button for Cart
      floatingActionButton: appProvider.cartItemCount > 0
          ? Container(
              margin: const EdgeInsets.only(bottom: 80),
              child: FloatingActionButton(
                onPressed: _navigateToCart,
                backgroundColor: kPrimaryColor,
                elevation: 4,
                child: Stack(
                  children: [
                    Icon(CupertinoIcons.cart, color: Colors.white, size: 24),
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
              ),
            )
          : null,
    );
  }

  Widget _buildInfoChip(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBorderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: kPrimaryColor),
          const SizedBox(width: 6),
          Text(
            text,
            style: GoogleFonts.afacad(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: kTextPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartButton(AppProvider appProvider) {
    return Stack(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black.withOpacity(0.3),
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
    );
  }

  Widget _buildProductCard(ProductModel product) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _showProductDetails(product);
      },
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
          children: [
            // Product Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(18),
              ),
              child: Container(
                height: 160,
                width: double.infinity,
                color: Colors.grey[50],
                child: product.imageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: product.imageUrl!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => _buildImagePlaceholder(),
                        errorWidget: (context, url, error) =>
                            _buildImagePlaceholder(),
                      )
                    : _buildImagePlaceholder(),
              ),
            ),

            // Product Details
            Padding(
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
                              product.name,
                              style: GoogleFonts.afacad(
                                fontSize: 17,
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
                              product.description,
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: kSuccessColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: kSuccessColor, width: 1),
                        ),
                        child: Text(
                          'KSh ${product.price.toStringAsFixed(0)}',
                          style: GoogleFonts.afacad(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: kSuccessColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          product.category,
                          style: GoogleFonts.afacad(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: kPrimaryColor,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _addToCart(product),
                        child: Container(
                          padding: const EdgeInsets.all(10),
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
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(
                            CupertinoIcons.plus,
                            size: 18,
                            color: Colors.white,
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

  Widget _buildImagePlaceholder() {
    return Container(
      color: Colors.grey[50],
      child: Center(
        child: Container(
          width: 60,
          height: 60,
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
            CupertinoIcons.cube_box_fill,
            size: 28,
            color: Colors.grey[300],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderSummary(AppProvider appProvider) {
    return GestureDetector(
      onTap: _navigateToCart,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [kPrimaryColor, const Color(0xFF0D9488)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: kPrimaryColor.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                CupertinoIcons.cart_fill,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${appProvider.cartItemCount} ${appProvider.cartItemCount == 1 ? 'item' : 'items'}',
                    style: GoogleFonts.afacad(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'KSh ${appProvider.cartTotal.toStringAsFixed(2)}',
                    style: GoogleFonts.afacad(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Text(
                    'View Cart',
                    style: GoogleFonts.afacad(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: kPrimaryColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    CupertinoIcons.arrow_right,
                    color: kPrimaryColor,
                    size: 18,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showProductDetails(ProductModel product) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return ProductDetailsSheet(
          product: product,
          onAddToCart: (quantity, specialInstructions, selectedOptions) {
            final appProvider = Provider.of<AppProvider>(context, listen: false);
            
            appProvider.addToCart(CartItem(
              product: product,
              quantity: quantity,
              specialInstructions: specialInstructions,
              selectedOptions: selectedOptions,
            ));
            
            Navigator.pop(context);
            
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(CupertinoIcons.checkmark_circle, color: Colors.grey.shade100),
                    const SizedBox(width: 12),
                    Text(
                      '${product.name} added to cart',
                      style: GoogleFonts.afacad(color: Colors.white),
                    ),
                  ],
                ),
                backgroundColor: kSuccessColor,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                margin: const EdgeInsets.all(16),
                duration: const Duration(seconds: 2),
              ),
            );
          },
        );
      },
    );
  }
}

class ProductDetailsSheet extends StatefulWidget {
  final ProductModel product;
  final Function(int, String?, List<String>?) onAddToCart;

  const ProductDetailsSheet({
    super.key,
    required this.product,
    required this.onAddToCart,
  });

  @override
  State<ProductDetailsSheet> createState() => _ProductDetailsSheetState();
}

class _ProductDetailsSheetState extends State<ProductDetailsSheet> {
  int _quantity = 1;
  String? _specialInstructions;
  final Map<String, List<String>> _selectedOptions = {};

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Product Image
            Center(
              child: Container(
                width: 200,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: widget.product.imageUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: CachedNetworkImage(
                          imageUrl: widget.product.imageUrl!,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Center(
                        child: Icon(
                          CupertinoIcons.cube_box_fill,
                          size: 60,
                          color: Colors.grey[300],
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 24),

            // Product Name
            Text(
              widget.product.name,
              style: GoogleFonts.afacad(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
                letterSpacing: -0.5,
              ),
            ),

            const SizedBox(height: 8),

            // Description
            Text(
              widget.product.description,
              style: GoogleFonts.afacad(
                fontSize: 16,
                color: const Color(0xFF64748B),
                height: 1.5,
              ),
            ),

            const SizedBox(height: 24),

            // Price
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Price',
                        style: GoogleFonts.afacad(
                          fontSize: 14,
                          color: const Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        'KSh ${(widget.product.price * _quantity).toStringAsFixed(2)}',
                        style: GoogleFonts.afacad(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F766E),
                        ),
                      ),
                    ],
                  ),
                  // Quantity Selector
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0), width: 2),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            CupertinoIcons.minus,
                            color: _quantity > 1
                                ? const Color(0xFF0F766E)
                                : const Color(0xFFCBD5E1),
                          ),
                          onPressed: _quantity > 1
                              ? () {
                                  setState(() => _quantity--);
                                }
                              : null,
                        ),
                        SizedBox(
                          width: 40,
                          child: Text(
                            _quantity.toString(),
                            textAlign: TextAlign.center,
                            style: GoogleFonts.afacad(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            CupertinoIcons.plus,
                            color: Color(0xFF0F766E),
                          ),
                          onPressed: () {
                            setState(() => _quantity++);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Options
            if (widget.product.options != null && widget.product.options!.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Customize your order',
                    style: GoogleFonts.afacad(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...widget.product.options!.map((option) {
                    return _buildOptionSection(option);
                  }).toList(),
                  const SizedBox(height: 16),
                ],
              ),

            // Addons
            if (widget.product.addons != null && widget.product.addons!.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Add-ons',
                    style: GoogleFonts.afacad(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...widget.product.addons!.map((addon) {
                    return _buildAddonItem(addon);
                  }).toList(),
                  const SizedBox(height: 16),
                ],
              ),

            // Special Instructions
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Special Instructions',
                  style: GoogleFonts.afacad(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: TextField(
                    onChanged: (value) => _specialInstructions = value,
                    style: GoogleFonts.afacad(fontSize: 15),
                    decoration: const InputDecoration(
                      hintText: 'Any special requests?',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    maxLines: 3,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Add to Cart Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final selectedOptionsList = _selectedOptions.values
                    .expand((list) => list)
                    .toList();
                  
                  widget.onAddToCart(
                    _quantity,
                    _specialInstructions,
                    selectedOptionsList.isEmpty ? null : selectedOptionsList,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F766E),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(CupertinoIcons.cart_fill, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      'Add to Cart - KSh ${(widget.product.price * _quantity).toStringAsFixed(2)}',
                      style: GoogleFonts.afacad(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
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
    );
  }

  Widget _buildOptionSection(ProductOption option) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            option.name,
            style: GoogleFonts.afacad(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: option.choices.map((choice) {
              final isSelected = _selectedOptions[option.name]?.contains(choice) ?? false;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (option.isMultiple) {
                      if (isSelected) {
                        _selectedOptions[option.name]?.remove(choice);
                        if (_selectedOptions[option.name]!.isEmpty) {
                          _selectedOptions.remove(option.name);
                        }
                      } else {
                        _selectedOptions[option.name] = [
                          ..._selectedOptions[option.name] ?? [],
                          choice,
                        ];
                      }
                    } else {
                      _selectedOptions[option.name] = [choice];
                    }
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF0F766E)
                        : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF0F766E)
                          : const Color(0xFFE2E8F0),
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    choice,
                    style: GoogleFonts.afacad(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : const Color(0xFF64748B),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildAddonItem(String addon) {
    final isSelected = _selectedOptions['addons']?.contains(addon) ?? false;
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedOptions['addons']?.remove(addon);
            if (_selectedOptions['addons']!.isEmpty) {
              _selectedOptions.remove('addons');
            }
          } else {
            _selectedOptions['addons'] = [
              ..._selectedOptions['addons'] ?? [],
              addon,
            ];
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF0F766E).withOpacity(0.1)
              : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF0F766E)
                : const Color(0xFFE2E8F0),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF0F766E)
                      : const Color(0xFFCBD5E1),
                  width: 2,
                ),
                color: isSelected ? const Color(0xFF0F766E) : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(
                      CupertinoIcons.checkmark,
                      size: 12,
                      color: Colors.white,
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                addon,
                style: GoogleFonts.afacad(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}