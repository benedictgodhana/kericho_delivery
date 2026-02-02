import 'package:kericho_delivery/data/models/product_model.dart';

class CartModel {
  List<CartItem> items;
  String? couponCode;
  double? discountAmount;

  CartModel({
    required this.items,
    this.couponCode,
    this.discountAmount = 0.0,
  });

  factory CartModel.fromJson(Map<String, dynamic> json) {
    return CartModel(
      items: (json['items'] as List)
          .map((item) => CartItem.fromJson(item))
          .toList(),
      couponCode: json['couponCode'],
      discountAmount: json['discountAmount']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((item) => item.toJson()).toList(),
      'couponCode': couponCode,
      'discountAmount': discountAmount,
    };
  }

  CartModel copyWith({
    List<CartItem>? items,
    String? couponCode,
    double? discountAmount,
  }) {
    return CartModel(
      items: items ?? this.items,
      couponCode: couponCode ?? this.couponCode,
      discountAmount: discountAmount ?? this.discountAmount,
    );
  }
}

class CartItem {
  final ProductModel product;
  int quantity;
  final String? specialInstructions;
  final List<String>? selectedOptions;

  CartItem({
    required this.product,
    required this.quantity,
    this.specialInstructions,
    this.selectedOptions,
  });

  double get price => product.price * quantity;

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      product: ProductModel.fromJson(json['product']),
      quantity: json['quantity'],
      specialInstructions: json['specialInstructions'],
      selectedOptions: json['selectedOptions'] != null
          ? List<String>.from(json['selectedOptions'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product': product.toJson(),
      'quantity': quantity,
      'specialInstructions': specialInstructions,
      'selectedOptions': selectedOptions,
    };
  }

  CartItem copyWith({
    ProductModel? product,
    int? quantity,
    String? specialInstructions,
    List<String>? selectedOptions,
  }) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      selectedOptions: selectedOptions ?? this.selectedOptions,
    );
  }
}