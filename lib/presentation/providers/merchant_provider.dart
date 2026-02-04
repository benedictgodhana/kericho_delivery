import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:kericho_delivery/data/models/merchant_model.dart';
import 'package:kericho_delivery/data/models/product_model.dart';

class MerchantProvider with ChangeNotifier {
  List<MerchantModel> _merchants = [];
  List<MerchantModel> _filteredMerchants = [];
  MerchantModel? _selectedMerchant;
  List<ProductModel> _merchantProducts = [];
  List<String> _categories = [];
  String _selectedCategory = 'All';
  String _searchQuery = '';
  bool _isLoading = false;
  String? _error;

  // Getters
  List<MerchantModel> get merchants => _filteredMerchants;
  MerchantModel? get selectedMerchant => _selectedMerchant;
  List<ProductModel> get merchantProducts => _merchantProducts;
  List<String> get categories => _categories;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Mock data for testing (replace with API calls)
  final List<MerchantModel> _mockMerchants = [
    MerchantModel(
      id: '1',
      name: 'Green Gardens Restaurant',
      description: 'Fresh local cuisine and traditional dishes',
      category: 'Restaurant',
      rating: 4.5,
      ratingCount: 120,
      address: 'Kericho Town Center',
      isOpen: true,
      deliveryFee: 50.0,
      deliveryTime: 25,
      minimumOrder: 200.0,
      tags: ['Traditional', 'Local', 'Affordable'],
      isFeatured: true,
      imageUrl: 'assets/images/green.jpg',
      createdAt: DateTime.now(),
    ),
    MerchantModel(
      id: '2',
      name: 'Kericho Fresh Mart',
      description: 'Fresh groceries and household items',
      category: 'Grocery',
      rating: 4.2,
      ratingCount: 85,
      address: 'Kipchebor Market',
      isOpen: true,
      deliveryFee: 40.0,
      deliveryTime: 20,
      minimumOrder: 150.0,
      tags: ['Groceries', 'Fresh', 'Market'],
      isFeatured: false,
      imageUrl: 'assets/images/fresh_mart.jpg',
      createdAt: DateTime.now(),
    ),
    MerchantModel(
      id: '3',
      name: 'MediCare Pharmacy',
      description: '24/7 pharmacy and healthcare products',
      category: 'Pharmacy',
      rating: 4.7,
      ratingCount: 65,
      address: 'Hospital Road',
      isOpen: true,
      deliveryFee: 60.0,
      deliveryTime: 15,
      minimumOrder: 100.0,
      tags: ['Medicine', 'Healthcare', '24/7'],
      isFeatured: true,
      imageUrl: 'assets/images/pharmacy.jpg',
      createdAt: DateTime.now(),
    ),
  ];

  MerchantProvider() {
    // Initialize with mock data
    _initializeData();
  }

  Future<void> _initializeData() async {
    _setLoading(true);
    try {
      // Simulate API delay
      await Future.delayed(const Duration(seconds: 1));

      _merchants = _mockMerchants;
      _filteredMerchants = _merchants;
      _categories = ['All', 'Restaurant', 'Grocery', 'Pharmacy', 'Electronics'];

      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load merchants: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadMerchants() async {
    _setLoading(true);
    try {
      // TODO: Replace with actual API call
      await Future.delayed(const Duration(seconds: 1));
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load merchants: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> selectMerchant(String merchantId) async {
    _setLoading(true);
    try {
      // TODO: Replace with actual API call
      await Future.delayed(const Duration(milliseconds: 500));

      _selectedMerchant = _merchants.firstWhere(
        (merchant) => merchant.id == merchantId,
        orElse: () => _mockMerchants.first,
      );

      // Load merchant products
      _merchantProducts = _getMockProducts(merchantId);

      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load merchant: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }

  void filterByCategory(String category) {
    _selectedCategory = category;

    if (category == 'All') {
      _filteredMerchants = _merchants;
    } else {
      _filteredMerchants = _merchants
          .where(
            (merchant) => merchant.category == category,
          )
          .toList();
    }

    _applySearchFilter();
    notifyListeners();
  }

  void searchMerchants(String query) {
    _searchQuery = query;
    _applySearchFilter();
    notifyListeners();
  }

  void _applySearchFilter() {
    if (_searchQuery.isEmpty) {
      if (_selectedCategory == 'All') {
        _filteredMerchants = _merchants;
      } else {
        _filteredMerchants = _merchants
            .where(
              (merchant) => merchant.category == _selectedCategory,
            )
            .toList();
      }
    } else {
      _filteredMerchants = _merchants.where((merchant) {
        final matchesCategory = _selectedCategory == 'All' ||
            merchant.category == _selectedCategory;
        final matchesSearch = merchant.name.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
            merchant.description.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
            (merchant.tags?.any((tag) => tag.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    )) ??
                false);

        return matchesCategory && matchesSearch;
      }).toList();
    }
  }

  List<MerchantModel> getFeaturedMerchants() {
    return _merchants.where((merchant) => merchant.isFeatured).toList();
  }

  List<MerchantModel> getNearbyMerchants(double lat, double lng) {
    // For now, return all merchants
    // Later implement actual distance calculation
    return _merchants;
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Mock products data
  List<ProductModel> _getMockProducts(String merchantId) {
    if (merchantId == '1') {
      return [
        ProductModel(
          id: '101',
          name: 'Chicken Pilau',
          description: 'Spiced rice with tender chicken pieces',
          price: 350.0,
          category: 'Main Course',
          merchantId: merchantId,
          preparationTime: 20,
          createdAt: DateTime.now(),
        ),
        ProductModel(
          id: '102',
          name: 'Ugali & Fish',
          description: 'Traditional maize meal with fried fish',
          price: 300.0,
          category: 'Main Course',
          merchantId: merchantId,
          preparationTime: 15,
          createdAt: DateTime.now(),
        ),
      ];
    } else if (merchantId == '2') {
      return [
        ProductModel(
          id: '201',
          name: 'Fresh Milk (1L)',
          description: 'Fresh dairy milk',
          price: 120.0,
          category: 'Dairy',
          merchantId: merchantId,
          preparationTime: 5,
          createdAt: DateTime.now(),
        ),
      ];
    } else {
      return [
        ProductModel(
          id: '301',
          name: 'Painkillers',
          description: 'Paracetamol tablets',
          price: 50.0,
          category: 'Medicine',
          merchantId: merchantId,
          preparationTime: 5,
          createdAt: DateTime.now(),
        ),
      ];
    }
  }

  void clearCategory() {}
}
