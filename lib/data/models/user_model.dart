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
  final String? googleId;

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
    this.googleId,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Map backend keys to model fields
    return UserModel(
      id: json['id']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      email: json['email']?.toString(),
      fullName: json['fullName'] ?? json['name'] ?? '',
      profileImage: json['profileImage'] ?? json['profile_photo'],
      userType: UserType.values.firstWhere(
        (e) =>
            e.toString().split('.').last ==
            (json['userType'] ?? json['type'] ?? 'customer'),
        orElse: () => UserType.customer,
      ),
      createdAt:
          DateTime.tryParse(json['createdAt'] ?? json['created_at'] ?? '') ??
              DateTime.now(),
      updatedAt: (json['updatedAt'] ?? json['updated_at']) != null
          ? DateTime.tryParse(json['updatedAt'] ?? json['updated_at'])
          : null,
      isVerified: (json['isVerified'] ?? json['is_active']) == true ||
          (json['isVerified'] ?? json['is_active']) == 1,
      rating: json['rating'] != null
          ? double.tryParse(json['rating'].toString())
          : null,
      totalOrders: json['totalOrders'] ?? json['orders_count'] ?? 0,
      googleId: json['googleId'] ?? json['google_id'],
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
      'googleId': googleId,
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
    String? googleId,
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
      googleId: googleId ?? this.googleId,
    );
  }
}

enum UserType {
  customer,
  rider,
  merchant,
  admin,
}
