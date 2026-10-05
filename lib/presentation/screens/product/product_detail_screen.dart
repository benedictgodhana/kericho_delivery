import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:kericho_delivery/data/models/cart_model.dart';
import 'package:kericho_delivery/data/models/product_model.dart';
import 'package:kericho_delivery/presentation/providers/app_provider.dart';

class ProductDetailScreen extends StatefulWidget {
  final ProductModel product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  // KulaHub brand palette (matches home/menu/merchant screens)
  static const Color kPrimaryColor = Color(0xFFFF5A36);
  static const Color kPrimaryDark = Color(0xFFC73F22);
  static const Color kBackgroundColor = Color(0xFFFFF8F1);
  static const Color kCardColor = Colors.white;
  static const Color kTextPrimary = Color(0xFF16181D);
  static const Color kTextSecondary = Color(0xFF6C757D);
  static const Color kBorderColor = Color(0xFFF0E4D8);
  static const Color kSuccessColor = Color(0xFF2EAD6C);

  static const double _heroHeight = 300;
  static const double _imageSize = 280;

  int _quantity = 1;
  final Map<String, List<String>> _selectedOptions = {};
  bool _showReviews = false;

  double get _unitPrice =>
      widget.product.discountedPrice ?? widget.product.price;

  void _addToCart() {
    HapticFeedback.mediumImpact();
    final selectedOptionsList =
        _selectedOptions.values.expand((list) => list).toList();
    context.read<AppProvider>().addToCart(
          CartItem(
            product: widget.product,
            quantity: _quantity,
            selectedOptions:
                selectedOptionsList.isEmpty ? null : selectedOptionsList,
          ),
        );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${widget.product.name} added to cart',
            style: GoogleFonts.afacad(color: Colors.white)),
        backgroundColor: kSuccessColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 1),
      ),
    );
    Navigator.of(context).pop();
  }

  Widget _buildProductImage() {
    final product = widget.product;
    if (product.imageUrl == null) {
      return Icon(CupertinoIcons.cube_box, size: 72, color: kTextSecondary);
    }
    return product.imageUrl!.startsWith('http')
        ? CachedNetworkImage(
            imageUrl: product.imageUrl!,
            fit: BoxFit.contain,
            errorWidget: (context, url, error) =>
                Icon(CupertinoIcons.cube_box, size: 72, color: kTextSecondary),
          )
        : Image.asset(product.imageUrl!, fit: BoxFit.contain);
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    return Scaffold(
      backgroundColor: kCardColor,
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                height: _heroHeight,
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [kPrimaryColor, kPrimaryDark],
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(90),
                    bottomRight: Radius.circular(90),
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(24, _imageSize / 2 - 20, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              product.name,
                              style: GoogleFonts.afacad(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  color: kTextPrimary),
                            ),
                          ),
                          Text(
                            'KSh ${_unitPrice.toStringAsFixed(0)}',
                            style: GoogleFonts.afacad(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: kPrimaryColor),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        product.category,
                        style: GoogleFonts.afacad(
                            fontSize: 14, color: kTextSecondary),
                      ),
                      const SizedBox(height: 20),
                      _buildTabToggle(),
                      const SizedBox(height: 20),
                      _showReviews
                          ? _buildReviewsPlaceholder()
                          : _buildDetailsTab(product),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            top: _heroHeight - _imageSize / 2,
            left: 0,
            right: 0,
            child: Center(
              child: SizedBox(
                  width: _imageSize,
                  height: _imageSize,
                  child: _buildProductImage()),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildCircleButton(
                    icon: CupertinoIcons.back,
                    onTap: () => Navigator.of(context).maybePop(),
                  ),
                  _buildCircleButton(
                      icon: CupertinoIcons.ellipsis_vertical, onTap: () {}),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildCircleButton(
      {required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration:
            const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
        child: Icon(icon, color: kTextPrimary, size: 18),
      ),
    );
  }

  Widget _buildTabToggle() {
    return Row(
      children: [
        _buildTabPill(
            label: 'Details',
            isSelected: !_showReviews,
            onTap: () => setState(() => _showReviews = false)),
        const SizedBox(width: 10),
        _buildTabPill(
            label: 'Reviews',
            isSelected: _showReviews,
            onTap: () => setState(() => _showReviews = true)),
      ],
    );
  }

  Widget _buildTabPill(
      {required String label,
      required bool isSelected,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? kPrimaryColor : kCardColor,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
              color: isSelected ? kPrimaryColor : kBorderColor, width: 1.2),
        ),
        child: Text(
          label,
          style: GoogleFonts.afacad(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.white : kTextSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildDetailsTab(ProductModel product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          product.description,
          style: GoogleFonts.afacad(
              fontSize: 14.5,
              fontWeight: FontWeight.w700,
              color: kTextSecondary,
              height: 1.4),
        ),
        const SizedBox(height: 20),
        if (product.options != null && product.options!.isNotEmpty) ...[
          Text('Options',
              style: GoogleFonts.afacad(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: kTextPrimary)),
          const SizedBox(height: 10),
          ...product.options!.map(_buildOptionSection),
          const SizedBox(height: 10),
        ],
        if (product.addons != null && product.addons!.isNotEmpty) ...[
          Text('Add-ons',
              style: GoogleFonts.afacad(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: kTextPrimary)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: product.addons!.map((addon) {
              final isSelected =
                  _selectedOptions['addons']?.contains(addon) ?? false;
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
      ],
    );
  }

  Widget _buildReviewsPlaceholder() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: Center(
        child: Column(
          children: [
            Icon(CupertinoIcons.star,
                size: 40, color: kTextSecondary.withValues(alpha: 0.4)),
            const SizedBox(height: 12),
            Text('No reviews yet',
                style: GoogleFonts.afacad(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: kTextSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
        child: SizedBox(
          height: 52,
          child: Row(
            children: [
              Container(
                height: 52,
                padding: const EdgeInsets.symmetric(horizontal: 6),
                decoration: BoxDecoration(
                  color: kBackgroundColor,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: kBorderColor, width: 1.2),
                ),
                child: Row(
                  children: [
                    _buildStepperButton(
                      icon: CupertinoIcons.minus,
                      onTap: _quantity > 1
                          ? () => setState(() => _quantity--)
                          : null,
                    ),
                    SizedBox(
                      width: 28,
                      child: Text(
                        '$_quantity',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.afacad(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: kTextPrimary),
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
                  onTap: _addToCart,
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      color: kPrimaryDark,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                            color: kPrimaryColor.withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 5)),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        'Add to Cart',
                        style: GoogleFonts.afacad(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w700,
                            color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepperButton({required IconData icon, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: onTap == null
              ? kBorderColor.withValues(alpha: 0.4)
              : kPrimaryColor.withValues(alpha: 0.12),
          shape: BoxShape.circle,
        ),
        child: Icon(icon,
            size: 14,
            color: onTap == null
                ? kTextSecondary.withValues(alpha: 0.5)
                : kPrimaryColor),
      ),
    );
  }

  Widget _buildChoiceChip(
      {required String label,
      required bool isSelected,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? kPrimaryColor : kBackgroundColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
              color: isSelected ? kPrimaryColor : kBorderColor, width: 1.2),
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
          Text(option.name,
              style: GoogleFonts.afacad(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: kTextPrimary)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: option.choices.map((choice) {
              final isSelected =
                  _selectedOptions[option.name]?.contains(choice) ?? false;
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
                      _selectedOptions[option.name] =
                          isSelected ? [] : [choice];
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
