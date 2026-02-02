import 'dart:math';

class LocationModel {
  final double latitude;
  final double longitude;
  final String address;
  final DateTime timestamp;
  final double? accuracy;
  final double? altitude;

  LocationModel({
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.timestamp,
    this.accuracy,
    this.altitude,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      address: json['address'],
      timestamp: DateTime.parse(json['timestamp']),
      accuracy: json['accuracy']?.toDouble(),
      altitude: json['altitude']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'timestamp': timestamp.toIso8601String(),
      'accuracy': accuracy,
      'altitude': altitude,
    };
  }

  LocationModel copyWith({
    double? latitude,
    double? longitude,
    String? address,
    DateTime? timestamp,
    double? accuracy,
    double? altitude,
  }) {
    return LocationModel(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      timestamp: timestamp ?? this.timestamp,
      accuracy: accuracy ?? this.accuracy,
      altitude: altitude ?? this.altitude,
    );
  }

  // Calculate distance between two locations in kilometers
  double distanceTo(LocationModel other) {
    const earthRadius = 6371.0; // Earth's radius in kilometers
    
    final lat1 = latitude * (3.141592653589793 / 180.0);
    final lon1 = longitude * (3.141592653589793 / 180.0);
    final lat2 = other.latitude * (3.141592653589793 / 180.0);
    final lon2 = other.longitude * (3.141592653589793 / 180.0);
    
    final dlat = lat2 - lat1;
    final dlon = lon2 - lon1;
    
    final a = pow(sin(dlat / 2), 2) +
        cos(lat1) * cos(lat2) * pow(sin(dlon / 2), 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    
    return earthRadius * c;
  }

  // Check if location is within radius (in km)
  bool isWithinRadius(LocationModel center, double radiusKm) {
    return distanceTo(center) <= radiusKm;
  }
}