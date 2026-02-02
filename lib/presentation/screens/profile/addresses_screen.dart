import 'dart:async';
import 'package:flutter/material.dart';
import 'package:kericho_delivery/data/models/location_model.dart';
import 'package:kericho_delivery/presentation/router/app_router.dart';
import 'package:kericho_delivery/presentation/screens/profile/add_edit_address_screen.dart';
import 'package:provider/provider.dart';
import 'package:kericho_delivery/presentation/providers/app_provider.dart';
import 'package:kericho_delivery/presentation/providers/location_provider.dart';
import 'package:kericho_delivery/core/theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';

class AddressesScreen extends StatefulWidget {
  const AddressesScreen({super.key});

  @override
  State<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
  final List<SavedAddress> _addresses = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 500));
      
      // TODO: Load addresses from API/local storage
      final loadedAddresses = [
        SavedAddress(
          id: '1',
          title: 'Home',
          address: '123 Kericho Town, Near Tea Hotel',
          location: LocationModel(
            latitude: -0.3670,
            longitude: 35.2830,
            address: '123 Kericho Town',
            timestamp: DateTime.now(),
          ),
          isDefault: true,
        ),
        SavedAddress(
          id: '2',
          title: 'Work',
          address: 'Tea Research Foundation, Kericho',
          location: LocationModel(
            latitude: -0.3680,
            longitude: 35.2840,
            address: 'Tea Research Foundation',
            timestamp: DateTime.now(),
          ),
          isDefault: false,
        ),
        SavedAddress(
          id: '3',
          title: "Parent's House",
          address: 'Kipkelion Road, Kericho',
          location: LocationModel(
            latitude: -0.3690,
            longitude: 35.2850,
            address: 'Kipkelion Road',
            timestamp: DateTime.now(),
          ),
          isDefault: false,
        ),
      ];

      if (mounted) {
        setState(() {
          _addresses.clear();
          _addresses.addAll(loadedAddresses);
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load addresses: $error';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _addNewAddress() async {
    final locationProvider = Provider.of<LocationProvider>(context, listen: false);
    
    try {
      // Get current location
      await locationProvider.getCurrentLocation();
      
      if (locationProvider.currentLocation != null) {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddEditAddressScreen(
              address: SavedAddress(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                title: 'New Address',
                address: locationProvider.currentLocation!.address,
                location: locationProvider.currentLocation!,
                isDefault: _addresses.isEmpty,
              ),
            ),
          ),
        );

        if (result != null && mounted) {
          setState(() {
            _addresses.add(result as SavedAddress);
          });
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not get current location'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $error'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _editAddress(SavedAddress address) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditAddressScreen(address: address),
      ),
    );

    if (result != null && mounted) {
      final updatedAddress = result as SavedAddress;
      final index = _addresses.indexWhere((a) => a.id == updatedAddress.id);
      if (index != -1) {
        setState(() {
          _addresses[index] = updatedAddress;
        });
      }
    }
  }

  Future<void> _deleteAddress(String addressId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Address'),
          content: const Text('Are you sure you want to delete this address?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      setState(() {
        _addresses.removeWhere((address) => address.id == addressId);
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Address deleted'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _setDefaultAddress(String addressId) {
    setState(() {
      for (final address in _addresses) {
        address.isDefault = address.id == addressId;
      }
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Default address updated'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _selectAddress(SavedAddress address) {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    appProvider.setCurrentLocation(address.location);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Addresses'),
        actions: [
          if (_addresses.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadAddresses,
              tooltip: 'Refresh',
            ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewAddress,
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            Text(
              'Error Loading Addresses',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _errorMessage!,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadAddresses,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Current Location
        _buildCurrentLocation(),
        
        // Addresses List
        Expanded(
          child: _addresses.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadAddresses,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _addresses.length,
                    itemBuilder: (context, index) {
                      final address = _addresses[index];
                      return _buildAddressCard(address);
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildCurrentLocation() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Consumer<LocationProvider>(
        builder: (context, locationProvider, child) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.primaryColor.withOpacity(0.2),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.gps_fixed,
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current Location',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        locationProvider.currentLocation?.address ??
                            'Fetching location...',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () {
                    locationProvider.getCurrentLocation();
                  },
                  tooltip: 'Refresh Location',
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.location_off,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'No saved addresses',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your frequently used addresses',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _addNewAddress,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Add First Address'),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressCard(SavedAddress address) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _getAddressIconColor(address.title),
            shape: BoxShape.circle,
          ),
          child: Icon(
            _getAddressIcon(address.title),
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                address.title,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (address.isDefault)
              Container(
                margin: const EdgeInsets.only(left: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Default',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: Colors.green,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Text(
          address.address,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: AppTheme.textSecondary,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'edit',
              child: ListTile(
                leading: const Icon(Icons.edit, size: 20),
                title: const Text('Edit'),
                dense: true,
              ),
            ),
            PopupMenuItem(
              value: 'set_default',
              child: ListTile(
                leading: const Icon(Icons.check_circle, size: 20),
                title: const Text('Set as Default'),
                dense: true,
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: ListTile(
                leading: const Icon(Icons.delete, size: 20, color: Colors.red),
                title: const Text('Delete', style: TextStyle(color: Colors.red)),
                dense: true,
              ),
            ),
          ],
          onSelected: (value) {
            switch (value) {
              case 'edit':
                _editAddress(address);
                break;
              case 'set_default':
                _setDefaultAddress(address.id);
                break;
              case 'delete':
                _deleteAddress(address.id);
                break;
            }
          },
        ),
        onTap: () => _selectAddress(address),
      ),
    );
  }

  Color _getAddressIconColor(String title) {
    switch (title.toLowerCase()) {
      case 'home':
        return Colors.blue;
      case 'work':
        return Colors.green;
      case 'school':
        return Colors.purple;
      default:
        return AppTheme.primaryColor;
    }
  }

  IconData _getAddressIcon(String title) {
    switch (title.toLowerCase()) {
      case 'home':
        return Icons.home;
      case 'work':
        return Icons.work;
      case 'school':
        return Icons.school;
      default:
        return Icons.location_on;
    }
  }
}

class SavedAddress {
  final String id;
  String title;
  String address;
  LocationModel location;
  bool isDefault;

  SavedAddress({
    required this.id,
    required this.title,
    required this.address,
    required this.location,
    this.isDefault = false,
  });

  // Add copyWith method for easier updates
  SavedAddress copyWith({
    String? id,
    String? title,
    String? address,
    LocationModel? location,
    bool? isDefault,
  }) {
    return SavedAddress(
      id: id ?? this.id,
      title: title ?? this.title,
      address: address ?? this.address,
      location: location ?? this.location,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}