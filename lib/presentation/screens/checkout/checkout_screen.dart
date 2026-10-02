import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kericho_delivery/data/models/cart_model.dart';
import 'package:kericho_delivery/data/models/order_model.dart';
import 'package:kericho_delivery/presentation/providers/app_provider.dart';
import 'package:kericho_delivery/presentation/providers/location_provider.dart';
import 'package:kericho_delivery/presentation/providers/order_provider.dart';
import 'package:kericho_delivery/presentation/router/app_router.dart';
import 'package:kericho_delivery/core/theme/app_theme.dart';

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
  DeliveryMethod _deliveryMethod = DeliveryMethod.delivery;
  PaymentMethod _paymentMethod = PaymentMethod.mpesa;

  final _locationController = TextEditingController();
  final _buildingController = TextEditingController();
  final _apartmentController = TextEditingController();
  final _instructionsController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

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
    super.dispose();
  }

  double get _deliveryFee => _deliveryMethod == DeliveryMethod.pickup ? 0 : widget.baseDeliveryFee;
  double get _total => widget.subtotal + _deliveryFee + _serviceFee;

  Future<void> _placeOrder() async {
    if (_deliveryMethod == DeliveryMethod.delivery && _locationController.text.trim().isEmpty) {
      _showError('Please enter your delivery location');
      return;
    }
    if (_nameController.text.trim().isEmpty || _phoneController.text.trim().isEmpty) {
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
      final addressParts = [
        _locationController.text.trim(),
        if (_buildingController.text.trim().isNotEmpty) _buildingController.text.trim(),
        if (_apartmentController.text.trim().isNotEmpty) _apartmentController.text.trim(),
      ];
      final deliveryAddress = _deliveryMethod == DeliveryMethod.pickup
          ? 'Pickup at ${widget.merchantName}'
          : addressParts.join(', ');

      final order = await orderProvider.createOrder(
        merchantId: widget.merchantId,
        items: widget.items,
        subtotal: widget.subtotal,
        deliveryFee: _deliveryFee + _serviceFee,
        deliveryAddress: deliveryAddress,
        deliveryLocation: locationProvider.currentLocation!,
        paymentMethod: _paymentMethod,
        specialInstructions: _instructionsController.text.trim().isNotEmpty
            ? _instructionsController.text.trim()
            : null,
      );

      if (order == null) {
        _showError('Could not place order. Please try again.');
        return;
      }

      for (final item in widget.items) {
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
        title: const Text('Sign in to continue?'),
        content: const Text(
          'Signing in lets you track this order from your profile and saves your details for next time. '
          'You can also continue as a guest.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Sign In'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Continue as Guest'),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionTitle('Delivery method'),
          Row(
            children: [
              Expanded(
                child: _methodChip(
                  label: 'Delivery',
                  icon: Icons.delivery_dining,
                  selected: _deliveryMethod == DeliveryMethod.delivery,
                  onTap: () => setState(() => _deliveryMethod = DeliveryMethod.delivery),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _methodChip(
                  label: 'Pickup',
                  icon: Icons.storefront,
                  selected: _deliveryMethod == DeliveryMethod.pickup,
                  onTap: () => setState(() => _deliveryMethod = DeliveryMethod.pickup),
                ),
              ),
            ],
          ),
          if (_deliveryMethod == DeliveryMethod.delivery) ...[
            const SizedBox(height: 24),
            _sectionTitle('Delivery address'),
            _field(_locationController, 'Location', Icons.location_on_outlined),
            const SizedBox(height: 12),
            _field(_buildingController, 'Building (optional)', Icons.apartment_outlined),
            const SizedBox(height: 12),
            _field(_apartmentController, 'Apartment / House no. (optional)', Icons.door_front_door_outlined),
            const SizedBox(height: 12),
            _field(_instructionsController, 'Additional instructions (optional)', Icons.sticky_note_2_outlined, maxLines: 2),
          ] else ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: AppTheme.primaryColor, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "You'll collect this order yourself from ${widget.merchantName}.",
                      style: GoogleFonts.afacad(fontSize: 13, color: AppTheme.textPrimary),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),
          _sectionTitle('Contact details'),
          _field(_nameController, 'Full name', Icons.person_outline),
          const SizedBox(height: 12),
          _field(_phoneController, 'Phone number', Icons.phone_outlined, keyboardType: TextInputType.phone),
          const SizedBox(height: 24),
          _sectionTitle('Payment method'),
          _paymentTile(PaymentMethod.mpesa, 'M-PESA', Icons.phone_android),
          _paymentTile(PaymentMethod.card, 'Card', Icons.credit_card),
          _paymentTile(PaymentMethod.wallet, 'KulaHub Wallet', Icons.account_balance_wallet),
          _paymentTile(PaymentMethod.cash, 'Cash', Icons.money),
          const SizedBox(height: 24),
          _sectionTitle('Order summary'),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                _summaryRow('Subtotal', widget.subtotal),
                _summaryRow(_deliveryMethod == DeliveryMethod.pickup ? 'Delivery' : 'Delivery fee', _deliveryFee),
                _summaryRow('Service fee', _serviceFee),
                const Divider(height: 24),
                _summaryRow('Total', _total, isTotal: true),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isPlacingOrder ? null : _placeOrder,
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              child: _isPlacingOrder
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text('Place Order', style: GoogleFonts.afacad(fontSize: 16, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(title, style: GoogleFonts.afacad(fontSize: 16, fontWeight: FontWeight.w700)),
      );

  Widget _methodChip({
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primaryColor.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: selected ? AppTheme.primaryColor : Colors.grey[300]!, width: selected ? 2 : 1),
        ),
        child: Column(
          children: [
            Icon(icon, color: selected ? AppTheme.primaryColor : Colors.grey[600]),
            const SizedBox(height: 6),
            Text(
              label,
              style: GoogleFonts.afacad(
                fontWeight: FontWeight.w600,
                color: selected ? AppTheme.primaryColor : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(TextEditingController controller, String label, IconData icon, {int maxLines = 1, TextInputType? keyboardType}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _paymentTile(PaymentMethod method, String label, IconData icon) {
    final selected = _paymentMethod == method;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: selected ? AppTheme.primaryColor : Colors.grey[200]!, width: selected ? 2 : 1),
      ),
      child: RadioListTile<PaymentMethod>(
        value: method,
        groupValue: _paymentMethod,
        onChanged: (value) => setState(() => _paymentMethod = value!),
        activeColor: AppTheme.primaryColor,
        secondary: Icon(icon, color: AppTheme.primaryColor),
        title: Text(label, style: GoogleFonts.afacad(fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _summaryRow(String label, double amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            label,
            style: GoogleFonts.afacad(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.w400,
              color: isTotal ? AppTheme.textPrimary : Colors.grey[600],
            ),
          ),
          const Spacer(),
          Text(
            'KSh ${amount.toStringAsFixed(2)}',
            style: GoogleFonts.afacad(
              fontSize: isTotal ? 18 : 14,
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
              color: isTotal ? AppTheme.primaryColor : AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
