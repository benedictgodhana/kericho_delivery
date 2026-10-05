import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:kericho_delivery/data/models/cart_model.dart';
import 'package:kericho_delivery/data/models/merchant_model.dart';
import 'package:kericho_delivery/data/models/order_model.dart';
import 'package:kericho_delivery/presentation/providers/app_provider.dart';
import 'package:kericho_delivery/presentation/providers/location_provider.dart';
import 'package:kericho_delivery/presentation/providers/merchant_provider.dart';
import 'package:kericho_delivery/presentation/providers/order_provider.dart';
import 'package:kericho_delivery/presentation/router/app_router.dart';
import 'package:kericho_delivery/presentation/screens/merchant/merchant_screen.dart';
import 'package:kericho_delivery/presentation/screens/product/product_detail_screen.dart';

enum DeliveryMethod { delivery, pickup }

class CheckoutScreen extends StatefulWidget {
  final String merchantId;
  final String merchantName;
  final List<CartItem> items;
  final double subtotal;
  final double baseDeliveryFee;

  const CheckoutScreen({
    super.key,
    required this.merchantId,
    required this.merchantName,
    required this.items,
    required this.subtotal,
    required this.baseDeliveryFee,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  // KulaHub brand palette (matches home/cart/product screens)
  static const Color kPrimaryColor = Color(0xFFFF5A36);
  static const Color kBorderColor = Color(0xFFF0E4D8);
  static const Color kTextPrimary = Color(0xFF16181D);
  static const Color kTextSecondary = Color(0xFF6C757D);

  // Neutral surfaces
  static const Color kBackgroundColor = Color(0xFFFFF8F1);
  static const Color kCardColor = Colors.white;

  DeliveryMethod _deliveryMethod = DeliveryMethod.delivery;
  PaymentMethod _paymentMethod = PaymentMethod.mpesa;
  bool _ecoCutlery = true;
  double _tipPercent = 0.20;
  double? _customTipAmount;
  String? _appliedPromoCode;

  final _locationController = TextEditingController();
  final _buildingController = TextEditingController();
  final _apartmentController = TextEditingController();
  final _instructionsController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _promoController = TextEditingController();

  bool _isPlacingOrder = false;

  static const double _serviceFee = 30.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _prefill());
  }

  void _prefill() {
    final locationProvider = context.read<LocationProvider>();
    final user = context.read<AppProvider>().user;
    if (locationProvider.currentLocation != null) {
      _locationController.text = locationProvider.currentLocation!.address;
    }
    if (user != null) {
      _nameController.text = user.fullName;
      _phoneController.text = user.phone;
    }
  }

  @override
  void dispose() {
    _locationController.dispose();
    _buildingController.dispose();
    _apartmentController.dispose();
    _instructionsController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _promoController.dispose();
    super.dispose();
  }

  double get _deliveryFee =>
      _deliveryMethod == DeliveryMethod.pickup ? 0 : widget.baseDeliveryFee;

  List<CartItem> _liveItems(AppProvider appProvider) => appProvider.cart.items
      .where((item) => item.product.merchantId == widget.merchantId)
      .toList();

  double _liveSubtotal(List<CartItem> items) =>
      items.fold(0.0, (sum, item) => sum + item.product.price * item.quantity);

  double _tipAmount(double subtotal) =>
      _customTipAmount ?? (subtotal * _tipPercent);

  double _total(double subtotal) =>
      subtotal +
      _deliveryFee +
      _serviceFee +
      _tipAmount(subtotal) -
      (_appliedPromoCode != null ? subtotal * 0.1 : 0);

  void _selectTip(double percent) {
    HapticFeedback.lightImpact();
    setState(() {
      _tipPercent = percent;
      _customTipAmount = null;
    });
  }

  Future<void> _selectCustomTip() async {
    final controller = TextEditingController();
    final result = await showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: kCardColor,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
        contentPadding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
        title: Text('Custom tip',
            style: GoogleFonts.afacad(
                fontSize: 21,
                fontWeight: FontWeight.w800,
                color: kTextPrimary)),
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: kBackgroundColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: kBorderColor),
          ),
          child: TextField(
            controller: controller,
            autofocus: true,
            cursorColor: kPrimaryColor,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: GoogleFonts.afacad(
                fontSize: 16, fontWeight: FontWeight.w700, color: kTextPrimary),
            decoration: InputDecoration(
              prefixText: 'KSh  ',
              prefixStyle: GoogleFonts.afacad(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: kPrimaryColor),
              hintText: 'Amount',
              hintStyle:
                  GoogleFonts.afacad(fontSize: 15, color: kTextSecondary),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              filled: false,
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: GoogleFonts.afacad(
                    fontWeight: FontWeight.w700, color: kTextSecondary)),
          ),
          TextButton(
            onPressed: () =>
                Navigator.pop(context, double.tryParse(controller.text.trim())),
            child: Text('Save',
                style: GoogleFonts.afacad(
                    fontWeight: FontWeight.w800, color: kPrimaryColor)),
          ),
        ],
      ),
    );
    if (result != null && result >= 0) {
      setState(() {
        _customTipAmount = result;
        _tipPercent = 0;
      });
    }
  }

  void _applyPromoCode() {
    final code = _promoController.text.trim();
    if (code.isEmpty) return;
    HapticFeedback.lightImpact();
    FocusScope.of(context).unfocus();
    setState(() => _appliedPromoCode = code.toUpperCase());
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(CupertinoIcons.checkmark_alt_circle_fill,
                color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text('Promo "$_appliedPromoCode" applied — 10% off',
                  style: GoogleFonts.afacad(
                      color: Colors.white,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        backgroundColor: kPrimaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _placeOrder() async {
    if (_deliveryMethod == DeliveryMethod.delivery &&
        _locationController.text.trim().isEmpty) {
      _showError('Please enter your delivery location');
      return;
    }
    if (_nameController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty) {
      _showError('Please enter your name and phone number');
      return;
    }

    final appProvider = context.read<AppProvider>();
    if (appProvider.user == null) {
      final proceedAsGuest = await _promptSignInOrGuest();
      if (proceedAsGuest == null) return; // dialog dismissed
      if (!proceedAsGuest) {
        // Return the customer to checkout (this exact action) once authenticated.
        final authenticated = await AppRouter.pushNamed(AppRouter.login);
        if (authenticated == true && mounted) {
          await _placeOrder();
        }
        return;
      }
    }

    final locationProvider = context.read<LocationProvider>();
    if (locationProvider.currentLocation == null) {
      _showError('Please enable location services to continue');
      return;
    }

    setState(() => _isPlacingOrder = true);
    try {
      final orderProvider = context.read<OrderProvider>();
      final items = _liveItems(appProvider);
      final subtotal = _liveSubtotal(items);
      final addressParts = [
        _locationController.text.trim(),
        if (_buildingController.text.trim().isNotEmpty)
          _buildingController.text.trim(),
        if (_apartmentController.text.trim().isNotEmpty)
          _apartmentController.text.trim(),
      ];
      final deliveryAddress = _deliveryMethod == DeliveryMethod.pickup
          ? 'Pickup at ${widget.merchantName}'
          : addressParts.join(', ');

      final order = await orderProvider.createOrder(
        merchantId: widget.merchantId,
        items: items,
        subtotal: subtotal,
        deliveryFee: _deliveryFee + _serviceFee + _tipAmount(subtotal),
        deliveryAddress: deliveryAddress,
        deliveryLocation: locationProvider.currentLocation!,
        paymentMethod: _paymentMethod,
        specialInstructions: _instructionsController.text.trim().isNotEmpty
            ? _instructionsController.text.trim()
            : null,
        couponCode: _appliedPromoCode,
      );

      if (order == null) {
        _showError('Could not place order. Please try again.');
        return;
      }

      for (final item in items) {
        appProvider.removeFromCart(item.product.id);
      }

      if (!mounted) return;
      AppRouter.pushNamedAndRemoveUntil(
        AppRouter.orderTracking,
        arguments: {'orderId': order.id},
      );
    } finally {
      if (mounted) setState(() => _isPlacingOrder = false);
    }
  }

  Future<bool?> _promptSignInOrGuest() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: kCardColor,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
        contentPadding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
        title: Text('Sign in to continue?',
            style: GoogleFonts.afacad(
                fontSize: 21,
                fontWeight: FontWeight.w800,
                color: kTextPrimary)),
        content: Text(
          'Signing in lets you track this order from your profile and saves your details for next time. '
          'You can also continue as a guest.',
          style: GoogleFonts.afacad(
              fontSize: 14.5, color: kTextSecondary, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Sign In',
                style: GoogleFonts.afacad(
                    fontWeight: FontWeight.w700, color: kTextSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Continue as Guest',
                style: GoogleFonts.afacad(
                    fontWeight: FontWeight.w800, color: kPrimaryColor)),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(CupertinoIcons.exclamationmark_circle_fill,
                color: kPrimaryColor, size: 18),
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
        backgroundColor: kTextPrimary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<AppProvider>();
    final merchantProvider = context.watch<MerchantProvider>();
    final merchant = merchantProvider.getMerchantById(widget.merchantId);
    final items = _liveItems(appProvider);
    final subtotal = _liveSubtotal(items);
    final total = _total(subtotal);

    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                children: [
                  _buildDeliveryModeSwitch(merchant),
                  const SizedBox(height: 18),
                  if (_deliveryMethod == DeliveryMethod.delivery)
                    _buildAddressCard(merchant)
                  else
                    _buildPickupCard(),
                  const SizedBox(height: 18),
                  _buildOrderItemsCard(merchant, items),
                  const SizedBox(height: 18),
                  _buildContactCard(),
                  const SizedBox(height: 18),
                  _buildPreferencesCard(),
                  if (_deliveryMethod == DeliveryMethod.delivery) ...[
                    const SizedBox(height: 18),
                    _buildTipCard(subtotal),
                  ],
                  const SizedBox(height: 18),
                  _buildPromoCard(),
                  const SizedBox(height: 18),
                  _buildPaymentCard(),
                  const SizedBox(height: 18),
                  _buildBreakdownCard(subtotal, total),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      "By tapping Place Order, you agree to KulaHub's Terms of Service, Privacy Policy, "
                      'and merchant cancellation terms.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.afacad(
                          fontSize: 12, color: kTextSecondary, height: 1.45),
                    ),
                  ),
                ],
              ),
            ),
            _buildBottomBar(total),
          ],
        ),
      ),
    );
  }

  // ───────────────────────── HEADER ─────────────────────────

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).maybePop(),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: kCardColor,
                shape: BoxShape.circle,
                border: Border.all(color: kBorderColor, width: 1.2),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 3)),
                ],
              ),
              child: const Icon(CupertinoIcons.back,
                  color: kTextPrimary, size: 19),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Checkout',
                  style: GoogleFonts.afacad(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: kTextPrimary,
                    letterSpacing: -0.5,
                    height: 1.05,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'from ${widget.merchantName}',
                  style: GoogleFonts.afacad(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: kTextSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
            decoration: BoxDecoration(
              color: kPrimaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(CupertinoIcons.lock_fill,
                    size: 12, color: kPrimaryColor),
                const SizedBox(width: 5),
                Text('Secure',
                    style: GoogleFonts.afacad(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.3,
                        color: kPrimaryColor)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────── SHARED BUILDING BLOCKS ─────────────────────────

  Widget _card({required Widget child, EdgeInsetsGeometry? padding}) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: kBorderColor, width: 1),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 16,
              offset: const Offset(0, 6)),
        ],
      ),
      child: child,
    );
  }

  Widget _iconBadge(IconData icon, {double size = 38}) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: kPrimaryColor.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: size * 0.46, color: kPrimaryColor),
    );
  }

  Widget _sectionHeader(IconData icon, String title, {String? subtitle}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          _iconBadge(icon),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: GoogleFonts.afacad(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: kTextPrimary,
                        letterSpacing: -0.1)),
                if (subtitle != null)
                  Text(subtitle,
                      style: GoogleFonts.afacad(
                          fontSize: 12.5, color: kTextSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _field(TextEditingController controller, String label, IconData icon,
      {int maxLines = 1, TextInputType? keyboardType}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: kBackgroundColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kBorderColor, width: 1),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        cursorColor: kPrimaryColor,
        style: GoogleFonts.afacad(
            fontSize: 15, fontWeight: FontWeight.w600, color: kTextPrimary),
        decoration: InputDecoration(
          icon: Icon(icon, size: 18, color: kTextSecondary),
          hintText: label,
          hintStyle: GoogleFonts.afacad(
              fontSize: 15, fontWeight: FontWeight.w500, color: kTextSecondary),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          filled: false,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _hairline() => Divider(height: 1, thickness: 1, color: kBorderColor);

  // ───────────────────────── DELIVERY MODE ─────────────────────────

  Widget _buildDeliveryModeSwitch(MerchantModel? merchant) {
    final deliveryMinutes = merchant?.deliveryTime ?? 30;
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: kBorderColor, width: 1),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 14,
              offset: const Offset(0, 5)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _deliveryModeSegment(
              label: 'Delivery',
              sublabel: '$deliveryMinutes-${deliveryMinutes + 10} min',
              icon: CupertinoIcons.bus,
              selected: _deliveryMethod == DeliveryMethod.delivery,
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _deliveryMethod = DeliveryMethod.delivery);
              },
            ),
          ),
          Expanded(
            child: _deliveryModeSegment(
              label: 'Pickup',
              sublabel: '15 min',
              icon: CupertinoIcons.bag_fill,
              selected: _deliveryMethod == DeliveryMethod.pickup,
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _deliveryMethod = DeliveryMethod.pickup);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _deliveryModeSegment({
    required String label,
    required String sublabel,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? kPrimaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
          boxShadow: selected
              ? [
                  BoxShadow(
                      color: kPrimaryColor.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 5))
                ]
              : null,
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon,
                    size: 16, color: selected ? Colors.white : kTextSecondary),
                const SizedBox(width: 7),
                Text(label,
                    style: GoogleFonts.afacad(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: selected ? Colors.white : kTextPrimary)),
              ],
            ),
            const SizedBox(height: 1),
            Text(sublabel,
                style: GoogleFonts.afacad(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: selected
                        ? Colors.white.withValues(alpha: 0.85)
                        : kTextSecondary)),
          ],
        ),
      ),
    );
  }

  String _estimatedArrival(int minutesFromNow, int windowMinutes) {
    final now = DateTime.now();
    final start = now.add(Duration(minutes: minutesFromNow));
    final end = now.add(Duration(minutes: minutesFromNow + windowMinutes));
    final formatter = DateFormat('h:mm a');
    return '${formatter.format(start)} - ${formatter.format(end)}';
  }

  Widget _buildAddressCard(MerchantModel? merchant) {
    final deliveryMinutes = merchant?.deliveryTime ?? 30;
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(CupertinoIcons.location_solid, 'Delivery address',
              subtitle: 'Where should we bring your order?'),
          _field(
              _locationController, 'Location', CupertinoIcons.location_solid),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _field(_buildingController, 'Building',
                    CupertinoIcons.building_2_fill),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _field(_apartmentController, 'Apt / House no.',
                    CupertinoIcons.house),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _etaPill(_estimatedArrival(deliveryMinutes, 10)),
        ],
      ),
    );
  }

  Widget _buildPickupCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(CupertinoIcons.bag_fill, 'Pickup',
              subtitle: widget.merchantName),
          Text(
            "You'll collect this order yourself from ${widget.merchantName}.",
            style: GoogleFonts.afacad(
                fontSize: 14.5, color: kTextSecondary, height: 1.4),
          ),
          const SizedBox(height: 16),
          _etaPill(_estimatedArrival(15, 0), label: 'Ready for pickup'),
        ],
      ),
    );
  }

  Widget _etaPill(String time, {String label = 'Estimated arrival'}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      decoration: BoxDecoration(
        color: kPrimaryColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kPrimaryColor.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          const Icon(CupertinoIcons.time_solid, size: 17, color: kPrimaryColor),
          const SizedBox(width: 10),
          Text(label,
              style: GoogleFonts.afacad(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: kTextPrimary)),
          const Spacer(),
          Text(time,
              style: GoogleFonts.afacad(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: kPrimaryColor)),
        ],
      ),
    );
  }

  // ───────────────────────── ORDER ITEMS ─────────────────────────

  Widget _buildOrderItemsCard(MerchantModel? merchant, List<CartItem> items) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _iconBadge(CupertinoIcons.bag_fill),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.merchantName,
                        style: GoogleFonts.afacad(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: kTextPrimary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    Text(
                      '${items.length} ${items.length == 1 ? 'item' : 'items'} in your order',
                      style: GoogleFonts.afacad(
                          fontSize: 12.5, color: kTextSecondary),
                    ),
                  ],
                ),
              ),
              if (merchant != null && merchant.ratingCount > 0)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                  decoration: BoxDecoration(
                    color: kBackgroundColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: kBorderColor),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(CupertinoIcons.star_fill,
                          size: 12, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(merchant.rating.toStringAsFixed(1),
                          style: GoogleFonts.afacad(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: kTextPrimary)),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          _hairline(),
          for (var i = 0; i < items.length; i++) ...[
            _buildOrderLine(items[i]),
            if (i < items.length - 1) _hairline(),
          ],
          _hairline(),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => MerchantScreen(
                    merchantId: widget.merchantId,
                    merchantName: widget.merchantName,
                    merchantImageUrl: merchant?.imageUrl),
              ),
            ),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 13),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: kPrimaryColor.withValues(alpha: 0.4), width: 1.2),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(CupertinoIcons.add_circled,
                      size: 17, color: kPrimaryColor),
                  const SizedBox(width: 8),
                  Text('Add more items',
                      style: GoogleFonts.afacad(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.2,
                          color: kPrimaryColor)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderLine(CartItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4)),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: item.product.imageUrl != null
                  ? Image.asset(
                      item.product.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _imageFallback(),
                    )
                  : _imageFallback(),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(item.product.name,
                          style: GoogleFonts.afacad(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: kTextPrimary,
                              height: 1.2),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ),
                    const SizedBox(width: 8),
                    Text(
                        'KSh ${(item.product.price * item.quantity).toStringAsFixed(0)}',
                        style: GoogleFonts.afacad(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: kTextPrimary)),
                  ],
                ),
                const SizedBox(height: 3),
                Text(item.product.description,
                    style: GoogleFonts.afacad(
                        fontSize: 12.5, color: kTextSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: kCardColor,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: kBorderColor, width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildStepperButton(
                            icon: CupertinoIcons.minus,
                            onTap: item.quantity > 1
                                ? () => context
                                    .read<AppProvider>()
                                    .updateCartItem(
                                        item.product.id, item.quantity - 1)
                                : null,
                          ),
                          SizedBox(
                            width: 28,
                            child: Text('${item.quantity}',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.afacad(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w800,
                                    color: kTextPrimary)),
                          ),
                          _buildStepperButton(
                            icon: CupertinoIcons.add,
                            filled: true,
                            onTap: () => context
                                .read<AppProvider>()
                                .updateCartItem(
                                    item.product.id, item.quantity + 1),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) =>
                                ProductDetailScreen(product: item.product)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 4),
                        child: Text('Customize',
                            style: GoogleFonts.afacad(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.2,
                                color: kPrimaryColor)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _imageFallback() => Container(
        color: kBorderColor.withValues(alpha: 0.6),
        child: const Icon(CupertinoIcons.cube_box,
            color: kTextSecondary, size: 26),
      );

  Widget _buildStepperButton({
    required IconData icon,
    VoidCallback? onTap,
    bool filled = false,
  }) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap == null
          ? null
          : () {
              HapticFeedback.lightImpact();
              onTap();
            },
      child: Container(
        width: 28,
        height: 28,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: filled ? kPrimaryColor : kBackgroundColor,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 13,
          color: filled
              ? Colors.white
              : (enabled
                  ? kTextPrimary
                  : kTextSecondary.withValues(alpha: 0.4)),
        ),
      ),
    );
  }

  // ───────────────────────── CONTACT + PREFERENCES ─────────────────────────

  Widget _buildContactCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(CupertinoIcons.person_fill, 'Contact details',
              subtitle: 'So your rider can reach you'),
          _field(_nameController, 'Full name', CupertinoIcons.person),
          const SizedBox(height: 10),
          _field(_phoneController, 'Phone number', CupertinoIcons.phone,
              keyboardType: TextInputType.phone),
        ],
      ),
    );
  }

  Widget _buildPreferencesCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(CupertinoIcons.slider_horizontal_3, 'Preferences'),
          Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
            decoration: BoxDecoration(
              color: kBackgroundColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: kBorderColor),
            ),
            child: Row(
              children: [
                const Icon(CupertinoIcons.leaf_arrow_circlepath,
                    size: 20, color: kPrimaryColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Eco-friendly cutlery & napkins',
                          style: GoogleFonts.afacad(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w800,
                              color: kTextPrimary)),
                      Text('Keep the planet clean together',
                          style: GoogleFonts.afacad(
                              fontSize: 12, color: kTextSecondary)),
                    ],
                  ),
                ),
                CupertinoSwitch(
                  value: _ecoCutlery,
                  activeTrackColor: kPrimaryColor,
                  onChanged: (value) {
                    HapticFeedback.selectionClick();
                    setState(() => _ecoCutlery = value);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _field(_instructionsController, 'Additional instructions (optional)',
              CupertinoIcons.pencil,
              maxLines: 2),
        ],
      ),
    );
  }

  // ───────────────────────── TIP ─────────────────────────

  Widget _buildTipCard(double subtotal) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: kPrimaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Text('🚴', style: TextStyle(fontSize: 18)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Courier tip',
                        style: GoogleFonts.afacad(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: kTextPrimary)),
                    Text('100% goes directly to your rider',
                        style: GoogleFonts.afacad(
                            fontSize: 12.5, color: kTextSecondary)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                  child: _tipChip('15%', subtotal * 0.15, _tipPercent == 0.15,
                      () => _selectTip(0.15))),
              const SizedBox(width: 8),
              Expanded(
                  child: _tipChip('20%', subtotal * 0.20, _tipPercent == 0.20,
                      () => _selectTip(0.20))),
              const SizedBox(width: 8),
              Expanded(
                  child: _tipChip('25%', subtotal * 0.25, _tipPercent == 0.25,
                      () => _selectTip(0.25))),
              const SizedBox(width: 8),
              Expanded(
                child: _tipChip(
                  'Custom',
                  _customTipAmount,
                  _customTipAmount != null,
                  _selectCustomTip,
                  isCustom: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tipChip(
      String label, double? amount, bool selected, VoidCallback onTap,
      {bool isCustom = false}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? kPrimaryColor : kBackgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: selected ? kPrimaryColor : kBorderColor, width: 1),
          boxShadow: selected
              ? [
                  BoxShadow(
                      color: kPrimaryColor.withValues(alpha: 0.28),
                      blurRadius: 10,
                      offset: const Offset(0, 4))
                ]
              : null,
        ),
        child: Column(
          children: [
            Text(label,
                style: GoogleFonts.afacad(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: selected ? Colors.white : kTextPrimary)),
            const SizedBox(height: 2),
            Text(
              isCustom && amount == null
                  ? 'Other'
                  : 'KSh ${(amount ?? 0).toStringAsFixed(0)}',
              style: GoogleFonts.afacad(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: selected
                      ? Colors.white.withValues(alpha: 0.9)
                      : kTextSecondary),
            ),
          ],
        ),
      ),
    );
  }

  // ───────────────────────── PROMO ─────────────────────────

  Widget _buildPromoCard() {
    if (_appliedPromoCode != null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: kPrimaryColor.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: kPrimaryColor.withValues(alpha: 0.35)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                  color: kPrimaryColor, shape: BoxShape.circle),
              child: const Icon(CupertinoIcons.ticket_fill,
                  size: 18, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(_appliedPromoCode!,
                          style: GoogleFonts.afacad(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                              color: kTextPrimary)),
                      const SizedBox(width: 6),
                      const Icon(CupertinoIcons.checkmark_seal_fill,
                          size: 15, color: kPrimaryColor),
                    ],
                  ),
                  Text('10% discount applied',
                      style: GoogleFonts.afacad(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: kPrimaryColor)),
                ],
              ),
            ),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                HapticFeedback.lightImpact();
                setState(() {
                  _appliedPromoCode = null;
                  _promoController.clear();
                });
              },
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Text('Remove',
                    style: GoogleFonts.afacad(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: kTextSecondary)),
              ),
            ),
          ],
        ),
      );
    }

    return _card(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: kBackgroundColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: kBorderColor),
              ),
              child: Row(
                children: [
                  const Icon(CupertinoIcons.ticket,
                      size: 18, color: kTextSecondary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _promoController,
                      textCapitalization: TextCapitalization.characters,
                      cursorColor: kPrimaryColor,
                      textAlignVertical: TextAlignVertical.center,
                      style: GoogleFonts.afacad(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.6,
                          color: kTextPrimary),
                      decoration: InputDecoration(
                        isDense: true,
                        isCollapsed: true,
                        filled: false,
                        hintText: 'Promo code (optional)',
                        hintStyle: GoogleFonts.afacad(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0,
                            color: kTextSecondary),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: _applyPromoCode,
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 22),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: kPrimaryColor,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                      color: kPrimaryColor.withValues(alpha: 0.28),
                      blurRadius: 10,
                      offset: const Offset(0, 4)),
                ],
              ),
              child: Text('Apply',
                  style: GoogleFonts.afacad(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.3,
                      color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────── PAYMENT ─────────────────────────

  Widget _buildPaymentCard() {
    final methods = [
      (PaymentMethod.mpesa, 'M-PESA', 'Pay with mobile money',
          CupertinoIcons.phone_fill),
      (PaymentMethod.card, 'Card', 'Debit or credit card',
          CupertinoIcons.creditcard_fill),
      (PaymentMethod.wallet, 'KulaHub Wallet', 'Use your wallet balance',
          CupertinoIcons.money_dollar_circle_fill),
      (PaymentMethod.cash, 'Cash', 'Pay when you receive',
          CupertinoIcons.money_dollar),
    ];
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(CupertinoIcons.creditcard_fill, 'Payment method',
              subtitle: 'Choose how you\'d like to pay'),
          for (var i = 0; i < methods.length; i++) ...[
            _paymentTile(
                methods[i].$1, methods[i].$2, methods[i].$3, methods[i].$4),
            if (i < methods.length - 1) const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }

  Widget _paymentTile(
      PaymentMethod method, String label, String subtitle, IconData icon) {
    final selected = _paymentMethod == method;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _paymentMethod = method);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        decoration: BoxDecoration(
          color: selected
              ? kPrimaryColor.withValues(alpha: 0.06)
              : kBackgroundColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? kPrimaryColor : kBorderColor,
            width: selected ? 1.6 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                      color: kPrimaryColor.withValues(alpha: 0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 4)),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? kPrimaryColor : kCardColor,
                shape: BoxShape.circle,
                border: selected ? null : Border.all(color: kBorderColor),
              ),
              child: Icon(icon,
                  color: selected ? Colors.white : kPrimaryColor, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: GoogleFonts.afacad(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w800,
                          color: kTextPrimary)),
                  Text(subtitle,
                      style: GoogleFonts.afacad(
                          fontSize: 12.5, color: kTextSecondary)),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? kPrimaryColor : Colors.transparent,
                border: Border.all(
                    color: selected ? kPrimaryColor : kBorderColor, width: 1.6),
              ),
              child: selected
                  ? const Icon(CupertinoIcons.checkmark_alt,
                      size: 13, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  // ───────────────────────── BREAKDOWN ─────────────────────────

  Widget _buildBreakdownCard(double subtotal, double total) {
    final tip = _tipAmount(subtotal);
    final discount = _appliedPromoCode != null ? subtotal * 0.1 : 0.0;
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(CupertinoIcons.doc_text_fill, 'Order summary'),
          _summaryRow('Subtotal', subtotal),
          _summaryRow(
              _deliveryMethod == DeliveryMethod.pickup
                  ? 'Pickup'
                  : 'Delivery fee',
              _deliveryFee),
          _summaryRow('Service fee', _serviceFee),
          _summaryRow('Courier tip', tip),
          if (discount > 0)
            _summaryRow('Promo ($_appliedPromoCode)', -discount,
                highlight: true),
          const SizedBox(height: 6),
          _hairline(),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total amount',
                        style: GoogleFonts.afacad(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: kTextPrimary)),
                    Text('Includes all taxes & fees',
                        style: GoogleFonts.afacad(
                            fontSize: 12.5, color: kTextSecondary)),
                  ],
                ),
              ),
              Text('KSh ${total.toStringAsFixed(0)}',
                  style: GoogleFonts.afacad(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                      color: kPrimaryColor)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, double amount, {bool highlight = false}) {
    final isFree = amount == 0 && label.toLowerCase() == 'pickup';
    final isNegative = amount < 0;
    final text = isFree
        ? 'FREE'
        : '${isNegative ? '- ' : ''}KSh ${amount.abs().toStringAsFixed(0)}';
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Text(
            label,
            style: GoogleFonts.afacad(
                fontSize: 14.5,
                fontWeight: FontWeight.w500,
                color: highlight ? kPrimaryColor : kTextSecondary),
          ),
          const Spacer(),
          Text(
            text,
            style: GoogleFonts.afacad(
                fontSize: 14.5,
                fontWeight: FontWeight.w700,
                color: (highlight || isFree) ? kPrimaryColor : kTextPrimary),
          ),
        ],
      ),
    );
  }

  // ───────────────────────── BOTTOM BAR ─────────────────────────

  Widget _buildBottomBar(double total) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 24,
              offset: const Offset(0, -6)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: _isPlacingOrder ? null : _placeOrder,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 10, 10, 10),
                decoration: BoxDecoration(
                  color: kPrimaryColor,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                        color: kPrimaryColor.withValues(alpha: 0.35),
                        blurRadius: 18,
                        offset: const Offset(0, 8)),
                  ],
                ),
                child: _isPlacingOrder
                    ? const SizedBox(
                        height: 42,
                        child: Center(
                          child: SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                                strokeWidth: 2.5, color: Colors.white),
                          ),
                        ),
                      )
                    : Row(
                        children: [
                          const Icon(CupertinoIcons.lock_fill,
                              color: Colors.white, size: 16),
                          const SizedBox(width: 10),
                          Text('Place Order',
                              style: GoogleFonts.afacad(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.3,
                                  color: Colors.white)),
                          const Spacer(),
                          Container(
                            height: 42,
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(21),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('KSh ${total.toStringAsFixed(0)}',
                                    style: GoogleFonts.afacad(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        color: kPrimaryColor)),
                                const SizedBox(width: 8),
                                const Icon(CupertinoIcons.arrow_right,
                                    color: kPrimaryColor, size: 16),
                              ],
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(CupertinoIcons.checkmark_shield_fill,
                    size: 13, color: kPrimaryColor),
                const SizedBox(width: 6),
                Text('Encrypted & secure checkout',
                    style: GoogleFonts.afacad(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: kTextSecondary)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}