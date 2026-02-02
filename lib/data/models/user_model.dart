class UserModel {
  final String id;
  final String phone;
  final String? email;
  final String fullName;
  final String? profileImage;
  final UserType userType;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isVerified;
  final double? rating;
  final int totalOrders;

  UserModel({
    required this.id,
    required this.phone,
    this.email,
    required this.fullName,
    this.profileImage,
    required this.userType,
    required this.createdAt,
    this.updatedAt,
    this.isVerified = false,
    this.rating,
    this.totalOrders = 0,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      phone: json['phone'],
      email: json['email'],
      fullName: json['fullName'],
      profileImage: json['profileImage'],
      userType: UserType.values.firstWhere(
        (e) => e.toString().split('.').last == json['userType'],
        orElse: () => UserType.customer,
      ),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      isVerified: json['isVerified'] ?? false,
      rating: json['rating']?.toDouble(),
      totalOrders: json['totalOrders'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone': phone,
      'email': email,
      'fullName': fullName,
      'profileImage': profileImage,
      'userType': userType.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isVerified': isVerified,
      'rating': rating,
      'totalOrders': totalOrders,
    };
  }

  UserModel copyWith({
    String? id,
    String? phone,
    String? email,
    String? fullName,
    String? profileImage,
    UserType? userType,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isVerified,
    double? rating,
    int? totalOrders,
  }) {
    return UserModel(
      id: id ?? this.id,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      profileImage: profileImage ?? this.profileImage,
      userType: userType ?? this.userType,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isVerified: isVerified ?? this.isVerified,
      rating: rating ?? this.rating,
      totalOrders: totalOrders ?? this.totalOrders,
    );
  }
}

enum UserType {
  customer,
  rider,
  merchant,
  admin,
}