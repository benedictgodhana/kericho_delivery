import 'package:kericho_delivery/data/models/location_model.dart';

class MerchantModel {
  final String id;
  final String name;
  final String description;
  final String? imageUrl;
  final String category;
  final double rating;
  final int ratingCount;
  final String? address;
  final LocationModel? location;
  final bool isOpen;
  final String? openingHours;
  final double deliveryFee;
  final int deliveryTime; // in minutes
  final double minimumOrder;
  final List<String>? tags;
  final bool isFeatured;
  final DateTime createdAt;

  MerchantModel({
    required this.id,
    required this.name,
    required this.description,
    this.imageUrl,
    required this.category,
    this.rating = 0.0,
    this.ratingCount = 0,
    this.address,
    this.location,
    this.isOpen = true,
    this.openingHours,
    this.deliveryFee = 50.0,
    this.deliveryTime = 30,
    this.minimumOrder = 0.0,
    this.tags,
    this.isFeatured = false,
    required this.createdAt,
  });

  factory MerchantModel.fromJson(Map<String, dynamic> json) {
    return MerchantModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      imageUrl: json['imageUrl'],
      category: json['category'],
      rating: json['rating']?.toDouble() ?? 0.0,
      ratingCount: json['ratingCount'] ?? 0,
      address: json['address'],
      location: json['location'] != null
          ? LocationModel.fromJson(json['location'])
          : null,
      isOpen: json['isOpen'] ?? true,
      openingHours: json['openingHours'],
      deliveryFee: json['deliveryFee']?.toDouble() ?? 50.0,
      deliveryTime: json['deliveryTime'] ?? 30,
      minimumOrder: json['minimumOrder']?.toDouble() ?? 0.0,
      tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
      isFeatured: json['isFeatured'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'category': category,
      'rating': rating,
      'ratingCount': ratingCount,
      'address': address,
      'location': location?.toJson(),
      'isOpen': isOpen,
      'openingHours': openingHours,
      'deliveryFee': deliveryFee,
      'deliveryTime': deliveryTime,
      'minimumOrder': minimumOrder,
      'tags': tags,
      'isFeatured': isFeatured,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  MerchantModel copyWith({
    String? id,
    String? name,
    String? description,
    String? imageUrl,
    String? category,
    double? rating,
    int? ratingCount,
    String? address,
    LocationModel? location,
    bool? isOpen,
    String? openingHours,
    double? deliveryFee,
    int? deliveryTime,
    double? minimumOrder,
    List<String>? tags,
    bool? isFeatured,
    DateTime? createdAt,
  }) {
    return MerchantModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      rating: rating ?? this.rating,
      ratingCount: ratingCount ?? this.ratingCount,
      address: address ?? this.address,
      location: location ?? this.location,
      isOpen: isOpen ?? this.isOpen,
      openingHours: openingHours ?? this.openingHours,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      deliveryTime: deliveryTime ?? this.deliveryTime,
      minimumOrder: minimumOrder ?? this.minimumOrder,
      tags: tags ?? this.tags,
      isFeatured: isFeatured ?? this.isFeatured,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}