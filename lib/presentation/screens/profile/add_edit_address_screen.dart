import 'package:flutter/material.dart';
import 'package:kericho_delivery/presentation/screens/profile/addresses_screen.dart';
import 'package:provider/provider.dart';
import 'package:kericho_delivery/presentation/providers/location_provider.dart';
import 'package:kericho_delivery/core/theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';

class AddEditAddressScreen extends StatefulWidget {
  final SavedAddress? address;

  const AddEditAddressScreen({super.key, this.address});

  @override
  State<AddEditAddressScreen> createState() => _AddEditAddressScreenState();
}

class _AddEditAddressScreenState extends State<AddEditAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  
  bool _isLoading = false;
  bool _isDefault = false;
  String? _selectedAddressType;

  // Custom validators
  String? _requiredValidator(String? value, {String fieldName = 'This field'}) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    if (widget.address != null) {
      _titleController.text = widget.address!.title;
      _addressController.text = widget.address!.address;
      _isDefault = widget.address!.isDefault;
      _selectedAddressType = widget.address!.title;
    } else {
      _loadCurrentLocation();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _loadCurrentLocation() async {
    final locationProvider = Provider.of<LocationProvider>(context, listen: false);
    await locationProvider.getCurrentLocation();
    if (locationProvider.currentLocation != null) {
      _addressController.text = locationProvider.currentLocation!.address;
    }
  }

  void _selectOnMap() {
    // TODO: Open map to select location
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Map selection not implemented yet')),
    );
  }

  void _saveAddress() {
    if (_formKey.currentState!.validate()) {
      final locationProvider = Provider.of<LocationProvider>(context, listen: false);

      if (locationProvider.currentLocation == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a location')),
        );
        return;
      }

      if (_addressController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter an address')),
        );
        return;
      }

      final savedAddress = SavedAddress(
        id: widget.address?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text.isNotEmpty 
            ? _titleController.text 
            : _selectedAddressType ?? 'Other',
        address: _addressController.text,
        location: locationProvider.currentLocation!,
        isDefault: _isDefault,
      );

      Navigator.pop(context, savedAddress);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.address == null ? 'Add Address' : 'Edit Address'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveAddress,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: 'Address Title',
                      hintText: 'e.g., Home, Work, Office',
                      prefixIcon: const Icon(Icons.title),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) => _requiredValidator(value, fieldName: 'Title'),
                  ),

                  const SizedBox(height: 20),

                  // Address
                  TextFormField(
                    controller: _addressController,
                    decoration: InputDecoration(
                      labelText: 'Address',
                      hintText: 'Enter your address',
                      prefixIcon: const Icon(Icons.location_on),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.map),
                        onPressed: _selectOnMap,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    maxLines: 3,
                  ),

                  const SizedBox(height: 16),

                  // Current Location Info
                  Consumer<LocationProvider>(
                    builder: (context, locationProvider, child) {
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[200] ?? Colors.grey),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.gps_fixed,
                              color: AppTheme.primaryColor,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Using current location',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    locationProvider.currentLocation?.address ??
                                        'Location not available',
                                    style: GoogleFonts.poppins(
                                      fontSize: 10,
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
                              iconSize: 20,
                              onPressed: _loadCurrentLocation,
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  // Address Type
                  Text(
                    'Address Type',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    children: [
                      _buildAddressTypeChip('Home', Icons.home),
                      _buildAddressTypeChip('Work', Icons.work),
                      _buildAddressTypeChip('Other', Icons.location_on),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Set as Default
                  SwitchListTile(
                    title: Text(
                      'Set as default address',
                      style: GoogleFonts.poppins(),
                    ),
                    subtitle: Text(
                      'Use this address for deliveries by default',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    value: _isDefault,
                    onChanged: (value) {
                      setState(() => _isDefault = value);
                    },
                    contentPadding: EdgeInsets.zero,
                  ),

                  const SizedBox(height: 32),

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveAddress,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Save Address'),
                    ),
                  ),
                ],
              ),

              // Additional Info
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.teaGreen.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info,
                          color: AppTheme.kerichoGreen,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Delivery Tips',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.kerichoGreen,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• Include landmarks for easier delivery\n'
                      '• Add gate/floor numbers if applicable\n'
                      '• Specify "leave at door" if preferred',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: AppTheme.kerichoGreen,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddressTypeChip(String type, IconData icon) {
    return ChoiceChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 6),
          Text(type),
        ],
      ),
      selected: _selectedAddressType == type,
      onSelected: (selected) {
        setState(() {
          if (selected) {
            _selectedAddressType = type;
            _titleController.text = type;
          }
        });
      },
    );
  }
}