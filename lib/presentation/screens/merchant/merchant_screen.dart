import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kericho_delivery/data/models/cart_model.dart';
import 'package:kericho_delivery/data/models/product_model.dart';
import 'package:provider/provider.dart';
import 'package:kericho_delivery/presentation/providers/merchant_provider.dart';
import 'package:kericho_delivery/presentation/providers/app_provider.dart';
import 'package:kericho_delivery/presentation/router/app_router.dart';
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
        body: const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(kPrimaryColor))),
      );
    }

    final categories = [
      'All',
      ...merchantProvider.merchantProducts.map((p) => p.category).toSet(),
    ];

    final filteredProducts = merchantProvider.merchantProducts.where((p) {
      final matchesCategory = _selectedCategory == 'All' || p.category == _selectedCategory;
      final matchesSearch = _searchQuery.isEmpty ||
          p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.description.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeaderImage(merchant.imageUrl)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTitleRow(merchant),
                  const SizedBox(height: 10),
                  Text(
                    merchant.description,
                    style: GoogleFonts.afacad(fontSize: 14, color: kTextSecondary, height: 1.4),
                  ),
                  const SizedBox(height: 16),
                  _buildDetailChips(merchant),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Icon(CupertinoIcons.location_solid, size: 16, color: kTextSecondary),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          merchant.address ?? 'Kericho, Kenya',
                          style: GoogleFonts.afacad(fontSize: 13, color: kTextSecondary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildSearchField(),
                  const SizedBox(height: 16),
                  _buildCategoryChips(categories),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: filteredProducts.isEmpty
                ? SliverToBoxAdapter(child: _buildEmptyState())
                : SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.72,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildProductCard(filteredProducts[index]),
                      childCount: filteredProducts.length,
                    ),
                  ),
          ),
          SliverToBoxAdapter(child: SizedBox(height: appProvider.cartItemCount > 0 ? 110 : 24)),
        ],
      ),
      floatingActionButton: appProvider.cartItemCount > 0 ? _buildCartBar(appProvider) : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildHeaderImage(String? imageUrl) {
    return Stack(
      children: [
        Container(
          height: 220,
          width: double.infinity,
          color: kBorderColor,
          child: imageUrl != null
              ? CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(color: kBorderColor),
                  errorWidget: (context, url, error) => _buildHeaderPlaceholder(),
                )
              : _buildHeaderPlaceholder(),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            height: 70,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withValues(alpha: 0.35)],
              ),
            ),
          ),
        ),
        Positioned(
          top: 48,
          left: 20,
          child: GestureDetector(
            onTap: () => Navigator.of(context).maybePop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: const Icon(CupertinoIcons.back, color: kTextPrimary, size: 20),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderPlaceholder() {
    return Container(
      color: kBorderColor,
      child: Icon(CupertinoIcons.bag_fill, size: 56, color: kTextSecondary.withValues(alpha: 0.5)),
    );
  }

  Widget _buildTitleRow(merchant) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            merchant.name,
            style: GoogleFonts.afacad(fontSize: 24, fontWeight: FontWeight.w800, color: kTextPrimary, letterSpacing: -0.3),
          ),
        ),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: (merchant.isOpen ? kSuccessColor : kErrorColor).withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(CupertinoIcons.circle_fill, size: 8, color: merchant.isOpen ? kSuccessColor : kErrorColor),
              const SizedBox(width: 6),
              Text(
                merchant.isOpen ? 'Open' : 'Closed',
                style: GoogleFonts.afacad(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: merchant.isOpen ? kSuccessColor : kErrorColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailChips(merchant) {
    return Row(
      children: [
        _buildDetailChip(CupertinoIcons.star_fill, '${merchant.rating.toStringAsFixed(1)} (${merchant.ratingCount})', kSecondaryColor),
        const SizedBox(width: 8),
        _buildDetailChip(CupertinoIcons.clock, '${merchant.deliveryTime} min', kTextSecondary),
        const SizedBox(width: 8),
        _buildDetailChip(
          CupertinoIcons.car_detailed,
          merchant.deliveryFee == 0 ? 'Free' : 'KSh ${merchant.deliveryFee.toInt()}',
          kTextSecondary,
        ),
      ],
    );
  }

  Widget _buildDetailChip(IconData icon, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: kCardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: kBorderColor, width: 1),
        ),
        child: Column(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.afacad(fontSize: 11.5, fontWeight: FontWeight.w700, color: kTextPrimary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
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
              onChanged: (value) => setState(() => _searchQuery = value),
              style: GoogleFonts.afacad(color: kTextPrimary, fontSize: 15),
              decoration: InputDecoration(
                hintText: 'Search menu items...',
                hintStyle: GoogleFonts.afacad(color: kTextSecondary, fontSize: 15),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChips(List<String> categories) {
    return SizedBox(
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
                  border: Border.all(color: isSelected ? kPrimaryColor : kBorderColor, width: 1.2),
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
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Icon(CupertinoIcons.search, size: 44, color: kTextSecondary),
          const SizedBox(height: 16),
          Text('No items found', style: GoogleFonts.afacad(fontSize: 18, fontWeight: FontWeight.w700, color: kTextPrimary)),
          const SizedBox(height: 8),
          Text('Try a different category', style: GoogleFonts.afacad(fontSize: 14, color: kTextSecondary)),
        ],
      ),
    );
  }

  Widget _buildProductCard(ProductModel product) {
    return GestureDetector(
      onTap: () => _showProductDetails(product),
      child: Container(
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
                  child: Container(
                    height: 100,
                    width: double.infinity,
                    color: kBackgroundColor,
                    child: product.imageUrl != null
                        ? (product.imageUrl!.startsWith('http')
                            ? CachedNetworkImage(
                                imageUrl: product.imageUrl!,
                                fit: BoxFit.cover,
                                errorWidget: (context, url, error) => Icon(CupertinoIcons.cube_box, color: kTextSecondary),
                              )
                            : Image.asset(product.imageUrl!, fit: BoxFit.cover))
                        : Icon(CupertinoIcons.cube_box, color: kTextSecondary),
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
      ),
    );
  }

  Widget _buildCartBar(AppProvider appProvider) {
    return GestureDetector(
      onTap: _navigateToCart,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: kPrimaryColor,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(color: kPrimaryColor.withValues(alpha: 0.35), blurRadius: 16, offset: const Offset(0, 6)),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
              child: const Icon(CupertinoIcons.cart_fill, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            Text(
              '${appProvider.cartItemCount} item${appProvider.cartItemCount > 1 ? 's' : ''}',
              style: GoogleFonts.afacad(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15),
            ),
            const Spacer(),
            Text(
              'KSh ${appProvider.cartTotal.toStringAsFixed(0)}',
              style: GoogleFonts.afacad(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16),
            ),
            const SizedBox(width: 6),
            const Icon(CupertinoIcons.arrow_right, color: Colors.white, size: 18),
          ],
        ),
      ),
    );
  }

  void _showProductDetails(ProductModel product) {
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
                content: Text('${product.name} added to cart', style: GoogleFonts.afacad(color: Colors.white)),
                backgroundColor: kSuccessColor,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                margin: const EdgeInsets.all(16),
                duration: const Duration(seconds: 1),
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
        color: kCardColor,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(28), topRight: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20, 14, 20, MediaQuery.of(context).viewInsets.bottom + 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: kBorderColor, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 18),
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: 180,
                  height: 140,
                  color: kBackgroundColor,
                  child: widget.product.imageUrl != null
                      ? (widget.product.imageUrl!.startsWith('http')
                          ? CachedNetworkImage(imageUrl: widget.product.imageUrl!, fit: BoxFit.cover)
                          : Image.asset(widget.product.imageUrl!, fit: BoxFit.cover))
                      : Icon(CupertinoIcons.cube_box, size: 48, color: kTextSecondary),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              widget.product.name,
              style: GoogleFonts.afacad(fontSize: 22, fontWeight: FontWeight.w800, color: kTextPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              widget.product.description,
              style: GoogleFonts.afacad(fontSize: 14.5, color: kTextSecondary, height: 1.4),
            ),
            const SizedBox(height: 14),
            Text(
              'KSh ${widget.product.price.toStringAsFixed(0)}',
              style: GoogleFonts.afacad(fontSize: 24, fontWeight: FontWeight.w800, color: kPrimaryColor),
            ),
            const SizedBox(height: 20),
            if (widget.product.options != null && widget.product.options!.isNotEmpty) ...[
              Text('Options', style: GoogleFonts.afacad(fontSize: 15, fontWeight: FontWeight.w800, color: kTextPrimary)),
              const SizedBox(height: 10),
              ...widget.product.options!.map(_buildOptionSection),
              const SizedBox(height: 10),
            ],
            if (widget.product.addons != null && widget.product.addons!.isNotEmpty) ...[
              Text('Add-ons', style: GoogleFonts.afacad(fontSize: 15, fontWeight: FontWeight.w800, color: kTextPrimary)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: widget.product.addons!.map((addon) {
                  final isSelected = _selectedOptions['addons']?.contains(addon) ?? false;
                  return _buildChoiceChip(
                    label: addon,
                    isSelected: isSelected,
                    onTap: () {
                      setState(() {
                        final current = _selectedOptions['addons'] ?? [];
                        if (isSelected) {
                          current.remove(addon);
                        } else {
                          _selectedOptions['addons'] = [...current, addon];
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],
            Container(
              decoration: BoxDecoration(
                color: kBackgroundColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: kBorderColor, width: 1.2),
              ),
              child: TextField(
                onChanged: (value) => _specialInstructions = value,
                style: GoogleFonts.afacad(fontSize: 14, color: kTextPrimary),
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Special instructions (optional)',
                  hintStyle: GoogleFonts.afacad(fontSize: 14, color: kTextSecondary),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(14),
                ),
              ),
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(color: kBackgroundColor, borderRadius: BorderRadius.circular(20)),
                  child: Row(
                    children: [
                      _buildStepperButton(
                        icon: CupertinoIcons.minus,
                        onTap: _quantity > 1 ? () => setState(() => _quantity--) : null,
                      ),
                      SizedBox(
                        width: 32,
                        child: Text(
                          '$_quantity',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.afacad(fontSize: 16, fontWeight: FontWeight.w700, color: kTextPrimary),
                        ),
                      ),
                      _buildStepperButton(
                        icon: CupertinoIcons.add,
                        onTap: () => setState(() => _quantity++),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      final selectedOptionsList = _selectedOptions.values.expand((list) => list).toList();
                      widget.onAddToCart(
                        _quantity,
                        _specialInstructions,
                        selectedOptionsList.isEmpty ? null : selectedOptionsList,
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: kPrimaryColor,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(color: kPrimaryColor.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 5)),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          'Add to Cart',
                          style: GoogleFonts.afacad(fontSize: 15.5, fontWeight: FontWeight.w700, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepperButton({required IconData icon, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        alignment: Alignment.center,
        child: Icon(icon, size: 16, color: onTap == null ? kTextSecondary.withValues(alpha: 0.4) : kPrimaryColor),
      ),
    );
  }

  Widget _buildChoiceChip({required String label, required bool isSelected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? kPrimaryColor : kBackgroundColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: isSelected ? kPrimaryColor : kBorderColor, width: 1.2),
        ),
        child: Text(
          label,
          style: GoogleFonts.afacad(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.white : kTextSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildOptionSection(ProductOption option) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(option.name, style: GoogleFonts.afacad(fontSize: 13.5, fontWeight: FontWeight.w700, color: kTextPrimary)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: option.choices.map((choice) {
              final isSelected = _selectedOptions[option.name]?.contains(choice) ?? false;
              return _buildChoiceChip(
                label: choice,
                isSelected: isSelected,
                onTap: () {
                  setState(() {
                    if (option.isMultiple) {
                      final current = _selectedOptions[option.name] ?? [];
                      if (isSelected) {
                        current.remove(choice);
                      } else {
                        _selectedOptions[option.name] = [...current, choice];
                      }
                    } else {
                      _selectedOptions[option.name] = isSelected ? [] : [choice];
                    }
                  });
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
