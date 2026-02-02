class ProductModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final double? discountedPrice;
  final String? imageUrl;
  final String category;
  final String merchantId;
  final bool isAvailable;
  final List<String>? tags;
  final int preparationTime; // in minutes
  final List<ProductOption>? options;
  final List<String>? addons;
  final DateTime createdAt;
  final DateTime? updatedAt;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.discountedPrice,
    this.imageUrl,
    required this.category,
    required this.merchantId,
    this.isAvailable = true,
    this.tags,
    this.preparationTime = 15,
    this.options,
    this.addons,
    required this.createdAt,
    this.updatedAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: json['price'].toDouble(),
      discountedPrice: json['discountedPrice']?.toDouble(),
      imageUrl: json['imageUrl'],
      category: json['category'],
      merchantId: json['merchantId'],
      isAvailable: json['isAvailable'] ?? true,
      tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
      preparationTime: json['preparationTime'] ?? 15,
      options: json['options'] != null
          ? (json['options'] as List)
              .map((option) => ProductOption.fromJson(option))
              .toList()
          : null,
      addons: json['addons'] != null ? List<String>.from(json['addons']) : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'discountedPrice': discountedPrice,
      'imageUrl': imageUrl,
      'category': category,
      'merchantId': merchantId,
      'isAvailable': isAvailable,
      'tags': tags,
      'preparationTime': preparationTime,
      'options': options?.map((option) => option.toJson()).toList(),
      'addons': addons,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  ProductModel copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    double? discountedPrice,
    String? imageUrl,
    String? category,
    String? merchantId,
    bool? isAvailable,
    List<String>? tags,
    int? preparationTime,
    List<ProductOption>? options,
    List<String>? addons,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      discountedPrice: discountedPrice ?? this.discountedPrice,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      merchantId: merchantId ?? this.merchantId,
      isAvailable: isAvailable ?? this.isAvailable,
      tags: tags ?? this.tags,
      preparationTime: preparationTime ?? this.preparationTime,
      options: options ?? this.options,
      addons: addons ?? this.addons,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class ProductOption {
  final String name;
  final List<String> choices;
  final bool isRequired;
  final bool isMultiple;

  ProductOption({
    required this.name,
    required this.choices,
    this.isRequired = false,
    this.isMultiple = false,
  });

  factory ProductOption.fromJson(Map<String, dynamic> json) {
    return ProductOption(
      name: json['name'],
      choices: List<String>.from(json['choices']),
      isRequired: json['isRequired'] ?? false,
      isMultiple: json['isMultiple'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'choices': choices,
      'isRequired': isRequired,
      'isMultiple': isMultiple,
    };
  }
}