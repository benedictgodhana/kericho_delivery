import 'package:flutter/material.dart';
import 'package:kericho_delivery/data/models/cart_model.dart';
import 'package:kericho_delivery/data/models/order_model.dart';
import 'package:provider/provider.dart';
import 'package:kericho_delivery/presentation/providers/app_provider.dart';
import 'package:kericho_delivery/presentation/providers/location_provider.dart';
import 'package:kericho_delivery/presentation/providers/order_provider.dart';
import 'package:kericho_delivery/presentation/router/app_router.dart';
import 'package:kericho_delivery/core/theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final TextEditingController _deliveryAddressController = TextEditingController();
  final TextEditingController _specialInstructionsController = TextEditingController();
  PaymentMethod _selectedPaymentMethod = PaymentMethod.mpesa;
  bool _isCheckingOut = false;

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDeliveryAddress();
    });
  }

  void _loadDeliveryAddress() {
    final locationProvider = Provider.of<LocationProvider>(context, listen: false);
    if (locationProvider.currentLocation != null) {
      _deliveryAddressController.text = locationProvider.currentLocation!.address;
    }
  }

  void _updateDeliveryAddress() async {
    final locationProvider = Provider.of<LocationProvider>(context, listen: false);
    await locationProvider.getCurrentLocation();
    if (locationProvider.currentLocation != null) {
      _deliveryAddressController.text = locationProvider.currentLocation!.address;
    }
  }

  void _updateQuantity(String productId, int quantity) {
    Provider.of<AppProvider>(context, listen: false)
      .updateCartItem(productId, quantity);
  }

  void _removeItem(String productId) {
    HapticFeedback.lightImpact();
    Provider.of<AppProvider>(context, listen: false)
      .removeFromCart(productId);
  }

  void _clearCart() {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Clear Cart',
            style: GoogleFonts.afacad(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: kTextPrimary,
            ),
          ),
          content: Text(
            'Are you sure you want to clear your cart?',
            style: GoogleFonts.afacad(
              fontSize: 15,
              color: kTextSecondary,
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          actions: [
            TextButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                Navigator.pop(context);
              },
              child: Text(
                'Cancel',
                style: GoogleFonts.afacad(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: kTextSecondary,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                HapticFeedback.mediumImpact();
                Provider.of<AppProvider>(context, listen: false).clearCart();
                Navigator.pop(context);
              },
              child: Text(
                'Clear',
                style: GoogleFonts.afacad(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: kErrorColor,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _proceedToCheckout() async {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    final locationProvider = Provider.of<LocationProvider>(context, listen: false);

    if (appProvider.cart.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(CupertinoIcons.cart, color: Colors.grey.shade100),
              const SizedBox(width: 12),
              Text(
                'Your cart is empty',
                style: GoogleFonts.afacad(color: Colors.white),
              ),
            ],
          ),
          backgroundColor: kWarningColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    if (_deliveryAddressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(CupertinoIcons.exclamationmark_circle, color: Colors.grey.shade100),
              const SizedBox(width: 12),
              Text(
                'Please enter a delivery address',
                style: GoogleFonts.afacad(color: Colors.white),
              ),
            ],
          ),
          backgroundColor: kErrorColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    if (locationProvider.currentLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(CupertinoIcons.location_slash, color: Colors.grey.shade100),
              const SizedBox(width: 12),
              Text(
                'Please enable location services',
                style: GoogleFonts.afacad(color: Colors.white),
              ),
            ],
          ),
          backgroundColor: kErrorColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    setState(() => _isCheckingOut = true);
    HapticFeedback.mediumImpact();

    try {
      // Group items by merchant
      final merchantGroups = <String, List<CartItem>>{};
      for (final item in appProvider.cart.items) {
        merchantGroups.putIfAbsent(
          item.product.merchantId,
          () => [],
        ).add(item);
      }

      // For now, create order for first merchant only
      final firstMerchantId = merchantGroups.keys.first;
      final merchantItems = merchantGroups[firstMerchantId]!;

      final subtotal = merchantItems.fold(
        0.0,
        (sum, item) => sum + ((item.product?.price ?? 0.0) * (item.quantity ?? 0)),
      );

      // For demo, use fixed delivery fee
      final deliveryFee = 50.0;

      final order = await orderProvider.createOrder(
        merchantId: firstMerchantId,
        items: merchantItems,
        subtotal: subtotal,
        deliveryFee: deliveryFee,
        deliveryAddress: _deliveryAddressController.text,
        deliveryLocation: locationProvider.currentLocation!,
        paymentMethod: _selectedPaymentMethod,
        specialInstructions: _specialInstructionsController.text.isNotEmpty
            ? _specialInstructionsController.text
            : null,
      );

      if (order != null) {
        // Clear cart for the ordered items
        for (final item in merchantItems) {
          appProvider.removeFromCart(item.product.id);
        }

        // Navigate to order tracking
        AppRouter.pushNamedAndRemoveUntil(
          AppRouter.orderTracking,
          arguments: {'orderId': order.id},
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(CupertinoIcons.xmark_circle, color: Colors.grey.shade100),
              const SizedBox(width: 12),
              Text(
                'Checkout failed. Please try again.',
                style: GoogleFonts.afacad(color: Colors.white),
              ),
            ],
          ),
          backgroundColor: kErrorColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
    } finally {
      setState(() => _isCheckingOut = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final cart = appProvider.cart;

    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: cart.items.isEmpty
          ? _buildEmptyCart()
          : Stack(
              children: [
                Column(
                  children: [
                    SizedBox(height: 240),
                    Expanded(
                      child: CustomScrollView(
                        physics: const BouncingScrollPhysics(),
                        slivers: [
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Cart Items Count
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Your Items',
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
                                              '${cart.items.length} items',
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
                                  const SizedBox(height: 16),
                                ],
                              ),
                            ),
                          ),
                          // Cart Items List
                          SliverPadding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  final item = cart.items[index];
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: _buildCartItem(item),
                                  );
                                },
                                childCount: cart.items.length,
                              ),
                            ),
                          ),
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                children: [
                                  // Delivery Address
                                  _buildAddressSection(),
                                  const SizedBox(height: 20),
                                  // Special Instructions
                                  _buildSpecialInstructions(),
                                  const SizedBox(height: 20),
                                  // Payment Method
                                  _buildPaymentMethod(),
                                  const SizedBox(height: 20),
                                  // Order Summary
                                  _buildOrderSummary(appProvider),
                                  const SizedBox(height: 20),
                                  // Checkout Button
                                  _buildCheckoutButton(appProvider),
                                  const SizedBox(height: 40),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                _buildCurvedHeader(cart),
              ],
            ),
    );
  }

  Widget _buildCurvedHeader(CartModel cart) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: ClipPath(
        clipper: CartHeaderCurveClipper(),
        child: Container(
          height: 280,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [kPrimaryDark, const Color(0xFF1E293B)],
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  // Back Button and Clear Cart
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          Navigator.pop(context);
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: kOverlayWhite,
                          ),
                          child: Icon(
                            CupertinoIcons.arrow_left,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ),
                      if (cart.items.isNotEmpty)
                        GestureDetector(
                          onTap: _clearCart,
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: kOverlayWhite,
                            ),
                            child: Icon(
                              CupertinoIcons.trash,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                        ),
                    ],
                  ),
                  
                  const SizedBox(height: 40),
                  // Cart Info
                  Row(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [kPrimaryColor, kSuccessColor],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: kPrimaryColor.withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(
                            CupertinoIcons.cart_fill,
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'My Cart',
                              style: GoogleFonts.afacad(
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${cart.items.length} ${cart.items.length == 1 ? 'item' : 'items'}',
                              style: GoogleFonts.afacad(
                                fontSize: 18,
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'KSh ${Provider.of<AppProvider>(context).cartSubtotal.toStringAsFixed(2)}',
                              style: GoogleFonts.afacad(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
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
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Container(
      color: kBackgroundColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [kPrimaryColor, kSuccessColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: kPrimaryColor.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Icon(
                CupertinoIcons.cart,
                size: 70,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Your cart is empty',
            style: GoogleFonts.afacad(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: kTextPrimary,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Add items from restaurants or stores',
            style: GoogleFonts.afacad(
              fontSize: 16,
              color: kTextSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: ElevatedButton(
              onPressed: () {
                HapticFeedback.mediumImpact();
                AppRouter.pushNamedAndRemoveUntil(AppRouter.home);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
                shadowColor: kPrimaryColor.withOpacity(0.3),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(CupertinoIcons.bag, size: 20),
                  const SizedBox(width: 12),
                  Text(
                    'Start Shopping',
                    style: GoogleFonts.afacad(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(CartItem item) {
    return Container(
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kBorderColor.withOpacity(0.5), width: 1),
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
          // Product Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: kBorderColor, width: 1),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: item.product.imageUrl != null
                        ? CachedNetworkImage(
                            imageUrl: item.product.imageUrl!,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Center(
                              child: Icon(
                                CupertinoIcons.cube_box_fill,
                                size: 30,
                                color: Colors.grey[300],
                              ),
                            ),
                            errorWidget: (context, url, error) => Center(
                              child: Icon(
                                CupertinoIcons.cube_box_fill,
                                size: 30,
                                color: Colors.grey[300],
                              ),
                            ),
                          )
                        : Center(
                            child: Icon(
                              CupertinoIcons.cube_box_fill,
                              size: 30,
                              color: Colors.grey[300],
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 16),
                // Product Details
                Expanded(
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
                                  item.product.name,
                                  style: GoogleFonts.afacad(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w800,
                                    color: kTextPrimary,
                                    height: 1.2,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  item.product.description,
                                  style: GoogleFonts.afacad(
                                    fontSize: 13.5,
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
                              'KSh ${item.product.price.toStringAsFixed(0)}',
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
                      // Options and Instructions
                      if (item.selectedOptions != null && item.selectedOptions!.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: kPrimaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                CupertinoIcons.checkmark_seal_fill,
                                size: 14,
                                color: kPrimaryColor,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  item.selectedOptions!.join(', '),
                                  style: GoogleFonts.afacad(
                                    fontSize: 12,
                                    color: kPrimaryColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (item.specialInstructions != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: kWarningColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  CupertinoIcons.text_bubble_fill,
                                  size: 14,
                                  color: kWarningColor,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    '"${item.specialInstructions!}"',
                                    style: GoogleFonts.afacad(
                                      fontSize: 12,
                                      color: kWarningColor,
                                      fontWeight: FontWeight.w600,
                                      fontStyle: FontStyle.italic,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
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
          ),
          // Quantity Controls and Total
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: kBackgroundColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              border: Border(
                top: BorderSide(color: kBorderColor, width: 1),
              ),
            ),
            child: Row(
              children: [
                // Quantity Controls
                Container(
                  decoration: BoxDecoration(
                    color: kCardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: kBorderColor, width: 1),
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => _updateQuantity(item.product.id, item.quantity - 1),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(12),
                              bottomLeft: Radius.circular(12),
                            ),
                            color: item.quantity > 1 ? kPrimaryColor : Colors.grey[200],
                          ),
                          child: Icon(
                            CupertinoIcons.minus,
                            size: 18,
                            color: item.quantity > 1 ? Colors.white : Colors.grey[400],
                          ),
                        ),
                      ),
                      Container(
                        width: 40,
                        height: 36,
                        color: kCardColor,
                        child: Center(
                          child: Text(
                            item.quantity.toString(),
                            style: GoogleFonts.afacad(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: kTextPrimary,
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _updateQuantity(item.product.id, item.quantity + 1),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(12),
                              bottomRight: Radius.circular(12),
                            ),
                            color: kPrimaryColor,
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
                ),
                const Spacer(),
                // Total Price
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Total',
                      style: GoogleFonts.afacad(
                        fontSize: 14,
                        color: kTextSecondary,
                      ),
                    ),
                    Text(
                      'KSh ${(item.product.price * item.quantity).toStringAsFixed(2)}',
                      style: GoogleFonts.afacad(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: kPrimaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                // Remove Button
                GestureDetector(
                  onTap: () => _removeItem(item.product.id),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: kErrorColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      CupertinoIcons.trash,
                      size: 18,
                      color: kErrorColor,
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

  Widget _buildAddressSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              CupertinoIcons.location_fill,
              color: kPrimaryColor,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Delivery Address',
              style: GoogleFonts.afacad(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: kTextPrimary,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
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
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _deliveryAddressController.text.isNotEmpty
                            ? _deliveryAddressController.text
                            : 'Enter your delivery address',
                        style: GoogleFonts.afacad(
                          fontSize: 15,
                          color: _deliveryAddressController.text.isNotEmpty
                              ? kTextPrimary
                              : kTextSecondary,
                          fontWeight: _deliveryAddressController.text.isNotEmpty
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (_deliveryAddressController.text.isEmpty)
                        const SizedBox(height: 4),
                      if (_deliveryAddressController.text.isEmpty)
                        Text(
                          'Tap the location button to use current location',
                          style: GoogleFonts.afacad(
                            fontSize: 12,
                            color: kTextSecondary,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: _updateDeliveryAddress,
                  child: Container(
                    padding: const EdgeInsets.all(12),
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
                      CupertinoIcons.location_fill,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSpecialInstructions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              CupertinoIcons.text_bubble_fill,
              color: kWarningColor,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Special Instructions',
              style: GoogleFonts.afacad(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: kTextPrimary,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '(Optional)',
              style: GoogleFonts.afacad(
                fontSize: 14,
                color: kTextSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
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
          child: TextField(
            controller: _specialInstructionsController,
            style: GoogleFonts.afacad(fontSize: 15),
            decoration: const InputDecoration(
              hintText: 'e.g., Leave at door, Call on arrival...',
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16),
            ),
            maxLines: 3,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethod() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              CupertinoIcons.creditcard_fill,
              color: kInfoColor,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Payment Method',
              style: GoogleFonts.afacad(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: kTextPrimary,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedPaymentMethod = PaymentMethod.mpesa;
                  });
                  HapticFeedback.lightImpact();
                },
                child: Container(
                  height: 70,
                  decoration: BoxDecoration(
                    color: _selectedPaymentMethod == PaymentMethod.mpesa
                        ? kPrimaryColor
                        : kCardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _selectedPaymentMethod == PaymentMethod.mpesa
                          ? kPrimaryColor
                          : kBorderColor,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: _selectedPaymentMethod == PaymentMethod.mpesa
                              ? Colors.white
                              : Colors.green,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            'M',
                            style: GoogleFonts.afacad(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: _selectedPaymentMethod == PaymentMethod.mpesa
                                  ? Colors.green
                                  : Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'M-Pesa',
                        style: GoogleFonts.afacad(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: _selectedPaymentMethod == PaymentMethod.mpesa
                              ? Colors.white
                              : kTextPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedPaymentMethod = PaymentMethod.cash;
                  });
                  HapticFeedback.lightImpact();
                },
                child: Container(
                  height: 70,
                  decoration: BoxDecoration(
                    color: _selectedPaymentMethod == PaymentMethod.cash
                        ? kPrimaryColor
                        : kCardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _selectedPaymentMethod == PaymentMethod.cash
                          ? kPrimaryColor
                          : kBorderColor,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        CupertinoIcons.money_dollar,
                        color: _selectedPaymentMethod == PaymentMethod.cash
                            ? Colors.white
                            : kWarningColor,
                        size: 28,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Cash',
                        style: GoogleFonts.afacad(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: _selectedPaymentMethod == PaymentMethod.cash
                              ? Colors.white
                              : kTextPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOrderSummary(AppProvider appProvider) {
    final cart = appProvider.cart;
    final deliveryFee = 50.0; // Fixed for demo
    final total = appProvider.cartSubtotal + deliveryFee - (cart.discountAmount ?? 0);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kBorderColor.withOpacity(0.5), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                CupertinoIcons.doc_text,
                color: kPrimaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Order Summary',
                style: GoogleFonts.afacad(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: kTextPrimary,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildSummaryRow('Subtotal', appProvider.cartSubtotal),
          _buildSummaryRow('Delivery Fee', deliveryFee),
          if (cart.discountAmount != null && cart.discountAmount! > 0)
            _buildSummaryRow('Discount', -cart.discountAmount!),
          const SizedBox(height: 12),
          Container(
            height: 1,
            color: kBorderColor,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                'Total Amount',
                style: GoogleFonts.afacad(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: kTextPrimary,
                ),
              ),
              const Spacer(),
              Text(
                'KSh ${total.toStringAsFixed(2)}',
                style: GoogleFonts.afacad(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: kPrimaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Text(
            label,
            style: GoogleFonts.afacad(
              fontSize: 15,
              color: kTextSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Text(
            'KSh ${amount.toStringAsFixed(2)}',
            style: GoogleFonts.afacad(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: kTextPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckoutButton(AppProvider appProvider) {
    final cart = appProvider.cart;
    final deliveryFee = 50.0;
    final total = appProvider.cartSubtotal + deliveryFee - (cart.discountAmount ?? 0);

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isCheckingOut ? null : _proceedToCheckout,
        style: ElevatedButton.styleFrom(
          backgroundColor: kPrimaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
          shadowColor: kPrimaryColor.withOpacity(0.3),
        ),
        child: _isCheckingOut
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(CupertinoIcons.lock_fill, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Proceed to Checkout',
                          style: GoogleFonts.afacad(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          'KSh ${total.toStringAsFixed(2)}',
                          style: GoogleFonts.afacad(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    CupertinoIcons.arrow_right,
                    size: 20,
                  ),
                ],
              ),
      ),
    );
  }
}

class CartHeaderCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 40);

    final firstControlPoint = Offset(size.width * 0.25, size.height);
    final firstEndPoint = Offset(size.width * 0.5, size.height - 20);
    path.quadraticBezierTo(
      firstControlPoint.dx,
      firstControlPoint.dy,
      firstEndPoint.dx,
      firstEndPoint.dy,
    );

    final secondControlPoint = Offset(size.width * 0.75, size.height - 60);
    final secondEndPoint = Offset(size.width, size.height - 40);
    path.quadraticBezierTo(
      secondControlPoint.dx,
      secondControlPoint.dy,
      secondEndPoint.dx,
      secondEndPoint.dy,
    );

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}