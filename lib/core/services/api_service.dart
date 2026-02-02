import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:kericho_delivery/core/constants/app_constants.dart';
import 'package:kericho_delivery/data/models/order_model.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  
  factory ApiService() {
    return _instance;
  }
  
  ApiService._internal();
  
  final String _baseUrl = AppConstants.baseUrl;
  String? _authToken;
  
  void setAuthToken(String token) {
    _authToken = token;
  }
  
  Future<Map<String, String>> _getHeaders() async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    
    return headers;
  }
  
  // Order-related API methods
  Future<OrderModel> createOrder(OrderModel order) async {
    // TODO: Implement actual API call
    await Future.delayed(const Duration(seconds: 1));
    return order;
  }
  
  Future<List<OrderModel>> getOrders() async {
    // TODO: Implement actual API call
    await Future.delayed(const Duration(seconds: 1));
    return [];
  }
  
  Future<OrderModel> getOrderById(String orderId) async {
    // TODO: Implement actual API call
    await Future.delayed(const Duration(seconds: 1));
    throw Exception('Not implemented');
  }
  
  Future<OrderModel> updateOrderStatus(
    String orderId, 
    OrderStatus status
  ) async {
    // TODO: Implement actual API call
    await Future.delayed(const Duration(seconds: 1));
    throw Exception('Not implemented');
  }
  
  Future<void> cancelOrder(String orderId, String? reason) async {
    // TODO: Implement actual API call
    await Future.delayed(const Duration(seconds: 1));
  }
  
  Future<void> rateOrder(
    String orderId, 
    int rating, 
    String? review
  ) async {
    // TODO: Implement actual API call
    await Future.delayed(const Duration(seconds: 1));
  }
}