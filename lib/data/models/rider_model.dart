import 'package:kericho_delivery/data/models/location_model.dart';

class RiderModel {
  final String id;
  final String name;
  final String phone;
  final String vehicleType; // Motorcycle, Bicycle, Car
  final String vehiclePlate;
  final double rating;
  final int totalDeliveries;
  final bool isAvailable;
  final LocationModel? currentLocation;
  final DateTime? lastActive;
  final String? profileImage;
  final List<String>? languages;

  RiderModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.vehicleType,
    required this.vehiclePlate,
    this.rating = 0.0,
    this.totalDeliveries = 0,
    this.isAvailable = true,
    this.currentLocation,
    this.lastActive,
    this.profileImage,
    this.languages,
  });

  factory RiderModel.fromJson(Map<String, dynamic> json) {
    return RiderModel(
      id: json['id'],
      name: json['name'],
      phone: json['phone'],
      vehicleType: json['vehicleType'],
      vehiclePlate: json['vehiclePlate'],
      rating: json['rating']?.toDouble() ?? 0.0,
      totalDeliveries: json['totalDeliveries'] ?? 0,
      isAvailable: json['isAvailable'] ?? true,
      currentLocation: json['currentLocation'] != null
          ? LocationModel.fromJson(json['currentLocation'])
          : null,
      lastActive: json['lastActive'] != null
          ? DateTime.parse(json['lastActive'])
          : null,
      profileImage: json['profileImage'],
      languages: json['languages'] != null
          ? List<String>.from(json['languages'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'vehicleType': vehicleType,
      'vehiclePlate': vehiclePlate,
      'rating': rating,
      'totalDeliveries': totalDeliveries,
      'isAvailable': isAvailable,
      'currentLocation': currentLocation?.toJson(),
      'lastActive': lastActive?.toIso8601String(),
      'profileImage': profileImage,
      'languages': languages,
    };
  }

  RiderModel copyWith({
    String? id,
    String? name,
    String? phone,
    String? vehicleType,
    String? vehiclePlate,
    double? rating,
    int? totalDeliveries,
    bool? isAvailable,
    LocationModel? currentLocation,
    DateTime? lastActive,
    String? profileImage,
    List<String>? languages,
  }) {
    return RiderModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      vehicleType: vehicleType ?? this.vehicleType,
      vehiclePlate: vehiclePlate ?? this.vehiclePlate,
      rating: rating ?? this.rating,
      totalDeliveries: totalDeliveries ?? this.totalDeliveries,
      isAvailable: isAvailable ?? this.isAvailable,
      currentLocation: currentLocation ?? this.currentLocation,
      lastActive: lastActive ?? this.lastActive,
      profileImage: profileImage ?? this.profileImage,
      languages: languages ?? this.languages,
    );
  }

  String get formattedPhone {
    if (phone.startsWith('254')) {
      return '+$phone';
    } else if (phone.startsWith('0')) {
      return '+254${phone.substring(1)}';
    }
    return phone;
  }

  String get statusText {
    if (!isAvailable) return 'Offline';
    if (currentLocation == null) return 'Available';
    return 'On Delivery';
  }
}