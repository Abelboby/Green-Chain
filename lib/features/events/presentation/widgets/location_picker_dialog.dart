import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../core/theme/app_colors.dart';

class LocationPickerDialog extends StatefulWidget {
  final LatLng? initialLocation;
  static String? lastSelectedAddress;

  const LocationPickerDialog({
    super.key,
    this.initialLocation,
  });

  static String? getLastAddress() => lastSelectedAddress;

  @override
  State<LocationPickerDialog> createState() => _LocationPickerDialogState();
}

class _LocationPickerDialogState extends State<LocationPickerDialog> {
  GoogleMapController? _mapController;
  LatLng? _selectedLocation;
  String? _selectedAddress;
  final _searchController = TextEditingController();
  bool _isSearching = false;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _selectedLocation = widget.initialLocation;
    _initializeLocation();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _initializeLocation() async {
    try {
      final locationStatus = await Permission.location.status;
      
      if (locationStatus.isDenied) {
        final result = await Permission.location.request();
        if (!result.isGranted) {
          throw Exception('Location permission denied');
        }
      }

      if (locationStatus.isPermanentlyDenied) {
        throw Exception('Location permission permanently denied');
      }

      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled');
      }

      await _getCurrentLocation();
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      if (mounted) {
        setState(() {
          _selectedLocation = LatLng(position.latitude, position.longitude);
          _isLoading = false;
        });
        
        await _updateCamera(_selectedLocation!);
        await _getAddressFromLatLng(_selectedLocation!);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to get current location: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _updateCamera(LatLng target) async {
    await _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: target,
          zoom: 15,
        ),
      ),
    );
  }

  Future<void> _getAddressFromLatLng(LatLng position) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty && mounted) {
        final place = placemarks.first;
        final address = [
          place.street,
          place.subLocality,
          place.locality,
          place.postalCode,
          place.country,
        ].where((e) => e != null && e.isNotEmpty).join(', ');
        
        setState(() {
          _selectedAddress = address;
          LocationPickerDialog.lastSelectedAddress = address;
        });
      }
    } catch (e) {
      debugPrint('Error getting address: $e');
    }
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_off,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage ?? 'An error occurred',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _errorMessage = null;
                });
                _initializeLocation();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          title: const Text(
            'Select Location',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 24,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            if (_selectedLocation != null)
              TextButton.icon(
                onPressed: () => Navigator.pop(
                  context,
                  _selectedLocation,
                ),
                icon: const Icon(Icons.check),
                label: const Text('Confirm'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primaryGreen,
                ),
              ),
          ],
        ),
        body: Stack(
          children: [
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_errorMessage != null)
              _buildErrorView()
            else
              Column(
                children: [
                  // Search bar
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search location...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _isSearching
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: Center(
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surface,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      onSubmitted: (value) {
                        // TODO: Implement location search
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Location search coming soon!'),
                          ),
                        );
                      },
                    ),
                  ),
                  // Selected location info
                  if (_selectedAddress != null)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.primaryGreen.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: AppColors.primaryGreen,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _selectedAddress!,
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.primaryGreen,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 8),
                  // Map
                  Expanded(
                    child: GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: _selectedLocation ?? const LatLng(0, 0),
                        zoom: 15,
                      ),
                      onMapCreated: (controller) {
                        _mapController = controller;
                      },
                      markers: _selectedLocation != null
                          ? {
                              Marker(
                                markerId: const MarkerId('selected'),
                                position: _selectedLocation!,
                                infoWindow: InfoWindow(
                                  title: 'Selected Location',
                                  snippet: _selectedAddress,
                                ),
                              ),
                            }
                          : {},
                      onTap: (latLng) async {
                        setState(() {
                          _selectedLocation = latLng;
                        });
                        await _getAddressFromLatLng(latLng);
                      },
                      myLocationEnabled: true,
                      myLocationButtonEnabled: false,
                      zoomControlsEnabled: true,
                      mapToolbarEnabled: false,
                    ),
                  ),
                ],
              ),
          ],
        ),
        floatingActionButton: !_isLoading && _errorMessage == null
            ? FloatingActionButton(
                heroTag: 'location_picker_current_location_fab',
                onPressed: _getCurrentLocation,
                backgroundColor: AppColors.primaryGreen,
                child: const Icon(Icons.my_location),
              )
            : null,
      ),
    );
  }
} 