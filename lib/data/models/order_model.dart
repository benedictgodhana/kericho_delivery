import 'package:kericho_delivery/data/models/cart_model.dart';
import 'package:kericho_delivery/data/models/location_model.dart';

class OrderModel {
  final String id;
  final String orderNumber;
  final String customerId;
  final String merchantId;
  final String? riderId;
  final List<CartItem> items;
  final double subtotal;
  final double deliveryFee;
  final double? discountAmount;
  final double totalAmount;
  final OrderStatus status;
  final String deliveryAddress;
  final LocationModel deliveryLocation;
  final PaymentMethod paymentMethod;
  final PaymentStatus paymentStatus;
  final String? mpesaReceipt;
  final String? specialInstructions;
  final DateTime createdAt;
  final DateTime? acceptedAt;
  final DateTime? preparedAt;
  final DateTime? pickedUpAt;
  final DateTime? deliveredAt;
  final String? riderNotes;
  final int? rating;
  final String? review;

  OrderModel({
    required this.id,
    required this.orderNumber,
    required this.customerId,
    required this.merchantId,
    this.riderId,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    this.discountAmount = 0.0,
    required this.totalAmount,
    required this.status,
    required this.deliveryAddress,
    required this.deliveryLocation,
    required this.paymentMethod,
    required this.paymentStatus,
    this.mpesaReceipt,
    this.specialInstructions,
    required this.createdAt,
    this.acceptedAt,
    this.preparedAt,
    this.pickedUpAt,
    this.deliveredAt,
    this.riderNotes,
    this.rating,
    this.review,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'],
      orderNumber: json['orderNumber'],
      customerId: json['customerId'],
      merchantId: json['merchantId'],
      riderId: json['riderId'],
      items: (json['items'] as List)
          .map((item) => CartItem.fromJson(item))
          .toList(),
      subtotal: json['subtotal'].toDouble(),
      deliveryFee: json['deliveryFee'].toDouble(),
      discountAmount: json['discountAmount']?.toDouble() ?? 0.0,
      totalAmount: json['totalAmount'].toDouble(),
      status: OrderStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => OrderStatus.pending,
      ),
      deliveryAddress: json['deliveryAddress'],
      deliveryLocation: LocationModel.fromJson(json['deliveryLocation']),
      paymentMethod: PaymentMethod.values.firstWhere(
        (e) => e.toString().split('.').last == json['paymentMethod'],
        orElse: () => PaymentMethod.mpesa,
      ),
      paymentStatus: PaymentStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['paymentStatus'],
        orElse: () => PaymentStatus.pending,
      ),
      mpesaReceipt: json['mpesaReceipt'],
      specialInstructions: json['specialInstructions'],
      createdAt: DateTime.parse(json['createdAt']),
      acceptedAt: json['acceptedAt'] != null ? DateTime.parse(json['acceptedAt']) : null,
      preparedAt: json['preparedAt'] != null ? DateTime.parse(json['preparedAt']) : null,
      pickedUpAt: json['pickedUpAt'] != null ? DateTime.parse(json['pickedUpAt']) : null,
      deliveredAt: json['deliveredAt'] != null ? DateTime.parse(json['deliveredAt']) : null,
      riderNotes: json['riderNotes'],
      rating: json['rating'],
      review: json['review'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderNumber': orderNumber,
      'customerId': customerId,
      'merchantId': merchantId,
      'riderId': riderId,
      'items': items.map((item) => item.toJson()).toList(),
      'subtotal': subtotal,
      'deliveryFee': deliveryFee,
      'discountAmount': discountAmount,
      'totalAmount': totalAmount,
      'status': status.toString().split('.').last,
      'deliveryAddress': deliveryAddress,
      'deliveryLocation': deliveryLocation.toJson(),
      'paymentMethod': paymentMethod.toString().split('.').last,
      'paymentStatus': paymentStatus.toString().split('.').last,
      'mpesaReceipt': mpesaReceipt,
      'specialInstructions': specialInstructions,
      'createdAt': createdAt.toIso8601String(),
      'acceptedAt': acceptedAt?.toIso8601String(),
      'preparedAt': preparedAt?.toIso8601String(),
      'pickedUpAt': pickedUpAt?.toIso8601String(),
      'deliveredAt': deliveredAt?.toIso8601String(),
      'riderNotes': riderNotes,
      'rating': rating,
      'review': review,
    };
  }

  OrderModel copyWith({
    String? id,
    String? orderNumber,
    String? customerId,
    String? merchantId,
    String? riderId,
    List<CartItem>? items,
    double? subtotal,
    double? deliveryFee,
    double? discountAmount,
    double? totalAmount,
    OrderStatus? status,
    String? deliveryAddress,
    LocationModel? deliveryLocation,
    PaymentMethod? paymentMethod,
    PaymentStatus? paymentStatus,
    String? mpesaReceipt,
    String? specialInstructions,
    DateTime? createdAt,
    DateTime? acceptedAt,
    DateTime? preparedAt,
    DateTime? pickedUpAt,
    DateTime? deliveredAt,
    String? riderNotes,
    int? rating,
    String? review,
  }) {
    return OrderModel(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      customerId: customerId ?? this.customerId,
      merchantId: merchantId ?? this.merchantId,
      riderId: riderId ?? this.riderId,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      discountAmount: discountAmount ?? this.discountAmount,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      deliveryLocation: deliveryLocation ?? this.deliveryLocation,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      mpesaReceipt: mpesaReceipt ?? this.mpesaReceipt,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      createdAt: createdAt ?? this.createdAt,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      preparedAt: preparedAt ?? this.preparedAt,
      pickedUpAt: pickedUpAt ?? this.pickedUpAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      riderNotes: riderNotes ?? this.riderNotes,
      rating: rating ?? this.rating,
      review: review ?? this.review,
    );
  }
}

enum OrderStatus {
  pending,
  accepted,
  preparing,
  ready,
  pickedUp,
  delivered,
  cancelled,
}

enum PaymentMethod {
  mpesa,
  cash,
  card,
}

enum PaymentStatus {
  pending,
  completed,
  failed,
  refunded,
}