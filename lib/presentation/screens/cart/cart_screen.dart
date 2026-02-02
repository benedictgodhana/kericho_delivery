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
    Provider.of<AppProvider>(context, listen: false)
      .removeFromCart(productId);
  }

  void _clearCart() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Clear Cart'),
          content: const Text('Are you sure you want to clear your cart?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Provider.of<AppProvider>(context, listen: false).clearCart();
                Navigator.pop(context);
              },
              child: const Text('Clear', style: TextStyle(color: Colors.red)),
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
        const SnackBar(content: Text('Your cart is empty')),
      );
      return;
    }

    if (_deliveryAddressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a delivery address')),
      );
      return;
    }

    if (locationProvider.currentLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enable location services')),
      );
      return;
    }

    setState(() => _isCheckingOut = true);

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
      // TODO: Handle multiple merchant orders
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
        SnackBar(content: Text('Checkout failed: $e')),
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
      appBar: AppBar(
        title: const Text('My Cart'),
        actions: [
          if (cart.items.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _clearCart,
            ),
        ],
      ),
      body: cart.items.isEmpty
          ? _buildEmptyCart()
          : _buildCartWithItems(),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 100,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 24),
          Text(
            'Your cart is empty',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Add items from restaurants or stores',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              AppRouter.pushNamedAndRemoveUntil(AppRouter.home);
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
            child: const Text('Start Shopping'),
          ),
        ],
      ),
    );
  }

  Widget _buildCartWithItems() {
    final appProvider = Provider.of<AppProvider>(context);
    final cart = appProvider.cart;

    return Column(
      children: [
        // Cart Items List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: cart.items.length,
            itemBuilder: (context, index) {
              final item = cart.items[index];
              return _buildCartItem(item);
            },
          ),
        ),

        // Checkout Section
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(color: Colors.grey[200]!),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            children: [
              // Delivery Address
              TextField(
                controller: _deliveryAddressController,
                decoration: InputDecoration(
                  labelText: 'Delivery Address',
                  hintText: 'Enter your delivery address',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.location_on),
                    onPressed: _updateDeliveryAddress,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                maxLines: 2,
              ),

              const SizedBox(height: 16),

              // Special Instructions
              TextField(
                controller: _specialInstructionsController,
                decoration: InputDecoration(
                  labelText: 'Special Instructions (Optional)',
                  hintText: 'e.g., Leave at door, Call on arrival',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                maxLines: 2,
              ),

              const SizedBox(height: 16),

              // Payment Method
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Payment Method',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ChoiceChip(
                          label: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/mpesa.png', // Add M-Pesa logo asset
                                width: 24,
                                height: 24,
                                color: Colors.green,
                              ),
                              const SizedBox(width: 8),
                              const Text('M-Pesa'),
                            ],
                          ),
                          selected: _selectedPaymentMethod == PaymentMethod.mpesa,
                          onSelected: (_) {
                            setState(() {
                              _selectedPaymentMethod = PaymentMethod.mpesa;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ChoiceChip(
                          label: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.money),
                              SizedBox(width: 8),
                              Text('Cash'),
                            ],
                          ),
                          selected: _selectedPaymentMethod == PaymentMethod.cash,
                          onSelected: (_) {
                            setState(() {
                              _selectedPaymentMethod = PaymentMethod.cash;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Order Summary
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _buildSummaryRow('Subtotal', appProvider.cartSubtotal),
                    _buildSummaryRow('Delivery Fee', 50.0), // Fixed for demo
                    if (cart.discountAmount != null && cart.discountAmount! > 0)
                      _buildSummaryRow('Discount', -cart.discountAmount!),
                    const Divider(height: 24),
                    _buildSummaryRow(
                      'Total',
                      appProvider.cartSubtotal + 50.0 - (cart.discountAmount ?? 0),
                      isTotal: true,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Checkout Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isCheckingOut ? null : _proceedToCheckout,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isCheckingOut
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'Proceed to Checkout',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCartItem(CartItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
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
      child: Row(
        children: [
          // Product Image
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: item.product.imageUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      item.product.imageUrl!,
                      fit: BoxFit.cover,
                    ),
                  )
                : const Icon(
                    Icons.fastfood,
                    size: 40,
                    color: Colors.grey,
                  ),
          ),

          const SizedBox(width: 12),

          // Product Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 4),

                if (item.selectedOptions != null && item.selectedOptions!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      item.selectedOptions!.join(', '),
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                if (item.specialInstructions != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      '"${item.specialInstructions!}"',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: AppTheme.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                Text(
                  'KSh ${(item.product.price * item.quantity).toStringAsFixed(2)}',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
          ),

          // Quantity Controls
          Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove, size: 18),
                      onPressed: () => _updateQuantity(
                        item.product.id,
                        item.quantity - 1,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 36,
                        minHeight: 36,
                      ),
                    ),
                    SizedBox(
                      width: 30,
                      child: Text(
                        item.quantity.toString(),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add, size: 18),
                      onPressed: () => _updateQuantity(
                        item.product.id,
                        item.quantity + 1,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 36,
                        minHeight: 36,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 20),
                onPressed: () => _removeItem(item.product.id),
                color: Colors.red,
                padding: EdgeInsets.zero,
              ),
            ],
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
            style: GoogleFonts.poppins(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.w400,
              color: isTotal ? AppTheme.textPrimary : Colors.grey[600],
            ),
          ),
          const Spacer(),
          Text(
            'KSh ${amount.toStringAsFixed(2)}',
            style: GoogleFonts.poppins(
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