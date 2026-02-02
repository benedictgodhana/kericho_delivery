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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MerchantProvider>(context, listen: false)
        .selectMerchant(widget.merchantId);
    });
  }

  void _addToCart(ProductModel product) {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    
    appProvider.addToCart(CartItem(
      product: product,
      quantity: 1,
    ));
    
    // Show success snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} added to cart'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _navigateToCart() {
    AppRouter.pushNamed(AppRouter.cart);
  }

  @override
  Widget build(BuildContext context) {
    final merchantProvider = Provider.of<MerchantProvider>(context);
    final appProvider = Provider.of<AppProvider>(context);
    final merchant = merchantProvider.selectedMerchant;

    if (merchant == null || merchantProvider.isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.merchantName)),
        body: const Center(child: CircularProgressIndicator()),
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
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: merchant.imageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: merchant.imageUrl!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[200],
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[200],
                        child: const Icon(Icons.store, size: 60, color: Colors.grey),
                      ),
                    )
                  : Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.store, size: 60, color: Colors.grey),
                    ),
              title: Text(
                merchant.name,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 4,
                      offset: const Offset(1, 1),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              // Cart with badge
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart, color: Colors.white),
                    onPressed: _navigateToCart,
                  ),
                  if (appProvider.cartItemCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          appProvider.cartItemCount > 9 
                            ? '9+' 
                            : appProvider.cartItemCount.toString(),
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),

          // Merchant Details
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Rating and Status
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: merchant.isOpen 
                            ? Colors.green.withOpacity(0.1)
                            : Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              merchant.isOpen 
                                ? Icons.circle
                                : Icons.circle_outlined,
                              size: 12,
                              color: merchant.isOpen ? Colors.green : Colors.red,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              merchant.isOpen ? 'Open Now' : 'Closed',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: merchant.isOpen ? Colors.green : Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Icon(Icons.star, size: 16, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(
                            merchant.rating.toStringAsFixed(1),
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            ' (${merchant.ratingCount})',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Description
                  Text(
                    merchant.description,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Details Grid
                  GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 2.5,
                    children: [
                      _buildDetailItem(
                        Icons.timer,
                        '${merchant.deliveryTime} min',
                        'Delivery',
                      ),
                      _buildDetailItem(
                        Icons.local_shipping,
                        'KSh ${merchant.deliveryFee.toInt()}',
                        'Fee',
                      ),
                      _buildDetailItem(
                        Icons.attach_money,
                        'KSh ${merchant.minimumOrder.toInt()}',
                        'Min order',
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Address
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 20,
                        color: AppTheme.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          merchant.address ?? 'Kericho, Kenya',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Search Bar
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search menu items...',
                        prefixIcon: const Icon(Icons.search),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                      onChanged: (value) {
                        // TODO: Implement search within merchant
                      },
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Category Filter
                  SizedBox(
                    height: 40,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: categories.map((category) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(category),
                            selected: _selectedCategory == category,
                            onSelected: (selected) {
                              setState(() {
                                _selectedCategory = category;
                              });
                            },
                            selectedColor: AppTheme.primaryColor,
                            labelStyle: GoogleFonts.poppins(
                              color: _selectedCategory == category
                                  ? Colors.white
                                  : AppTheme.textPrimary,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Products Grid
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: filteredProducts.isEmpty
                ? SliverToBoxAdapter(
                    child: Container(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(
                            Icons.fastfood_outlined,
                            size: 80,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No items found',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Try a different category',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.8,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final product = filteredProducts[index];
                        return _buildProductCard(product);
                      },
                      childCount: filteredProducts.length,
                    ),
                  ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),

      // Floating Action Button for Cart
      floatingActionButton: appProvider.cartItemCount > 0
          ? FloatingActionButton.extended(
              onPressed: _navigateToCart,
              backgroundColor: AppTheme.primaryColor,
              label: Row(
                children: [
                  Text(
                    '${appProvider.cartItemCount} items',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'KSh ${appProvider.cartTotal.toStringAsFixed(2)}',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              icon: const Icon(Icons.shopping_cart, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildDetailItem(IconData icon, String value, String label) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 20, color: AppTheme.primaryColor),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildProductCard(ProductModel product) {
    return GestureDetector(
      onTap: () {
        _showProductDetails(product);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              child: Container(
                height: 120,
                width: double.infinity,
                color: Colors.grey[200],
                child: product.imageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: product.imageUrl!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const Center(
                          child: CircularProgressIndicator(),
                        ),
                        errorWidget: (context, url, error) => const Icon(
                          Icons.fastfood,
                          size: 40,
                          color: Colors.grey,
                        ),
                      )
                    : const Icon(
                        Icons.fastfood,
                        size: 40,
                        color: Colors.grey,
                      ),
              ),
            ),

            // Product Details
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 4),

                  Text(
                    product.description,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 8),

                  // Price and Add Button
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'KSh ${product.price.toStringAsFixed(2)}',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ),
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.add,
                            size: 16,
                            color: Colors.white,
                          ),
                          onPressed: () => _addToCart(product),
                          padding: EdgeInsets.zero,
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
                content: Text('${product.name} added to cart'),
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
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Center(
              child: Container(
                width: 200,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: widget.product.imageUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CachedNetworkImage(
                          imageUrl: widget.product.imageUrl!,
                          fit: BoxFit.cover,
                        ),
                      )
                    : const Icon(
                        Icons.fastfood,
                        size: 60,
                        color: Colors.grey,
                      ),
              ),
            ),

            const SizedBox(height: 16),

            // Product Name
            Text(
              widget.product.name,
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 8),

            // Description
            Text(
              widget.product.description,
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),

            const SizedBox(height: 16),

            // Price
            Text(
              'KSh ${widget.product.price.toStringAsFixed(2)}',
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: AppTheme.primaryColor,
              ),
            ),

            const SizedBox(height: 24),

            // Options
            if (widget.product.options != null && widget.product.options!.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Options',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
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
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...widget.product.addons!.map((addon) {
                    return CheckboxListTile(
                      title: Text(addon),
                      value: _selectedOptions['addons']?.contains(addon) ?? false,
                      onChanged: (value) {
                        setState(() {
                          if (value == true) {
                            _selectedOptions['addons'] = [
                              ..._selectedOptions['addons'] ?? [],
                              addon,
                            ];
                          } else {
                            _selectedOptions['addons']?.remove(addon);
                          }
                        });
                      },
                    );
                  }).toList(),
                  const SizedBox(height: 16),
                ],
              ),

            // Special Instructions
            TextField(
              onChanged: (value) => _specialInstructions = value,
              decoration: InputDecoration(
                labelText: 'Special Instructions',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              maxLines: 3,
            ),

            const SizedBox(height: 24),

            // Quantity and Add Button
            Row(
              children: [
                // Quantity Selector
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
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
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          setState(() => _quantity++);
                        },
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Add to Cart Button
                Expanded(
                  flex: 2,
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
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.add_shopping_cart),
                        const SizedBox(width: 8),
                        Text(
                          'Add to Cart',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionSection(ProductOption option) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          option.name,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        
        if (option.isMultiple)
          // Multiple selection
          Wrap(
            spacing: 8,
            children: option.choices.map((choice) {
              final isSelected = _selectedOptions[option.name]?.contains(choice) ?? false;
              return ChoiceChip(
                label: Text(choice),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedOptions[option.name] = [
                        ..._selectedOptions[option.name] ?? [],
                        choice,
                      ];
                    } else {
                      _selectedOptions[option.name]?.remove(choice);
                    }
                  });
                },
              );
            }).toList(),
          )
        else
          // Single selection
          Wrap(
            spacing: 8,
            children: option.choices.map((choice) {
              final isSelected = _selectedOptions[option.name]?.contains(choice) ?? false;
              return ChoiceChip(
                label: Text(choice),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedOptions[option.name] = [choice];
                    } else {
                      _selectedOptions[option.name]?.remove(choice);
                    }
                  });
                },
              );
            }).toList(),
          ),
        
        const SizedBox(height: 16),
      ],
    );
  }
}