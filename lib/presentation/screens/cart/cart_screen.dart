import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kericho_delivery/data/models/cart_model.dart';
import 'package:provider/provider.dart';
import 'package:kericho_delivery/presentation/providers/app_provider.dart';
import 'package:kericho_delivery/presentation/providers/merchant_provider.dart';
import 'package:kericho_delivery/presentation/router/app_router.dart';
import 'package:kericho_delivery/presentation/screens/checkout/checkout_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  // KulaHub brand palette (matches home/menu screens)
  static const Color kPrimaryColor = Color(0xFFFF5A36);
  static const Color kSecondaryColor = Color(0xFFFFB020);
  static const Color kBackgroundColor = Color(0xFFFFF8F1);
  static const Color kCardColor = Colors.white;
  static const Color kTextPrimary = Color(0xFF16181D);
  static const Color kTextSecondary = Color(0xFF6C757D);
  static const Color kBorderColor = Color(0xFFF0E4D8);
  static const Color kErrorColor = Color(0xFFE5484D);

  static const double _flatDeliveryFee = 50.0;

  void _updateQuantity(String productId, int quantity) {
    HapticFeedback.lightImpact();
    Provider.of<AppProvider>(context, listen: false)
        .updateCartItem(productId, quantity);
  }

  void _removeItem(String productId) {
    HapticFeedback.mediumImpact();
    Provider.of<AppProvider>(context, listen: false).removeFromCart(productId);
  }

  void _clearCart() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: kCardColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: Text('Clear Cart', style: GoogleFonts.afacad(fontWeight: FontWeight.w800, color: kTextPrimary)),
          content: Text(
            'Are you sure you want to clear your cart?',
            style: GoogleFonts.afacad(color: kTextSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: GoogleFonts.afacad(fontWeight: FontWeight.w700, color: kTextSecondary)),
            ),
            TextButton(
              onPressed: () {
                Provider.of<AppProvider>(context, listen: false).clearCart();
                Navigator.pop(context);
              },
              child: Text('Clear', style: GoogleFonts.afacad(fontWeight: FontWeight.w700, color: kErrorColor)),
            ),
          ],
        );
      },
    );
  }

  // Group cart items by restaurant. KulaHub ships one restaurant per order today;
  // items from other restaurants stay in the cart for a separate checkout.
  Map<String, List<CartItem>> _groupByMerchant(List<CartItem> items) {
    final groups = <String, List<CartItem>>{};
    for (final item in items) {
      groups.putIfAbsent(item.product.merchantId, () => []).add(item);
    }
    return groups;
  }

  void _proceedToCheckout() {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final merchantProvider = Provider.of<MerchantProvider>(context, listen: false);

    if (appProvider.cart.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your cart is empty')),
      );
      return;
    }

    final merchantGroups = _groupByMerchant(appProvider.cart.items);
    final firstMerchantId = merchantGroups.keys.first;
    final merchantItems = merchantGroups[firstMerchantId]!;
    final merchant = merchantProvider.getMerchantById(firstMerchantId);

    final subtotal = merchantItems.fold(
      0.0,
      (sum, item) => sum + (item.product.price * item.quantity),
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CheckoutScreen(
          merchantId: firstMerchantId,
          merchantName: merchant?.name ?? 'Restaurant',
          items: merchantItems,
          subtotal: subtotal,
          baseDeliveryFee: merchant?.deliveryFee ?? 50.0,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final cart = appProvider.cart;

    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(cart.items.isNotEmpty),
            Expanded(
              child: cart.items.isEmpty ? _buildEmptyCart() : _buildCartWithItems(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool hasItems) {
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
            'My Cart',
            style: GoogleFonts.afacad(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: kTextPrimary,
              letterSpacing: -0.3,
            ),
          ),
          const Spacer(),
          if (hasItems)
            GestureDetector(
              onTap: _clearCart,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: kCardColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: kBorderColor, width: 1.2),
                ),
                child: const Icon(CupertinoIcons.trash, color: kErrorColor, size: 18),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(color: kCardColor, shape: BoxShape.circle),
              child: Icon(CupertinoIcons.cart, size: 48, color: kTextSecondary.withValues(alpha: 0.5)),
            ),
            const SizedBox(height: 24),
            Text(
              'Your cart is empty',
              style: GoogleFonts.afacad(fontSize: 22, fontWeight: FontWeight.w800, color: kTextPrimary),
            ),
            const SizedBox(height: 10),
            Text(
              'Add items from restaurants or stores\nto get started',
              style: GoogleFonts.afacad(fontSize: 14.5, color: kTextSecondary, height: 1.4),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            GestureDetector(
              onTap: () => AppRouter.pushNamedAndRemoveUntil(AppRouter.home),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                decoration: BoxDecoration(
                  color: kPrimaryColor,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(color: kPrimaryColor.withValues(alpha: 0.3), blurRadius: 14, offset: const Offset(0, 6)),
                  ],
                ),
                child: Text(
                  'Start Shopping',
                  style: GoogleFonts.afacad(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartWithItems() {
    final appProvider = Provider.of<AppProvider>(context);
    final merchantProvider = Provider.of<MerchantProvider>(context);
    final cart = appProvider.cart;
    final merchantGroups = _groupByMerchant(cart.items);

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            children: [
              if (merchantGroups.length > 1)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: kSecondaryColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Icon(CupertinoIcons.info_circle_fill, color: kSecondaryColor, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Checkout ships from one store at a time. Items from other '
                          'stores stay in your cart.',
                          style: GoogleFonts.afacad(fontSize: 12.5, color: kTextPrimary, height: 1.3),
                        ),
                      ),
                    ],
                  ),
                ),
              for (final entry in merchantGroups.entries) ...[
                _buildMerchantGroupHeader(merchantProvider, entry.key),
                const SizedBox(height: 10),
                for (final item in entry.value)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildCartItem(item),
                  ),
                const SizedBox(height: 8),
              ],
            ],
          ),
        ),
        _buildCheckoutSection(appProvider, merchantGroups.length),
      ],
    );
  }

  Widget _buildMerchantGroupHeader(MerchantProvider merchantProvider, String merchantId) {
    final merchant = merchantProvider.getMerchantById(merchantId);
    return Row(
      children: [
        Icon(CupertinoIcons.bag_fill, size: 16, color: kPrimaryColor),
        const SizedBox(width: 8),
        Text(
          merchant?.name ?? 'Store',
          style: GoogleFonts.afacad(fontSize: 16, fontWeight: FontWeight.w800, color: kTextPrimary),
        ),
      ],
    );
  }

  Widget _buildCartItem(CartItem item) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorderColor, width: 1),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 72,
              height: 72,
              color: kBackgroundColor,
              child: item.product.imageUrl != null
                  ? (item.product.imageUrl!.startsWith('http')
                      ? Image.network(item.product.imageUrl!, fit: BoxFit.cover)
                      : Image.asset(item.product.imageUrl!, fit: BoxFit.cover))
                  : Icon(CupertinoIcons.cube_box, color: kTextSecondary),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  style: GoogleFonts.afacad(fontSize: 15, fontWeight: FontWeight.w700, color: kTextPrimary),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (item.selectedOptions != null && item.selectedOptions!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      item.selectedOptions!.join(', '),
                      style: GoogleFonts.afacad(fontSize: 12, color: kTextSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                if (item.specialInstructions != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '"${item.specialInstructions!}"',
                      style: GoogleFonts.afacad(fontSize: 12, fontStyle: FontStyle.italic, color: kTextSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                const SizedBox(height: 8),
                Text(
                  'KSh ${(item.product.price * item.quantity).toStringAsFixed(0)}',
                  style: GoogleFonts.afacad(fontSize: 15, fontWeight: FontWeight.w800, color: kPrimaryColor),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () => _removeItem(item.product.id),
                child: Icon(CupertinoIcons.xmark_circle_fill, size: 20, color: kTextSecondary.withValues(alpha: 0.5)),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: kBackgroundColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildStepperButton(
                      icon: CupertinoIcons.minus,
                      onTap: () => _updateQuantity(item.product.id, item.quantity - 1),
                    ),
                    SizedBox(
                      width: 26,
                      child: Text(
                        '${item.quantity}',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.afacad(fontWeight: FontWeight.w700, color: kTextPrimary, fontSize: 14),
                      ),
                    ),
                    _buildStepperButton(
                      icon: CupertinoIcons.add,
                      onTap: () => _updateQuantity(item.product.id, item.quantity + 1),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepperButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        alignment: Alignment.center,
        child: Icon(icon, size: 14, color: kPrimaryColor),
      ),
    );
  }

  Widget _buildCheckoutSection(AppProvider appProvider, int merchantCount) {
    final cart = appProvider.cart;
    final total = appProvider.cartSubtotal + _flatDeliveryFee - (cart.discountAmount ?? 0);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 16, offset: const Offset(0, -4)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: kBackgroundColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                _buildSummaryRow('Subtotal', appProvider.cartSubtotal),
                _buildSummaryRow('Delivery fee (est.)', _flatDeliveryFee),
                if (cart.discountAmount != null && cart.discountAmount! > 0)
                  _buildSummaryRow('Discount', -cart.discountAmount!),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Divider(height: 1, color: kBorderColor),
                ),
                _buildSummaryRow('Total (est.)', total, isTotal: true),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: GestureDetector(
              onTap: _proceedToCheckout,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 17),
                decoration: BoxDecoration(
                  color: kPrimaryColor,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(color: kPrimaryColor.withValues(alpha: 0.3), blurRadius: 14, offset: const Offset(0, 6)),
                  ],
                ),
                child: Center(
                  child: Text(
                    'Proceed to Checkout',
                    style: GoogleFonts.afacad(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            label,
            style: GoogleFonts.afacad(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
              color: isTotal ? kTextPrimary : kTextSecondary,
            ),
          ),
          const Spacer(),
          Text(
            'KSh ${amount.toStringAsFixed(0)}',
            style: GoogleFonts.afacad(
              fontSize: isTotal ? 18 : 14,
              fontWeight: isTotal ? FontWeight.w800 : FontWeight.w600,
              color: isTotal ? kPrimaryColor : kTextPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
