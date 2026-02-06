import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:kericho_delivery/core/constants/app_constants.dart';
import 'package:kericho_delivery/data/models/merchant_model.dart';
import 'package:kericho_delivery/data/models/order_model.dart';
import 'package:kericho_delivery/data/models/user_model.dart';
import 'package:kericho_delivery/data/models/location_model.dart';
import 'package:kericho_delivery/data/models/cart_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class AppProvider with ChangeNotifier {
  /// Clears all favorite merchants and updates persistent storage.
  Future<void> clearAllFavorites() async {
    _favorites.clear();
    await _saveFavorites();
    notifyListeners();
  }

  static AppProvider? _instance;

  static AppProvider get instance {
    _instance ??= AppProvider._();
    return _instance!;
  }

  AppProvider._() {
    _initialize();
  }

  UserModel? _user;
  LocationModel? _currentLocation;
  CartModel _cart = CartModel(items: []);
  bool _isLoading = false;
  String? _error;
  ThemeMode _themeMode = ThemeMode.light;
  Locale _locale = const Locale('en', 'US');
  List<MerchantModel> _favorites = [];
  List<OrderModel> _orderHistory = [];
  String? _authToken;
  String? _refreshToken;

  // ── Getters ────────────────────────────────────────────────────────────────
  UserModel? get user => _user;
  LocationModel? get currentLocation => _currentLocation;
  CartModel get cart => _cart;
  bool get isLoading => _isLoading;
  String? get error => _error;
  ThemeMode get themeMode => _themeMode;
  Locale get locale => _locale;
  List<MerchantModel> get favorites => _favorites;
  List<OrderModel> get orderHistory => _orderHistory;
  String? get authToken => _authToken;

  int get cartItemCount =>
      _cart.items.fold(0, (sum, item) => sum + item.quantity);
  double get cartTotal =>
      _cart.items.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
  double get cartSubtotal => _cart.items
      .fold(0.0, (sum, item) => sum + (item.product.price * item.quantity));

  bool get isAuthenticated => _authToken != null && _user != null;

  Future<void> _initialize() async {
    await _loadTokens();
    await _loadUserData();
    await _loadCart();
    await _loadFavorites();
    await _loadPreferences();
  }

  // ── API Core ───────────────────────────────────────────────────────────────
  Future<http.Response> _makeApiRequest(
    String url,
    String method, {
    Map<String, dynamic>? body,
    bool requiresAuth = true,
    Map<String, String>? additionalHeaders,
  }) async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (requiresAuth && _authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }

    if (additionalHeaders != null) {
      headers.addAll(additionalHeaders);
    }

    http.Response response;
    final uri = Uri.parse(url);

    try {
      switch (method.toLowerCase()) {
        case 'post':
          response = await http.post(
            uri,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          );
          break;
        case 'get':
          response = await http.get(uri, headers: headers);
          break;
        case 'put':
          response = await http.put(
            uri,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          );
          break;
        case 'delete':
          response = await http.delete(uri, headers: headers);
          break;
        default:
          throw Exception('Unsupported HTTP method: $method');
      }

      if (response.statusCode == 401 && requiresAuth) {
        final refreshed = await _refreshAuthToken();
        if (refreshed) {
          return await _makeApiRequest(url, method,
              body: body, requiresAuth: requiresAuth);
        }
      }

      return response;
    } on SocketException {
      throw Exception('No internet connection. Please check your network.');
    } on http.ClientException {
      throw Exception('Unable to connect to server. Please try again later.');
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<bool> _refreshAuthToken() async {
    if (_refreshToken == null) return false;

    try {
      final response = await http.post(
        Uri.parse('${AppConstants.apiBaseUrl}/auth/refresh'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $_refreshToken',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _authToken = data['access_token'];
        _refreshToken = data['refresh_token'] ?? _refreshToken;
        await _saveTokens();
        if (kDebugMode) print('Token refreshed successfully');
        return true;
      }
      return false;
    } catch (e) {
      if (kDebugMode) print('Token refresh failed: $e');
      return false;
    }
  }

  // ── Authentication Flows ───────────────────────────────────────────────────
  Future<void> sendOtp(String phone) async {
    _setLoading(true);
    try {
      if (kDebugMode) print('→ Sending OTP to: $phone');

      final response = await _makeApiRequest(
        AppConstants.sendOtpEndpoint,
        'post',
        body: {'phone': phone},
        requiresAuth: false,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true ||
            data['message']?.contains('OTP sent') == true) {
          _error = null;
        } else {
          throw Exception(data['message'] ?? 'Failed to send OTP');
        }
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to send OTP');
      }
    } catch (e) {
      _error = 'Failed to send OTP: $e';
      if (kDebugMode) print(_error);
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<dynamic> verifyOtp(String phone, String otp) async {
    _setLoading(true);
    try {
      if (kDebugMode) print('→ Verifying OTP → $phone / $otp');

      // Ensure OTP is always a 4-character string (pad with zeros if needed)
      final otpStr = otp.padLeft(4, '0');
      final response = await _makeApiRequest(
        AppConstants.verifyOtpEndpoint,
        'post',
        body: {'phone': phone, 'otp': otpStr},
        requiresAuth: false,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Debug log to see actual response structure
        if (kDebugMode) {
          print('OTP Response: $data');
          print('Response type: ${data.runtimeType}');
        }

        // Check success in various ways
        bool success = false;
        if (data is Map<String, dynamic>) {
          if (data.containsKey('success')) {
            final successValue = data['success'];
            success = successValue == true ||
                successValue == 'true' ||
                successValue == 1 ||
                successValue == '1';
          } else if (data.containsKey('status')) {
            final statusValue = data['status'];
            success = statusValue == true ||
                statusValue == 'true' ||
                statusValue == 'success' ||
                statusValue == 200 ||
                statusValue == 1;
          } else if (data.containsKey('verified')) {
            final verifiedValue = data['verified'];
            success = verifiedValue == true ||
                verifiedValue == 'true' ||
                verifiedValue == 1 ||
                verifiedValue == '1';
          }
        } else if (data is String) {
          success = data.toLowerCase() == 'true' || data == '1';
        } else if (data is int) {
          success = data == 1 || data == 200;
        } else if (data is bool) {
          success = data;
        }

        if (success) {
          // Extract user data
          UserModel? user;
          String? token;
          bool hasGoogle = false;

          if (data is Map<String, dynamic>) {
            // Try different user key possibilities
            if (data.containsKey('user') && data['user'] is Map) {
              try {
                user = UserModel.fromJson(data['user']);
              } catch (e) {
                if (kDebugMode) print('Error parsing user: $e');
              }
            } else if (data.containsKey('data') && data['data'] is Map) {
              try {
                user = UserModel.fromJson(data['data']);
              } catch (e) {
                if (kDebugMode) print('Error parsing user from data: $e');
              }
            }

            // Try different token key possibilities
            token = data['token'] ?? data['access_token'] ?? data['auth_token'];

            // Check for Google linkage
            if (data.containsKey('has_google')) {
              final googleValue = data['has_google'];
              hasGoogle = googleValue == true ||
                  googleValue == 'true' ||
                  googleValue == 1 ||
                  googleValue == '1';
            } else if (user != null) {
              hasGoogle = user.googleId != null && user.googleId!.isNotEmpty;
            }
          }

          // If we got a token, store it
          if (token != null) {
            _authToken = token;
            await _saveTokens();
          }

          // If we got a user, store it
          if (user != null) {
            _user = user;
            await _saveUserData(user);
          }

          // Return appropriate response
          return {
            'success': true,
            'has_google': hasGoogle,
            'user': user,
          };
        } else {
          final message = (data is Map<String, dynamic>)
              ? (data['message'] ?? data['error'] ?? 'Verification failed')
              : 'Verification failed';
          throw Exception(message);
        }
      } else if (response.statusCode == 422) {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Invalid OTP');
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'OTP verification failed');
      }
    } catch (e) {
      _error = 'OTP verification failed: $e';
      if (kDebugMode) print(_error);
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<dynamic> loginWithGoogle(
      Map<String, dynamic> googleData, String phone) async {
    _setLoading(true);
    try {
      if (kDebugMode) print('→ Google login with phone: $phone');

      final response = await _makeApiRequest(
        AppConstants.googleLoginEndpoint,
        'post',
        body: {
          'id_token': googleData['id_token'],
          'access_token': googleData['access_token'],
          'phone': phone.isNotEmpty ? phone : null,
          'email': googleData['email'],
          'name': googleData['name'],
        },
        requiresAuth: false,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Debug log
        if (kDebugMode) {
          print('Google login response: $data');
        }

        // Check success in various ways
        bool success = false;
        if (data is Map<String, dynamic>) {
          if (data.containsKey('success')) {
            final successValue = data['success'];
            success = successValue == true ||
                successValue == 'true' ||
                successValue == 1 ||
                successValue == '1';
          } else if (data.containsKey('status')) {
            final statusValue = data['status'];
            success = statusValue == true ||
                statusValue == 'true' ||
                statusValue == 'success' ||
                statusValue == 200 ||
                statusValue == 1;
          }
        } else if (data is String) {
          success = data.toLowerCase() == 'true' || data == '1';
        } else if (data is int) {
          success = data == 1 || data == 200;
        } else if (data is bool) {
          success = data;
        }

        if (success) {
          UserModel? user;
          String? token;

          if (data is Map<String, dynamic>) {
            // Try different user key possibilities
            if (data.containsKey('user') && data['user'] is Map) {
              try {
                user = UserModel.fromJson(data['user']);
              } catch (e) {
                if (kDebugMode)
                  print('Error parsing user from Google login: $e');
              }
            } else if (data.containsKey('data') && data['data'] is Map) {
              try {
                user = UserModel.fromJson(data['data']);
              } catch (e) {
                if (kDebugMode) print('Error parsing user from data: $e');
              }
            }

            // Try different token key possibilities
            token = data['token'] ?? data['access_token'] ?? data['auth_token'];
          }

          if (token != null) {
            _authToken = token;
            await _saveTokens();
          }

          if (user != null) {
            _user = user;
            await _saveUserData(user);
          }

          _error = null;
          notifyListeners();

          if (kDebugMode) {
            print('Google login/link successful → user: ${user?.id}');
          }

          return {
            'success': true,
            'user': user,
          };
        } else {
          final message = (data is Map<String, dynamic>)
              ? (data['message'] ?? data['error'] ?? 'Google login failed')
              : 'Google login failed';
          throw Exception(message);
        }
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Google login failed');
      }
    } catch (e) {
      _error = 'Google login failed: $e';
      if (kDebugMode) print(_error);
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> linkGoogleAccount(Map<String, dynamic> googleData) async {
    // Reuse the same endpoint — backend handles both cases
    await loginWithGoogle(googleData, _user?.phone ?? '');
  }

  // ── Other Auth Methods ─────────────────────────────────────────────────────
  Future<void> loginUser(UserModel user, {String? token}) async {
    _setLoading(true);
    try {
      _user = user;
      if (token != null) {
        _authToken = token;
        await _saveTokens();
      }
      await _saveUserData(user);
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Login failed: $e';
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    try {
      if (_authToken != null) {
        await _makeApiRequest('${AppConstants.apiBaseUrl}/auth/logout', 'post');
      }

      _user = null;
      _authToken = null;
      _refreshToken = null;
      _cart = CartModel(items: []);
      _favorites.clear();
      _orderHistory.clear();

      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Logout failed: $e';
    } finally {
      _setLoading(false);
    }
  }

  // ── Token Persistence ──────────────────────────────────────────────────────
  Future<void> _loadTokens() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _authToken = prefs.getString(AppConstants.tokenKey);
      _refreshToken = prefs.getString(AppConstants.refreshTokenKey);
    } catch (e) {
      if (kDebugMode) print('Error loading tokens: $e');
    }
  }

  Future<void> _saveTokens() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_authToken != null)
        await prefs.setString(AppConstants.tokenKey, _authToken!);
      if (_refreshToken != null)
        await prefs.setString(AppConstants.refreshTokenKey, _refreshToken!);
    } catch (e) {
      if (kDebugMode) print('Error saving tokens: $e');
    }
  }

  // ── User / Cart / Favorites Persistence ────────────────────────────────────
  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(AppConstants.userKey);
      if (userJson != null) _user = UserModel.fromJson(jsonDecode(userJson));
    } catch (e) {
      if (kDebugMode) print('Error loading user data: $e');
    }
  }

  Future<void> _saveUserData(UserModel user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.userKey, jsonEncode(user.toJson()));
    } catch (e) {
      if (kDebugMode) print('Error saving user data: $e');
    }
  }

  Future<void> _loadCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJson = prefs.getString(AppConstants.cartKey);
      if (cartJson != null) _cart = CartModel.fromJson(jsonDecode(cartJson));
    } catch (e) {
      if (kDebugMode) print('Error loading cart: $e');
    }
  }

  Future<void> _saveCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.cartKey, jsonEncode(_cart.toJson()));
    } catch (e) {
      if (kDebugMode) print('Error saving cart: $e');
    }
  }

  Future<void> _loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString('favorites');
      if (json != null) {
        final list = jsonDecode(json) as List;
        _favorites = list.map((e) => MerchantModel.fromJson(e)).toList();
      }
    } catch (e) {
      if (kDebugMode) print('Error loading favorites: $e');
    }
  }

  Future<void> _saveFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = jsonEncode(_favorites.map((m) => m.toJson()).toList());
      await prefs.setString('favorites', json);
    } catch (e) {
      if (kDebugMode) print('Error saving favorites: $e');
    }
  }

  // ── Preferences / Theme / Location ────────────────────────────────────────
  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Theme
      final themeStr = prefs.getString('theme_mode');
      _themeMode = themeStr == 'dark' ? ThemeMode.dark : ThemeMode.light;

      // Locale
      final lang = prefs.getString('language_code') ?? 'en';
      final country = prefs.getString('country_code') ?? 'US';
      _locale = Locale(lang, country);

      // Location
      final lat = prefs.getString('latitude');
      final lng = prefs.getString('longitude');
      final address = prefs.getString('address');
      if (lat != null && lng != null) {
        _currentLocation = LocationModel(
          latitude: double.tryParse(lat) ?? 0.0,
          longitude: double.tryParse(lng) ?? 0.0,
          address: address ?? 'Kericho, Kenya',
          timestamp: DateTime.now(),
        );
      }
    } catch (e) {
      if (kDebugMode) print('Error loading preferences: $e');
    }
  }

  Future<void> setCurrentLocation(LocationModel location) async {
    _currentLocation = location;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('latitude', location.latitude.toString());
    await prefs.setString('longitude', location.longitude.toString());
    await prefs.setString('address', location.address);
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _themeMode =
        _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'theme_mode', _themeMode == ThemeMode.light ? 'light' : 'dark');
    notifyListeners();
  }

  Future<void> setTheme(ThemeMode mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'theme_mode', mode == ThemeMode.light ? 'light' : 'dark');
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', locale.languageCode);
    await prefs.setString('country_code', locale.countryCode ?? '');
    notifyListeners();
  }

  // ── Cart & Favorites ───────────────────────────────────────────────────────
  Future<void> addToCart(CartItem item) async {
    final index =
        _cart.items.indexWhere((i) => i.product.id == item.product.id);
    if (index >= 0) {
      _cart.items[index] = _cart.items[index].copyWith(
        quantity: _cart.items[index].quantity + item.quantity,
      );
    } else {
      _cart.items.add(item);
    }
    await _saveCart();
    notifyListeners();
  }

  Future<void> updateCartItem(String productId, int quantity) async {
    final index = _cart.items.indexWhere((i) => i.product.id == productId);
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
    _cart.items.removeWhere((i) => i.product.id == productId);
    await _saveCart();
    notifyListeners();
  }

  Future<void> clearCart() async {
    _cart = CartModel(items: []);
    await _saveCart();
    notifyListeners();
  }

  Future<void> toggleFavorite(MerchantModel merchant) async {
    if (_favorites.any((m) => m.id == merchant.id)) {
      _favorites.removeWhere((m) => m.id == merchant.id);
    } else {
      _favorites.add(merchant);
    }
    await _saveFavorites();
    notifyListeners();
  }

  bool isFavorite(String merchantId) =>
      _favorites.any((m) => m.id == merchantId);

  // ── UI State Helpers ───────────────────────────────────────────────────────
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setError(String? error) {
    _error = error;
    if (error != null) {
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

  Future<void> resetApp() async {
    await logout();
    _currentLocation = null;
    _themeMode = ThemeMode.light;
    _locale = const Locale('en', 'US');
    _error = null;
    notifyListeners();
  }
}
