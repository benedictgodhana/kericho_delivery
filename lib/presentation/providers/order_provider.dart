import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:kericho_delivery/data/models/cart_model.dart';
import 'package:kericho_delivery/data/models/order_model.dart';
import 'package:kericho_delivery/data/models/location_model.dart';
import 'package:kericho_delivery/data/models/product_model.dart';
import 'package:kericho_delivery/data/models/rider_model.dart';
import 'package:kericho_delivery/core/services/api_service.dart';
import 'package:kericho_delivery/core/services/mpesa_service.dart';

class OrderProvider with ChangeNotifier {
  // Current active order (for tracking)
  OrderModel? _activeOrder;
  
  // Order history
  List<OrderModel> _orders = [];
  
  // Filtered orders
  List<OrderModel> _filteredOrders = [];
  
  // Order status filter
  OrderStatus? _statusFilter;
  
  // Date range filter
  DateTimeRange? _dateRangeFilter;
  
  // Search query
  String _searchQuery = '';
  
  // Loading states
  bool _isLoading = false;
  bool _isPlacingOrder = false;
  bool _isTracking = false;
  
  // Error handling
  String? _error;
  
  // Real-time tracking
  Timer? _trackingTimer;
  LocationModel? _riderLocation;
  RiderModel? _assignedRider;
  
  // Payment
  bool _isProcessingPayment = false;
  String? _paymentError;
  
  // Getters
  OrderModel? get activeOrder => _activeOrder;
  List<OrderModel> get orders => _filteredOrders;
  OrderStatus? get statusFilter => _statusFilter;
  DateTimeRange? get dateRangeFilter => _dateRangeFilter;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  bool get isPlacingOrder => _isPlacingOrder;
  bool get isTracking => _isTracking;
  bool get isProcessingPayment => _isProcessingPayment;
  String? get error => _error;
  String? get paymentError => _paymentError;
  LocationModel? get riderLocation => _riderLocation;
  RiderModel? get assignedRider => _assignedRider;
  
  // Statistics
  int get totalOrders => _orders.length;
  int get pendingOrders => _orders.where((o) => o.status == OrderStatus.pending).length;
  int get activeOrders => _orders.where((o) => 
    o.status == OrderStatus.accepted || 
    o.status == OrderStatus.preparing || 
    o.status == OrderStatus.ready || 
    o.status == OrderStatus.pickedUp
  ).length;
  int get completedOrders => _orders.where((o) => o.status == OrderStatus.delivered).length;
  int get cancelledOrders => _orders.where((o) => o.status == OrderStatus.cancelled).length;
  
  double get totalSpent => _orders
    .where((o) => o.status == OrderStatus.delivered)
    .fold(0.0, (sum, order) => sum + order.totalAmount);

  // Initialize provider
  OrderProvider() {
    _loadOrders();
  }

  // Load orders from API/local storage
  Future<void> _loadOrders() async {
    _setLoading(true);
    try {
      // TODO: Replace with actual API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock data for testing
      _orders = _getMockOrders();
      _filteredOrders = _orders;
      
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load orders: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }

  // Create new order
  Future<OrderModel?> createOrder({
    required String merchantId,
    required List<CartItem> items,
    required double subtotal,
    required double deliveryFee,
    required String deliveryAddress,
    required LocationModel deliveryLocation,
    required PaymentMethod paymentMethod,
    String? specialInstructions,
    String? couponCode,
  }) async {
    _setPlacingOrder(true);
    try {
      // Generate order number
      final orderNumber = 'KER-${DateTime.now().millisecondsSinceEpoch}';
      
      // Calculate total
      final discount = couponCode != null ? subtotal * 0.1 : 0.0; // 10% discount for demo
      final total = subtotal + deliveryFee - discount;
      
      // Create order object
      final order = OrderModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        orderNumber: orderNumber,
        customerId: 'current_user_id', // TODO: Get from auth
        merchantId: merchantId,
        items: items,
        subtotal: subtotal,
        deliveryFee: deliveryFee,
        discountAmount: discount,
        totalAmount: total,
        status: OrderStatus.pending,
        deliveryAddress: deliveryAddress,
        deliveryLocation: deliveryLocation,
        paymentMethod: paymentMethod,
        paymentStatus: PaymentStatus.pending,
        specialInstructions: specialInstructions,
        createdAt: DateTime.now(),
      );
      
      // Process payment based on method
      if (paymentMethod == PaymentMethod.mpesa) {
        await _processMpesaPayment(order);
      }
      
      // Save order locally
      _orders.insert(0, order);
      _activeOrder = order;
      _applyFilters();
      
      // TODO: Send to API
      // await ApiService.instance.createOrder(order);
      
      // Start tracking if payment successful
      if (order.paymentStatus == PaymentStatus.completed) {
        _startOrderTracking(order.id);
      }
      
      _error = null;
      notifyListeners();
      
      return order;
    } catch (e) {
      _error = 'Failed to create order: ${e.toString()}';
      return null;
    } finally {
      _setPlacingOrder(false);
    }
  }

  // Process M-Pesa payment
  Future<void> _processMpesaPayment(OrderModel order) async {
    _setProcessingPayment(true);
    try {
      // TODO: Implement actual M-Pesa payment
      await Future.delayed(const Duration(seconds: 2));
      
      // Simulate successful payment
      order = order.copyWith(
        paymentStatus: PaymentStatus.completed,
        mpesaReceipt: 'MP${DateTime.now().millisecondsSinceEpoch}',
      );
      
      _paymentError = null;
    } catch (e) {
      _paymentError = 'Payment failed: ${e.toString()}';
      order = order.copyWith(paymentStatus: PaymentStatus.failed);
      rethrow;
    } finally {
      _setProcessingPayment(false);
    }
  }

  // Cancel order
  Future<bool> cancelOrder(String orderId, {String? reason}) async {
    _setLoading(true);
    try {
      // Find and update order
      final index = _orders.indexWhere((order) => order.id == orderId);
      if (index != -1) {
        _orders[index] = _orders[index].copyWith(
          status: OrderStatus.cancelled,
        );
        
        if (_activeOrder?.id == orderId) {
          _activeOrder = null;
          _stopOrderTracking();
        }
        
        _applyFilters();
        
        // TODO: Notify API
        // await ApiService.instance.cancelOrder(orderId, reason);
        
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _error = 'Failed to cancel order: ${e.toString()}';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Rate order
  Future<void> rateOrder(String orderId, int rating, {String? review}) async {
    _setLoading(true);
    try {
      final index = _orders.indexWhere((order) => order.id == orderId);
      if (index != -1) {
        _orders[index] = _orders[index].copyWith(
          rating: rating,
          review: review,
        );
        
        // TODO: Send rating to API
        // await ApiService.instance.rateOrder(orderId, rating, review);
        
        _applyFilters();
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to rate order: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }

  // Start order tracking (simulated)
  Future<void> _startOrderTracking(String orderId) async {
    if (_isTracking) return;
    
    _isTracking = true;
    
    // Simulate rider assignment
    _assignedRider = RiderModel(
      id: 'rider_001',
      name: 'John Kamau',
      phone: '254712345678',
      vehicleType: 'Motorcycle',
      vehiclePlate: 'KBR 123A',
      rating: 4.5,
      totalDeliveries: 150,
      isAvailable: true,
    );
    
    // Simulate rider location updates
    _trackingTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      // Simulate rider moving towards destination
      if (_riderLocation == null) {
        // Start from merchant location (simulated)
        _riderLocation = LocationModel(
          latitude: -0.3670, // Kericho coordinates
          longitude: 35.2830,
          address: 'Starting point',
          timestamp: DateTime.now(),
        );
      } else {
        // Simulate movement
        _riderLocation = LocationModel(
          latitude: _riderLocation!.latitude + 0.001,
          longitude: _riderLocation!.longitude + 0.001,
          address: 'En route',
          timestamp: DateTime.now(),
        );
      }
      
      // Update order status based on simulated progress
      _updateOrderStatus(orderId, timer.tick);
      
      notifyListeners();
    });
    
    notifyListeners();
  }

  // Update order status based on tracking progress
  void _updateOrderStatus(String orderId, int tick) {
    final index = _orders.indexWhere((order) => order.id == orderId);
    if (index != -1) {
      final order = _orders[index];
      OrderStatus newStatus = order.status;
      
      // Simulate status progression
      switch (order.status) {
        case OrderStatus.pending:
          newStatus = OrderStatus.accepted;
          break;
        case OrderStatus.accepted:
          newStatus = OrderStatus.preparing;
          break;
        case OrderStatus.preparing:
          newStatus = OrderStatus.ready;
          break;
        case OrderStatus.ready:
          newStatus = OrderStatus.pickedUp;
          break;
        case OrderStatus.pickedUp:
          // Simulate delivery after some time
          if (tick > 6) {
            newStatus = OrderStatus.delivered;
            _stopOrderTracking();
          }
          break;
        default:
          break;
      }
      
      if (newStatus != order.status) {
        _orders[index] = order.copyWith(status: newStatus);
        
        // Update timestamps
        final now = DateTime.now();
        switch (newStatus) {
          case OrderStatus.accepted:
            _orders[index] = _orders[index].copyWith(acceptedAt: now);
            break;
          case OrderStatus.preparing:
            _orders[index] = _orders[index].copyWith(preparedAt: now);
            break;
          case OrderStatus.pickedUp:
            _orders[index] = _orders[index].copyWith(pickedUpAt: now);
            break;
          case OrderStatus.delivered:
            _orders[index] = _orders[index].copyWith(deliveredAt: now);
            break;
          default:
            break;
        }
        
        if (order.id == _activeOrder?.id) {
          _activeOrder = _orders[index];
        }
        
        notifyListeners();
      }
    }
  }

  // Stop order tracking
  void _stopOrderTracking() {
    _trackingTimer?.cancel();
    _trackingTimer = null;
    _isTracking = false;
    _riderLocation = null;
    _assignedRider = null;
    notifyListeners();
  }

  // Set active order for tracking
  void setActiveOrder(OrderModel order) {
    _activeOrder = order;
    
    // If order is still active, start tracking
    if (order.status != OrderStatus.delivered && 
        order.status != OrderStatus.cancelled) {
      _startOrderTracking(order.id);
    }
    
    notifyListeners();
  }

  // Filter orders
  void filterOrders({
    OrderStatus? status,
    DateTimeRange? dateRange,
    String search = '',
  }) {
    _statusFilter = status;
    _dateRangeFilter = dateRange;
    _searchQuery = search;
    _applyFilters();
    notifyListeners();
  }

  // Apply all filters
  void _applyFilters() {
    List<OrderModel> filtered = List.from(_orders);
    
    // Apply status filter
    if (_statusFilter != null) {
      filtered = filtered.where((order) => order.status == _statusFilter).toList();
    }
    
    // Apply date range filter
    if (_dateRangeFilter != null) {
      filtered = filtered.where((order) {
        return order.createdAt.isAfter(_dateRangeFilter!.start) &&
               order.createdAt.isBefore(_dateRangeFilter!.end);
      }).toList();
    }
    
    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((order) {
        return order.orderNumber.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               order.merchantId.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               order.deliveryAddress.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }
    
    _filteredOrders = filtered;
  }

  // Clear all filters
  void clearFilters() {
    _statusFilter = null;
    _dateRangeFilter = null;
    _searchQuery = '';
    _filteredOrders = List.from(_orders);
    notifyListeners();
  }

  // Get order by ID
  OrderModel? getOrderById(String orderId) {
    return _orders.firstWhere(
      (order) => order.id == orderId,
      orElse: () => throw Exception('Order not found'),
    );
  }

  // Get orders by merchant
  List<OrderModel> getOrdersByMerchant(String merchantId) {
    return _orders.where((order) => order.merchantId == merchantId).toList();
  }

  // Get recent orders
  List<OrderModel> getRecentOrders({int limit = 5}) {
    return _orders
      .where((order) => order.status == OrderStatus.delivered)
      .take(limit)
      .toList();
  }

  // Refresh orders from API
  Future<void> refreshOrders() async {
    await _loadOrders();
  }

  // Loading states
  void _setLoading(bool loading) {
    _isLoading = loading;
    if (loading) _error = null;
    notifyListeners();
  }

  void _setPlacingOrder(bool placing) {
    _isPlacingOrder = placing;
    if (placing) _error = null;
    notifyListeners();
  }

  void _setProcessingPayment(bool processing) {
    _isProcessingPayment = processing;
    if (processing) _paymentError = null;
    notifyListeners();
  }

  // Error handling
  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clearPaymentError() {
    _paymentError = null;
    notifyListeners();
  }

  // Mock data for testing
  List<OrderModel> _getMockOrders() {
    return [
      OrderModel(
        id: '1',
        orderNumber: 'KER-1001',
        customerId: 'user_001',
        merchantId: '1',
        riderId: 'rider_001',
        items: [
          CartItem(
            product: ProductModel(
              id: '101',
              name: 'Chicken Pilau',
              description: 'Spiced rice with chicken',
              price: 350.0,
              category: 'Main Course',
              merchantId: '1',
              createdAt: DateTime.now(),
            ),
            quantity: 2,
          ),
        ],
        subtotal: 700.0,
        deliveryFee: 50.0,
        totalAmount: 750.0,
        status: OrderStatus.delivered,
        deliveryAddress: '123 Kericho Town',
        deliveryLocation: LocationModel(
          latitude: -0.3670,
          longitude: 35.2830,
          address: '123 Kericho Town',
          timestamp: DateTime.now(),
        ),
        paymentMethod: PaymentMethod.mpesa,
        paymentStatus: PaymentStatus.completed,
        mpesaReceipt: 'MP123456789',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        deliveredAt: DateTime.now().subtract(const Duration(days: 1)),
        rating: 5,
        review: 'Great food, fast delivery!',
      ),
      OrderModel(
        id: '2',
        orderNumber: 'KER-1002',
        customerId: 'user_001',
        merchantId: '2',
        items: [
          CartItem(
            product: ProductModel(
              id: '201',
              name: 'Fresh Milk (1L)',
              description: 'Fresh dairy milk',
              price: 120.0,
              category: 'Dairy',
              merchantId: '2',
              createdAt: DateTime.now(),
            ),
            quantity: 3,
          ),
        ],
        subtotal: 360.0,
        deliveryFee: 40.0,
        totalAmount: 400.0,
        status: OrderStatus.pickedUp,
        deliveryAddress: '456 Kipchebor Estate',
        deliveryLocation: LocationModel(
          latitude: -0.3680,
          longitude: 35.2840,
          address: '456 Kipchebor Estate',
          timestamp: DateTime.now(),
        ),
        paymentMethod: PaymentMethod.cash,
        paymentStatus: PaymentStatus.pending,
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        acceptedAt: DateTime.now().subtract(const Duration(minutes: 50)),
        pickedUpAt: DateTime.now().subtract(const Duration(minutes: 10)),
      ),
      OrderModel(
        id: '3',
        orderNumber: 'KER-1003',
        customerId: 'user_001',
        merchantId: '3',
        items: [
          CartItem(
            product: ProductModel(
              id: '301',
              name: 'Painkillers',
              description: 'Paracetamol tablets',
              price: 50.0,
              category: 'Medicine',
              merchantId: '3',
              createdAt: DateTime.now(),
            ),
            quantity: 1,
          ),
        ],
        subtotal: 50.0,
        deliveryFee: 60.0,
        totalAmount: 110.0,
        status: OrderStatus.preparing,
        deliveryAddress: '789 Hospital Road',
        deliveryLocation: LocationModel(
          latitude: -0.3690,
          longitude: 35.2850,
          address: '789 Hospital Road',
          timestamp: DateTime.now(),
        ),
        paymentMethod: PaymentMethod.mpesa,
        paymentStatus: PaymentStatus.completed,
        mpesaReceipt: 'MP987654321',
        createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
        acceptedAt: DateTime.now().subtract(const Duration(minutes: 25)),
      ),
    ];
  }

  @override
  void dispose() {
    _trackingTimer?.cancel();
    super.dispose();
  }
}