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
  // KulaHub brand palette (matches home/menu/merchant screens)
  static const Color kPrimaryColor = Color(0xFFFF5A36);
  static const Color kBackgroundColor = Color(0xFFFFF8F1);
  static const Color kCardColor = Colors.white;
  static const Color kTextPrimary = Color(0xFF16181D);
  static const Color kTextSecondary = Color(0xFF6C757D);
  static const Color kBorderColor = Color(0xFFF0E4D8);
  static const Color kErrorColor = Color(0xFFE5484D);

  // Refined accents
  static const Color kInk = Color(0xFF1B1816);
  static const Color kHairline = Color(0xFFE9DCCB);

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
          surfaceTintColor: Colors.transparent,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
          contentPadding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
          title: Text('Clear your cart?',
              style: GoogleFonts.afacad(
                  fontSize: 21, fontWeight: FontWeight.w700, color: kInk)),
          content: Text(
            'All items will be removed. This can\'t be undone.',
            style: GoogleFonts.afacad(
                fontSize: 14.5, color: kTextSecondary, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Keep items',
                  style: GoogleFonts.afacad(
                      fontWeight: FontWeight.w700, color: kTextSecondary)),
            ),
            TextButton(
              onPressed: () {
                Provider.of<AppProvider>(context, listen: false).clearCart();
                Navigator.pop(context);
              },
              child: Text('Clear cart',
                  style: GoogleFonts.afacad(
                      fontWeight: FontWeight.w700, color: kErrorColor)),
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

  void _proceedToCheckout() async {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final merchantProvider =
        Provider.of<MerchantProvider>(context, listen: false);

    if (appProvider.cart.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your cart is empty')),
      );
      return;
    }

    if (appProvider.user == null) {
      final authenticated = await AppRouter.pushNamed(AppRouter.authPrompt);
      if (authenticated != true || !mounted) return;
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
        bottom: false,
        child: Column(
          children: [
            _buildHeader(cart.items.isNotEmpty, appProvider.cartItemCount),
            Expanded(
              child: cart.items.isEmpty
                  ? _buildEmptyCart()
                  : _buildCartWithItems(),
            ),
          ],
        ),
      ),
    );
  }

  // ───────────────────────── HEADER ─────────────────────────

  Widget _buildHeader(bool hasItems, int itemCount) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).maybePop(),
            child: Container(
              width: 42,
              height: 42,
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
              child: const Icon(CupertinoIcons.back, color: kInk, size: 19),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My Cart',
                  style: GoogleFonts.afacad(
                    fontSize: 27,
                    fontWeight: FontWeight.w700,
                    color: kInk,
                    letterSpacing: -0.4,
                    height: 1.1,
                  ),
                ),
                if (hasItems)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      '$itemCount ${itemCount == 1 ? 'item' : 'items'}',
                      style: GoogleFonts.afacad(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                          color: kTextSecondary),
                    ),
                  ),
              ],
            ),
          ),
          if (hasItems)
            GestureDetector(
              onTap: _clearCart,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: kHairline, width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(CupertinoIcons.trash,
                        color: kTextSecondary, size: 15),
                    const SizedBox(width: 6),
                    Text(
                      'Clear',
                      style: GoogleFonts.afacad(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: kTextSecondary),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ───────────────────────── EMPTY ─────────────────────────

  Widget _buildEmptyCart() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 116,
              height: 116,
              decoration: BoxDecoration(
                color: kCardColor,
                shape: BoxShape.circle,
                border: Border.all(color: kHairline, width: 1),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 24,
                      offset: const Offset(0, 10)),
                ],
              ),
              child: Icon(CupertinoIcons.bag,
                  size: 46, color: kPrimaryColor.withValues(alpha: 0.9)),
            ),
            const SizedBox(height: 28),
            Text(
              'Your cart is empty',
              style: GoogleFonts.afacad(
                  fontSize: 25, fontWeight: FontWeight.w700, color: kInk),
            ),
            const SizedBox(height: 12),
            Container(width: 36, height: 2, color: kPrimaryColor),
            const SizedBox(height: 14),
            Text(
              'Add items from restaurants or stores\nto get started.',
              style: GoogleFonts.afacad(
                  fontSize: 15, color: kTextSecondary, height: 1.45),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            GestureDetector(
              onTap: () => AppRouter.pushNamedAndRemoveUntil(AppRouter.home),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 34, vertical: 16),
                decoration: BoxDecoration(
                  color: kInk,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.22),
                        blurRadius: 18,
                        offset: const Offset(0, 8)),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Start Shopping',
                      style: GoogleFonts.afacad(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                          color: Colors.white),
                    ),
                    const SizedBox(width: 10),
                    const Icon(CupertinoIcons.arrow_right,
                        color: kPrimaryColor, size: 17),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ───────────────────────── ITEMS ─────────────────────────

  Widget _buildCartWithItems() {
    final appProvider = Provider.of<AppProvider>(context);
    final merchantProvider = Provider.of<MerchantProvider>(context);
    final cart = appProvider.cart;
    final merchantGroups = _groupByMerchant(cart.items);

    return Column(
      children: [
        Expanded(
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
            children: [
              if (merchantGroups.length > 1)
                Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: kPrimaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: kPrimaryColor.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(CupertinoIcons.info_circle,
                          color: kPrimaryColor, size: 17),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Checkout ships from one store at a time. Items from other '
                          'stores stay in your cart.',
                          style: GoogleFonts.afacad(
                              fontSize: 13, color: kTextPrimary, height: 1.35),
                        ),
                      ),
                    ],
                  ),
                ),
              for (final entry in merchantGroups.entries) ...[
                if (merchantGroups.length > 1)
                  _buildMerchantGroupHeader(merchantProvider, entry.key),
                for (var i = 0; i < entry.value.length; i++) ...[
                  _buildCartItem(entry.value[i]),
                  if (i < entry.value.length - 1)
                    const Divider(height: 1, thickness: 1, color: kHairline),
                ],
                const SizedBox(height: 18),
              ],
            ],
          ),
        ),
        _buildCheckoutSection(appProvider, merchantGroups.length),
      ],
    );
  }

  Widget _buildMerchantGroupHeader(
      MerchantProvider merchantProvider, String merchantId) {
    final merchant = merchantProvider.getMerchantById(merchantId);
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 6),
      child: Row(
        children: [
          Container(width: 3, height: 18, color: kPrimaryColor),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              merchant?.name ?? 'Store',
              style: GoogleFonts.afacad(
                  fontSize: 18, fontWeight: FontWeight.w700, color: kInk),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemImage(CartItem item) {
    Widget fallback() => Container(
          color: kBorderColor.withValues(alpha: 0.6),
          child: const Icon(CupertinoIcons.cube_box,
              color: kTextSecondary, size: 24),
        );

    final url = item.product.imageUrl;
    if (url == null) return fallback();
    if (url.startsWith('http')) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => fallback(),
      );
    }
    return Image.asset(url, fit: BoxFit.cover);
  }

  Widget _buildCartItem(CartItem item) {
    final subtitle =
        (item.selectedOptions != null && item.selectedOptions!.isNotEmpty)
            ? item.selectedOptions!.join(', ')
            : 'Regular';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 78,
            height: 78,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 5)),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: _buildItemImage(item),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  style: GoogleFonts.afacad(
                      fontSize: 16.5,
                      fontWeight: FontWeight.w700,
                      color: kInk,
                      height: 1.2),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.afacad(
                      fontSize: 13, color: kTextSecondary, height: 1.3),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (item.specialInstructions != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: Text(
                      '"${item.specialInstructions!}"',
                      style: GoogleFonts.afacad(
                          fontSize: 12.5,
                          fontStyle: FontStyle.italic,
                          color: kTextSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildQuantityPill(item),
                    const Spacer(),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => _removeItem(item.product.id),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 4),
                        child: Text(
                          'Remove',
                          style: GoogleFonts.afacad(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.3,
                              color: kTextSecondary,
                              decoration: TextDecoration.underline,
                              decorationColor:
                                  kTextSecondary.withValues(alpha: 0.5)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
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
                    color: kPrimaryColor),
              ),
              Text(
                (item.product.price * item.quantity).toStringAsFixed(0),
                style: GoogleFonts.afacad(
                    fontSize: 16, fontWeight: FontWeight.w700, color: kInk),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityPill(CartItem item) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kHairline, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildStepperButton(
            icon: CupertinoIcons.minus,
            onTap: () => _updateQuantity(item.product.id, item.quantity - 1),
          ),
          SizedBox(
            width: 30,
            child: Text(
              '${item.quantity}',
              textAlign: TextAlign.center,
              style: GoogleFonts.afacad(
                  fontWeight: FontWeight.w700, color: kInk, fontSize: 15),
            ),
          ),
          _buildStepperButton(
            icon: CupertinoIcons.add,
            filled: true,
            onTap: () => _updateQuantity(item.product.id, item.quantity + 1),
          ),
        ],
      ),
    );
  }

  Widget _buildStepperButton({
    required IconData icon,
    required VoidCallback onTap,
    bool filled = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: filled ? kInk : kBackgroundColor,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 13, color: filled ? Colors.white : kInk),
      ),
    );
  }

  // ───────────────────────── CHECKOUT ─────────────────────────

  Widget _buildCheckoutSection(AppProvider appProvider, int merchantCount) {
    final cart = appProvider.cart;
    final total = appProvider.cartSubtotal - (cart.discountAmount ?? 0);
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(24, 14, 24, 20 + bottomPad),
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(36)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 24,
              offset: const Offset(0, -6)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 18),
            decoration: BoxDecoration(
              color: kHairline,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          _buildSummaryRow('Subtotal', appProvider.cartSubtotal),
          if (cart.discountAmount != null && cart.discountAmount! > 0)
            _buildSummaryRow('Discount', -cart.discountAmount!,
                accent: kPrimaryColor),
          Padding(
            padding: const EdgeInsets.only(top: 2, bottom: 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Delivery fee calculated at checkout',
                    style: GoogleFonts.afacad(
                        fontSize: 12.5,
                        fontStyle: FontStyle.italic,
                        color: kTextSecondary),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: kHairline),
          const SizedBox(height: 14),
          _buildSummaryRow('Total', total, isTotal: true),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _proceedToCheckout,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(26, 10, 10, 10),
              decoration: BoxDecoration(
                color: kInk,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 20,
                      offset: const Offset(0, 8)),
                ],
              ),
              child: Row(
                children: [
                  Text(
                    'Proceed to Checkout',
                    style: GoogleFonts.afacad(
                        fontSize: 16.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                        color: Colors.white),
                  ),
                  const Spacer(),
                  Container(
                    width: 42,
                    height: 42,
                    decoration: const BoxDecoration(
                        color: kPrimaryColor, shape: BoxShape.circle),
                    child: const Icon(CupertinoIcons.arrow_right,
                        color: kInk, size: 18),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount,
      {bool isTotal = false, Color? accent}) {
    final isNegative = amount < 0;
    final formatted =
        '${isNegative ? '- ' : ''}KSh ${amount.abs().toStringAsFixed(0)}';

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            isTotal ? label.toUpperCase() : label,
            style: GoogleFonts.afacad(
              fontSize: isTotal ? 13.5 : 15,
              fontWeight: isTotal ? FontWeight.w800 : FontWeight.w500,
              letterSpacing: isTotal ? 1.8 : 0.1,
              color: isTotal ? kInk : kTextSecondary,
            ),
          ),
          const Spacer(),
          Text(
            formatted,
            style: isTotal
                ? GoogleFonts.afacad(
                    fontSize: 24, fontWeight: FontWeight.w700, color: kInk)
                : GoogleFonts.afacad(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: accent ?? kTextPrimary),
          ),
        ],
      ),
    );
  }
}