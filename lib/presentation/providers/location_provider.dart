import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:kericho_delivery/data/models/location_model.dart';

class LocationProvider with ChangeNotifier {
  LocationModel? _currentLocation;
  Position? _position;
  bool _isLoading = false;
  String? _error;
  StreamSubscription<Position>? _positionStream;
  bool _isTracking = false;

  LocationModel? get currentLocation => _currentLocation;
  Position? get position => _position;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isTracking => _isTracking;

  Future<void> getCurrentLocation() async {
    _setLoading(true);
    try {
      // Check permissions
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled.');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied.');
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Get address from coordinates
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      String address = _formatAddress(placemarks);

      _position = position;
      _currentLocation = LocationModel(
        latitude: position.latitude,
        longitude: position.longitude,
        address: address,
        timestamp: DateTime.now(),
        accuracy: position.accuracy,
        altitude: position.altitude,
      );

      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to get location: ${e.toString()}';
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> startLocationTracking() async {
    if (_isTracking) return;

    try {
      _positionStream = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10, // Update every 10 meters
        ),
      ).listen((Position position) {
        _position = position;
        
        // Only update current location if tracking is enabled
        if (_isTracking) {
          _currentLocation = LocationModel(
            latitude: position.latitude,
            longitude: position.longitude,
            address: _currentLocation?.address ?? 'Updating...',
            timestamp: DateTime.now(),
            accuracy: position.accuracy,
            altitude: position.altitude,
          );
          notifyListeners();
        }
      });

      _isTracking = true;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to start location tracking: ${e.toString()}';
    }
  }

  void stopLocationTracking() {
    _positionStream?.cancel();
    _isTracking = false;
    notifyListeners();
  }

  Future<List<LocationModel>> searchLocations(String query) async {
    if (query.isEmpty) return [];

    try {
      List<Location> locations = await locationFromAddress(query);

      return locations.map((location) {
        return LocationModel(
          latitude: location.latitude,
          longitude: location.longitude,
          address: query,
          timestamp: DateTime.now(),
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  Future<String> getAddressFromCoordinates(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      return _formatAddress(placemarks);
    } catch (e) {
      return 'Unknown location';
    }
  }

  String _formatAddress(List<Placemark> placemarks) {
    if (placemarks.isEmpty) return 'Unknown location';

    final place = placemarks.first;
    final parts = [
      place.street,
      place.subLocality,
      place.locality,
      place.subAdministrativeArea,
      place.administrativeArea,
      place.country,
    ];

    return parts.where((part) => part != null && part.isNotEmpty).join(', ');
  }

  // Calculate distance between current location and target
  double? calculateDistanceTo(double targetLat, double targetLng) {
    if (_currentLocation == null) return null;

    return _currentLocation!.distanceTo(
      LocationModel(
        latitude: targetLat,
        longitude: targetLng,
        address: '',
        timestamp: DateTime.now(),
      ),
    );
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    super.dispose();
  }
}