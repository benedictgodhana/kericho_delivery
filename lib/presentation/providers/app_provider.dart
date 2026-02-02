import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:kericho_delivery/data/models/merchant_model.dart';
import 'package:kericho_delivery/data/models/order_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kericho_delivery/data/models/user_model.dart';
import 'package:kericho_delivery/data/models/location_model.dart';
import 'package:kericho_delivery/data/models/cart_model.dart';

class AppProvider with ChangeNotifier {
  // Singleton instance
  static AppProvider? _instance;
  
  static AppProvider get instance {
    _instance ??= AppProvider._();
    return _instance!;
  }

  AppProvider._() {
    _initialize();
  }

  // App State
  UserModel? _user;
  LocationModel? _currentLocation;
  CartModel _cart = CartModel(items: []);
  bool _isLoading = false;
  String? _error;
  ThemeMode _themeMode = ThemeMode.light;
  Locale _locale = const Locale('en', 'US');
  List<MerchantModel> _favorites = [];
  List<OrderModel> _orderHistory = [];

  // Getters
  UserModel? get user => _user;
  LocationModel? get currentLocation => _currentLocation;
  CartModel get cart => _cart;
  bool get isLoading => _isLoading;
  String? get error => _error;
  ThemeMode get themeMode => _themeMode;
  Locale get locale => _locale;
  List<MerchantModel> get favorites => _favorites;
  List<OrderModel> get orderHistory => _orderHistory;
  
  // Cart getters
  int get cartItemCount => _cart.items.fold(0, (sum, item) => sum + item.quantity);
  double get cartTotal => _cart.items.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
  double get cartSubtotal => _cart.items.fold(0.0, (sum, item) => sum + (item.product.price * item.quantity));

  // Initialize app
  Future<void> _initialize() async {
    await _loadUserData();
    await _loadCart();
    await _loadFavorites();
    await _loadPreferences();
  }

  // User Methods
  Future<void> loginUser(UserModel user) async {
    _setLoading(true);
    try {
      _user = user;
      await _saveUserData(user);
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Login failed: ${e.toString()}';
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    try {
      _user = null;
      _cart = CartModel(items: []);
      _favorites.clear();
      _orderHistory.clear();
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Logout failed: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateUserProfile(UserModel updatedUser) async {
    _setLoading(true);
    try {
      _user = updatedUser;
      await _saveUserData(updatedUser);
      notifyListeners();
    } catch (e) {
      _error = 'Update failed: ${e.toString()}';
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Location Methods
  Future<void> setCurrentLocation(LocationModel location) async {
    _currentLocation = location;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('latitude', location.latitude.toString());
    await prefs.setString('longitude', location.longitude.toString());
    await prefs.setString('address', location.address);
    notifyListeners();
  }

  Future<void> updateLocationFromGPS() async {
    // This would integrate with geolocator package
    // For now, simulate location update
    if (_currentLocation != null) {
      // Simulate minor location change
      final newLocation = LocationModel(
        latitude: _currentLocation!.latitude + 0.0001,
        longitude: _currentLocation!.longitude + 0.0001,
        address: _currentLocation!.address,
        timestamp: DateTime.now(),
      );
      await setCurrentLocation(newLocation);
    }
  }

  // Cart Methods
  Future<void> addToCart(CartItem item) async {
    final existingIndex = _cart.items.indexWhere(
      (cartItem) => cartItem.product.id == item.product.id,
    );

    if (existingIndex >= 0) {
      // Update quantity
      _cart.items[existingIndex] = _cart.items[existingIndex].copyWith(
        quantity: _cart.items[existingIndex].quantity + item.quantity,
      );
    } else {
      // Add new item
      _cart.items.add(item);
    }

    await _saveCart();
    notifyListeners();
  }

  Future<void> updateCartItem(String productId, int quantity) async {
    final index = _cart.items.indexWhere((item) => item.product.id == productId);
    
    if (index >= 0) {
      if (quantity <= 0) {
        _cart.items.removeAt(index);
      } else {
        _cart.items[index] = _cart.items[index].copyWith(quantity: quantity);
      }
      
      await _saveCart();
      notifyListeners();
    }
  }

  Future<void> removeFromCart(String productId) async {
    _cart.items.removeWhere((item) => item.product.id == productId);
    await _saveCart();
    notifyListeners();
  }

  Future<void> clearCart() async {
    _cart = CartModel(items: []);
    await _saveCart();
    notifyListeners();
  }

  // Favorites Methods
  Future<void> toggleFavorite(MerchantModel merchant) async {
    if (_favorites.any((m) => m.id == merchant.id)) {
      _favorites.removeWhere((m) => m.id == merchant.id);
    } else {
      _favorites.add(merchant);
    }
    await _saveFavorites();
    notifyListeners();
  }

  bool isFavorite(String merchantId) {
    return _favorites.any((merchant) => merchant.id == merchantId);
  }

  // Order History Methods
  Future<void> addToOrderHistory(OrderModel order) async {
    _orderHistory.insert(0, order);
    // Keep only last 50 orders
    if (_orderHistory.length > 50) {
      _orderHistory = _orderHistory.sublist(0, 50);
    }
    notifyListeners();
  }

  // Theme Methods
  Future<void> toggleTheme() async {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_mode', _themeMode == ThemeMode.light ? 'light' : 'dark');
    notifyListeners();
  }

  Future<void> setTheme(ThemeMode mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_mode', mode == ThemeMode.light ? 'light' : 'dark');
    notifyListeners();
  }

  // Language/Locale Methods
  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', locale.languageCode);
    await prefs.setString('country_code', locale.countryCode ?? '');
    notifyListeners();
  }

  // Loading State
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Error Handling
  void setError(String? error) {
    _error = error;
    if (error != null) {
      // Clear error after 5 seconds
      Future.delayed(const Duration(seconds: 5), () {
        _error = null;
        notifyListeners();
      });
    }
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Persistence Methods
  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('user_data');
      
      if (userJson != null) {
        _user = UserModel.fromJson(userJson as Map<String, dynamic>);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading user data: $e');
      }
    }
  }

  Future<void> _saveUserData(UserModel user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_data', user.toJson() as String);
    } catch (e) {
      if (kDebugMode) {
        print('Error saving user data: $e');
      }
    }
  }

  Future<void> _loadCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJson = prefs.getString('cart_data');
      
      if (cartJson != null) {
        _cart = CartModel.fromJson(cartJson as Map<String, dynamic>);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading cart: $e');
      }
    }
  }

  Future<void> _saveCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('cart_data', _cart.toJson() as String);
    } catch (e) {
      if (kDebugMode) {
        print('Error saving cart: $e');
      }
    }
  }

  Future<void> _loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = prefs.getString('favorites');
      
      if (favoritesJson != null) {
        final List<dynamic> favoritesList = favoritesJson as List<dynamic>;
        _favorites = favoritesList.map((json) => MerchantModel.fromJson(json)).toList();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading favorites: $e');
      }
    }
  }

  Future<void> _saveFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = _favorites.map((merchant) => merchant.toJson()).toList();
      await prefs.setString('favorites', favoritesJson.toString());
    } catch (e) {
      if (kDebugMode) {
        print('Error saving favorites: $e');
      }
    }
  }

  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load theme
      final theme = prefs.getString('theme_mode');
      if (theme == 'dark') {
        _themeMode = ThemeMode.dark;
      } else {
        _themeMode = ThemeMode.light;
      }
      
      // Load locale
      final languageCode = prefs.getString('language_code') ?? 'en';
      final countryCode = prefs.getString('country_code') ?? 'US';
      _locale = Locale(languageCode, countryCode);
      
      // Load location if exists
      final lat = prefs.getString('latitude');
      final lng = prefs.getString('longitude');
      final address = prefs.getString('address');
      
      if (lat != null && lng != null) {
        _currentLocation = LocationModel(
          latitude: double.parse(lat),
          longitude: double.parse(lng),
          address: address ?? 'Kericho, Kenya',
          timestamp: DateTime.now(),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading preferences: $e');
      }
    }
  }

  // Reset app state (for testing/debugging)
  Future<void> resetApp() async {
    await logout();
    _currentLocation = null;
    _themeMode = ThemeMode.light;
    _locale = const Locale('en', 'US');
    _error = null;
    notifyListeners();
  }
}