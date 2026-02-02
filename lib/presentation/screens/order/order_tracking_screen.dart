import 'package:flutter/material.dart';
import 'package:kericho_delivery/data/models/order_model.dart';
import 'package:kericho_delivery/data/models/rider_model.dart';
import 'package:provider/provider.dart';
import 'package:kericho_delivery/presentation/providers/order_provider.dart';
import 'package:kericho_delivery/presentation/providers/location_provider.dart';
import 'package:kericho_delivery/core/theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class OrderTrackingScreen extends StatefulWidget {
  final String orderId;
  
  const OrderTrackingScreen({
    super.key,
    required this.orderId,
  });
  
  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  late GoogleMapController _mapController;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  
  @override
  void initState() {
    super.initState();
    _initializeTracking();
  }
  
  void _initializeTracking() {
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    final order = orderProvider.getOrderById(widget.orderId);
    
    if (order != null) {
      orderProvider.setActiveOrder(order);
    }
  }
  
  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _updateMapMarkers();
  }
  
  void _updateMapMarkers() {
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    final locationProvider = Provider.of<LocationProvider>(context, listen: false);
    
    _markers.clear();
    _polylines.clear();
    
    // Merchant marker
    if (orderProvider.activeOrder != null) {
      final merchantLatLng = LatLng(
        -0.3670, // Mock merchant location
        35.2830,
      );
      
      _markers.add(
        Marker(
          markerId: const MarkerId('merchant'),
          position: merchantLatLng,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          infoWindow: const InfoWindow(title: 'Merchant'),
        ),
      );
      
      // Delivery location marker
      final deliveryLatLng = LatLng(
        orderProvider.activeOrder!.deliveryLocation.latitude,
        orderProvider.activeOrder!.deliveryLocation.longitude,
      );
      
      _markers.add(
        Marker(
          markerId: const MarkerId('delivery'),
          position: deliveryLatLng,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: InfoWindow(
            title: 'Delivery: ${orderProvider.activeOrder!.deliveryAddress}',
          ),
        ),
      );
      
      // Rider marker
      if (orderProvider.riderLocation != null) {
        final riderLatLng = LatLng(
          orderProvider.riderLocation!.latitude,
          orderProvider.riderLocation!.longitude,
        );
        
        _markers.add(
          Marker(
            markerId: const MarkerId('rider'),
            position: riderLatLng,
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
            infoWindow: InfoWindow(
              title: orderProvider.assignedRider?.name ?? 'Rider',
            ),
          ),
        );
        
        // Draw polyline from rider to delivery
        _polylines.add(
          Polyline(
            polylineId: const PolylineId('route'),
            color: AppTheme.primaryColor,
            width: 4,
            points: [riderLatLng, deliveryLatLng],
          ),
        );
        
        // Animate camera to show both points
        _mapController.animateCamera(
          CameraUpdate.newLatLngBounds(
            LatLngBounds(
              southwest: LatLng(
                riderLatLng.latitude - 0.01,
                riderLatLng.longitude - 0.01,
              ),
              northeast: LatLng(
                deliveryLatLng.latitude + 0.01,
                deliveryLatLng.longitude + 0.01,
              ),
            ),
            50,
          ),
        );
      }
    }
    
    setState(() {});
  }
  
  String _getStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'Order placed';
      case OrderStatus.accepted:
        return 'Merchant accepted';
      case OrderStatus.preparing:
        return 'Preparing your order';
      case OrderStatus.ready:
        return 'Ready for pickup';
      case OrderStatus.pickedUp:
        return 'Rider picked up';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }
  
  IconData _getStatusIcon(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Icons.access_time;
      case OrderStatus.accepted:
        return Icons.check_circle_outline;
      case OrderStatus.preparing:
        return Icons.restaurant;
      case OrderStatus.ready:
        return Icons.shopping_bag;
      case OrderStatus.pickedUp:
        return Icons.delivery_dining;
      case OrderStatus.delivered:
        return Icons.check_circle;
      case OrderStatus.cancelled:
        return Icons.cancel;
    }
  }
  
  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.accepted:
        return Colors.blue;
      case OrderStatus.preparing:
        return Colors.purple;
      case OrderStatus.ready:
        return Colors.teal;
      case OrderStatus.pickedUp:
        return AppTheme.primaryColor;
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);
    final order = orderProvider.getOrderById(widget.orderId);
    
    if (order == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Order Tracking'),
        ),
        body: const Center(
          child: Text('Order not found'),
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Order #${order.orderNumber}'),
        actions: [
          if (order.status != OrderStatus.delivered && 
              order.status != OrderStatus.cancelled)
            IconButton(
              icon: const Icon(Icons.cancel),
              onPressed: () {
                _showCancelDialog(context, order.id);
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Map Section
            SizedBox(
              height: 300,
              child: GoogleMap(
                onMapCreated: _onMapCreated,
                initialCameraPosition: const CameraPosition(
                  target: LatLng(-0.3670, 35.2830), // Kericho center
                  zoom: 14,
                ),
                markers: _markers,
                polylines: _polylines,
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                zoomControlsEnabled: false,
              ),
            ),
            
            // Order Status Timeline
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order Status',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Status Timeline
                  _buildStatusTimeline(order.status),
                  
                  const SizedBox(height: 24),
                  
                  // Rider Info
                  if (orderProvider.assignedRider != null)
                    _buildRiderInfo(orderProvider.assignedRider!),
                  
                  const SizedBox(height: 24),
                  
                  // Order Details
                  _buildOrderDetails(order),
                  
                  const SizedBox(height: 24),
                  
                  // Contact Buttons
                  _buildContactButtons(orderProvider),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatusTimeline(OrderStatus currentStatus) {
    final allStatuses = OrderStatus.values;
    final currentIndex = allStatuses.indexOf(currentStatus);
    
    return Column(
      children: allStatuses.asMap().entries.map((entry) {
        final index = entry.key;
        final status = entry.value;
        final isCompleted = index <= currentIndex;
        final isCurrent = index == currentIndex;
        
        return Row(
          children: [
            // Status Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isCompleted 
                  ? _getStatusColor(status).withOpacity(0.1)
                  : Colors.grey[100],
                shape: BoxShape.circle,
                border: Border.all(
                  color: isCompleted ? _getStatusColor(status) : (Colors.grey[300] ?? Colors.grey),
                  width: 2,
                ),
              ),
              child: Icon(
                _getStatusIcon(status),
                color: isCompleted ? _getStatusColor(status) : Colors.grey[400],
                size: 20,
              ),
            ),
            
            const SizedBox(width: 12),
            
            // Status Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getStatusText(status),
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w400,
                      color: isCurrent ? _getStatusColor(status) : Colors.grey[600],
                    ),
                  ),
                  if (isCurrent && status != OrderStatus.delivered && 
                      status != OrderStatus.cancelled)
                    Text(
                      'Estimated: ${_getEstimatedTime(status)}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                ],
              ),
            ),
            
            // Connector Line
            if (index < allStatuses.length - 1)
              Container(
                width: 2,
                height: 30,
                margin: const EdgeInsets.only(left: 19),
                color: index < currentIndex 
                  ? _getStatusColor(allStatuses[index + 1])
                  : Colors.grey[300],
              ),
          ],
        );
      }).toList(),
    );
  }
  
  String _getEstimatedTime(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return '5-10 mins';
      case OrderStatus.accepted:
        return '10-15 mins';
      case OrderStatus.preparing:
        return '15-20 mins';
      case OrderStatus.ready:
        return '5-10 mins';
      case OrderStatus.pickedUp:
        return 'Arriving soon';
      default:
        return '';
    }
  }
  
  Widget _buildRiderInfo(RiderModel rider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200] ?? Colors.grey),
      ),
      child: Row(
        children: [
          // Rider Avatar
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: rider.profileImage != null
                ? CircleAvatar(
                    backgroundImage: NetworkImage(rider.profileImage!),
                  )
                : Icon(
                    Icons.person,
                    size: 30,
                    color: AppTheme.primaryColor,
                  ),
          ),
          
          const SizedBox(width: 16),
          
          // Rider Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rider.name,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${rider.vehicleType} • ${rider.vehiclePlate}',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.star,
                      color: Colors.amber,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      rider.rating.toStringAsFixed(1),
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      ' • ${rider.totalDeliveries} deliveries',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Call Button
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.phone,
                color: Colors.white,
                size: 20,
              ),
            ),
            onPressed: () {
              // TODO: Implement call functionality
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildOrderDetails(OrderModel order) {
    return Container(
      padding: const EdgeInsets.all(16),
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
          Text(
            'Order Details',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          
          // Items
          Column(
            children: order.items.map((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${item.product.name} x${item.quantity}',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Text(
                      'KSh ${(item.product.price * item.quantity).toStringAsFixed(2)}',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          
          const Divider(height: 24),
          
          // Totals
          _buildTotalRow('Subtotal', order.subtotal),
          _buildTotalRow('Delivery Fee', order.deliveryFee),
          if (order.discountAmount != null && order.discountAmount! > 0)
            _buildTotalRow('Discount', -order.discountAmount!),
          
          const Divider(height: 24),
          
          _buildTotalRow(
            'Total',
            order.totalAmount,
            isTotal: true,
          ),
          
          const SizedBox(height: 16),
          
          // Payment Status
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: order.paymentStatus == PaymentStatus.completed
                    ? Colors.green.withOpacity(0.1)
                    : Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  order.paymentStatus == PaymentStatus.completed
                    ? 'Paid'
                    : 'Payment Pending',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: order.paymentStatus == PaymentStatus.completed
                      ? Colors.green
                      : Colors.orange,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                order.paymentMethod == PaymentMethod.mpesa
                  ? 'M-Pesa'
                  : 'Cash on Delivery',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildTotalRow(String label, double amount, {bool isTotal = false}) {
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
  
  Widget _buildContactButtons(OrderProvider orderProvider) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              // TODO: Implement chat functionality
            },
            icon: const Icon(Icons.chat),
            label: const Text('Chat with Rider'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              // TODO: Implement call functionality
            },
            icon: const Icon(Icons.phone),
            label: const Text('Call Rider'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  void _showCancelDialog(BuildContext context, String orderId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Cancel Order'),
          content: const Text('Are you sure you want to cancel this order?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Provider.of<OrderProvider>(context, listen: false)
                  .cancelOrder(orderId);
                Navigator.pop(context); // Go back
              },
              child: const Text('Yes, Cancel'),
            ),
          ],
        );
      },
    );
  }
}