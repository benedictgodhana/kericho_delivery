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

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  static const Color kPrimaryColor = Color(0xFFFF5A36);
  static const Color kBackgroundColor = Color(0xFFFFF8F1);
  static const Color kCardColor = Colors.white;
  static const Color kTextPrimary = Color(0xFF16181D);
  static const Color kTextSecondary = Color(0xFF6C757D);
  static const Color kBorderColor = Color(0xFFF0E4D8);
  static const Color kSuccessColor = Color(0xFF2EAD6C);

  String _selectedCategory = 'All';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounceTimer;

  @override
  void dispose() {
    _searchController.dispose();
    _searchDebounceTimer?.cancel();
    super.dispose();
  }

  void _handleSearchChanged(String query) {
    _searchDebounceTimer?.cancel();
    _searchDebounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _searchQuery = query);
    });
  }

  void _addToCart(ProductModel product) {
    HapticFeedback.mediumImpact();
    context.read<AppProvider>().addToCart(CartItem(product: product, quantity: 1));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} added to cart', style: GoogleFonts.afacad(color: Colors.white)),
        backgroundColor: kSuccessColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  List<ProductModel> _filterProducts(List<ProductModel> products) {
    return products.where((product) {
      final matchesCategory = _selectedCategory == 'All' || product.category == _selectedCategory;
      final matchesSearch = _searchQuery.isEmpty ||
          product.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          product.description.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final merchantProvider = context.watch<MerchantProvider>();
    final categories = merchantProvider.getProductCategories();
    final products = _filterProducts(merchantProvider.getAllProducts());

    return Scaffold(
      backgroundColor: kBackgroundColor,
      extendBody: true,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchField(),
            _buildCategoryChips(categories),
            Expanded(
              child: products.isEmpty
                  ? _buildEmptyState()
                  : GridView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 14,
                        childAspectRatio: 0.72,
                      ),
                      itemCount: products.length,
                      itemBuilder: (context, index) => _buildProductCard(products[index]),
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).maybePop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: kCardColor,
                shape: BoxShape.circle,
                border: Border.all(color: kBorderColor, width: 1.2),
              ),
              child: const Icon(CupertinoIcons.back, color: kTextPrimary, size: 20),
            ),
          ),
          const SizedBox(width: 14),
          Text(
            'Menu',
            style: GoogleFonts.afacad(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: kTextPrimary,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
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
                onChanged: _handleSearchChanged,
                style: GoogleFonts.afacad(color: kTextPrimary, fontSize: 15),
                decoration: InputDecoration(
                  hintText: 'Search the menu...',
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

  Widget _buildCategoryChips(List<String> categories) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: SizedBox(
        height: 40,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            final isSelected = category == _selectedCategory;
            return Padding(
              padding: EdgeInsets.only(right: index < categories.length - 1 ? 10 : 0),
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() => _selectedCategory = category);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
                  decoration: BoxDecoration(
                    color: isSelected ? kPrimaryColor : kCardColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? kPrimaryColor : kBorderColor,
                      width: 1.2,
                    ),
                  ),
                  child: Text(
                    category,
                    style: GoogleFonts.afacad(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
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

  Widget _buildProductCard(ProductModel product) {
    return Container(
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: kBorderColor, width: 1),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2)),
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
                        height: 110,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        height: 110,
                        color: kBackgroundColor,
                        child: Icon(CupertinoIcons.cube_box, color: kTextSecondary),
                      ),
              ),
              Positioned(
                right: 10,
                bottom: -14,
                child: GestureDetector(
                  onTap: () => _addToCart(product),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: kPrimaryColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(color: kPrimaryColor.withValues(alpha: 0.35), blurRadius: 6, offset: const Offset(0, 2)),
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
                  style: GoogleFonts.afacad(fontSize: 14.5, fontWeight: FontWeight.w700, color: kTextPrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  product.description,
                  style: GoogleFonts.afacad(fontSize: 12, color: kTextSecondary, height: 1.3),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  'KSh ${product.price.toStringAsFixed(0)}',
                  style: GoogleFonts.afacad(fontSize: 13.5, fontWeight: FontWeight.w700, color: kPrimaryColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(CupertinoIcons.search, size: 44, color: kTextSecondary),
            const SizedBox(height: 16),
            Text(
              'No items found',
              style: GoogleFonts.afacad(fontSize: 18, fontWeight: FontWeight.w700, color: kTextPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              'Try a different search or category',
              style: GoogleFonts.afacad(fontSize: 14, color: kTextSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
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
              _buildNavItem(CupertinoIcons.house_fill, 'Home', false, () => Navigator.of(context).maybePop()),
              _buildNavItem(CupertinoIcons.square_grid_2x2, 'Menu', true, () {}),
              _buildCartNavItem(),
              _buildNavItem(CupertinoIcons.gift, 'Rewards', false, () => AppRouter.pushNamed(AppRouter.promotions)),
              _buildNavItem(CupertinoIcons.person_fill, 'Profile', false, () => AppRouter.pushNamed(AppRouter.profile)),
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
        AppRouter.pushNamed(AppRouter.cart);
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
                      decoration: const BoxDecoration(color: Color(0xFFE5484D), shape: BoxShape.circle),
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
