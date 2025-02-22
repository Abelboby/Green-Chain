import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../providers/waste_provider.dart';
import '../../models/index.dart';
import 'dart:math' show min, max;

class CollectionCentersScreen extends StatefulWidget {
  const CollectionCentersScreen({Key? key}) : super(key: key);

  @override
  State<CollectionCentersScreen> createState() => _CollectionCentersScreenState();
}

class _CollectionCentersScreenState extends State<CollectionCentersScreen> {
  bool _showMap = true;
  String? _selectedWasteType;
  final Set<Marker> _markers = {};
  GoogleMapController? _mapController;
  Position? _currentPosition;
  bool _isLoading = true;

  final List<String> wasteTypes = [
    'All',
    'Plastic',
    'Paper',
    'Glass',
    'Metal',
    'E-waste',
    'Organic',
    'Hazardous',
  ];

  @override
  void initState() {
    super.initState();
    _initializeScreen();
  }

  Future<void> _initializeScreen() async {
    await _getCurrentLocation();
    await _loadCenters();
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please enable location services')),
          );
        }
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }

      if (permission == LocationPermission.deniedForever) return;

      final position = await Geolocator.getCurrentPosition();
      if (mounted) {
        setState(() => _currentPosition = position);
      }
    } catch (e) {
      debugPrint('Error getting location: $e');
    }
  }

  Future<void> _loadCenters() async {
    try {
      final wasteProvider = Provider.of<WasteProvider>(context, listen: false);
      await wasteProvider.loadCollectionCenters();
      _createMarkers();
    } catch (e) {
      debugPrint('Error loading centers: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading centers: $e')),
        );
      }
    }
  }

  void _createMarkers() {
    final centers = Provider.of<WasteProvider>(context, listen: false).centers;
    
    _markers.clear();

    // Add current location marker
    if (_currentPosition != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId('current_location'),
          position: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          infoWindow: const InfoWindow(
            title: 'Your Location',
            snippet: 'You are here',
          ),
        ),
      );
    }
    
    // Add center markers
    for (var center in centers) {
      if (_selectedWasteType == null || 
          _selectedWasteType == 'All' ||
          center.acceptedWasteTypes.contains(_selectedWasteType)) {
        _markers.add(
          Marker(
            markerId: MarkerId(center.id),
            position: LatLng(
              center.location.latitude,
              center.location.longitude,
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
            infoWindow: InfoWindow(
              title: center.name,
              snippet: '${center.isOpen ? 'Open' : 'Closed'} • ${center.capacityPercentage.round()}% full',
            ),
            onTap: () => _showCenterDetails(center),
          ),
        );
      }
    }
    
    if (mounted) setState(() {});
    _fitBounds();
  }

  void _fitBounds() {
    if (_mapController == null || _markers.isEmpty) return;

    double minLat = 90.0;
    double maxLat = -90.0;
    double minLng = 180.0;
    double maxLng = -180.0;

    for (final marker in _markers) {
      final lat = marker.position.latitude;
      final lng = marker.position.longitude;
      
      minLat = min(minLat, lat);
      maxLat = max(maxLat, lat);
      minLng = min(minLng, lng);
      maxLng = max(maxLng, lng);
    }

    // Add padding
    final padding = 0.1;
    final bounds = LatLngBounds(
      southwest: LatLng(minLat - padding, minLng - padding),
      northeast: LatLng(maxLat + padding, maxLng + padding),
    );

    _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 50),
    );
  }

  void _showCenterDetails(CollectionCenter center) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.4,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  height: 4,
                  width: 40,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                center.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: center.isOpen ? Colors.green : Colors.red,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      center.isOpen ? 'Open' : 'Closed',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('${center.capacityPercentage.round()}% full'),
                  const SizedBox(width: 8),
                  Text(center.waitTimeText),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Accepted Waste Types',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: center.acceptedWasteTypes.map((type) => Chip(
                  label: Text(type),
                  backgroundColor: AppColors.primaryGreen.withOpacity(0.1),
                )).toList(),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.location_on),
                title: Text(center.address),
                subtitle: const Text('Tap to navigate'),
                onTap: () {
                  // TODO: Implement navigation
                },
              ),
              ListTile(
                leading: const Icon(Icons.phone),
                title: Text(center.contactNumber),
                onTap: () {
                  // TODO: Implement call
                },
              ),
              ListTile(
                leading: const Icon(Icons.email),
                title: Text(center.email),
                onTap: () {
                  // TODO: Implement email
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final wasteProvider = Provider.of<WasteProvider>(context);
    final centers = wasteProvider.centers;

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Collection Centers'),
        actions: [
          IconButton(
            icon: Icon(_showMap ? Icons.list : Icons.map),
            onPressed: () => setState(() => _showMap = !_showMap),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            scrollDirection: Axis.horizontal,
            child: Row(
              children: wasteTypes.map((type) {
                final isSelected = _selectedWasteType == type;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(type),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedWasteType = selected ? type : null;
                        _createMarkers();
                      });
                    },
                    selectedColor: AppColors.primaryGreen.withOpacity(0.2),
                    checkmarkColor: AppColors.primaryGreen,
                  ),
                );
              }).toList(),
            ),
          ),

          // Map or List view
          Expanded(
            child: _showMap
                ? GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: _currentPosition != null
                          ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
                          : const LatLng(0, 0),
                      zoom: 12,
                    ),
                    markers: _markers,
                    onMapCreated: (controller) {
                      _mapController = controller;
                      _fitBounds();
                    },
                    myLocationEnabled: true,
                    myLocationButtonEnabled: true,
                    zoomControlsEnabled: true,
                    mapToolbarEnabled: true,
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: centers.length,
                    itemBuilder: (context, index) {
                      final center = centers[index];
                      if (_selectedWasteType != null &&
                          _selectedWasteType != 'All' &&
                          !center.acceptedWasteTypes.contains(_selectedWasteType)) {
                        return const SizedBox.shrink();
                      }
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: ListTile(
                          title: Text(center.name),
                          subtitle: Text(center.address),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                center.isOpen ? 'Open' : 'Closed',
                                style: TextStyle(
                                  color: center.isOpen ? Colors.green : Colors.red,
                                ),
                              ),
                              Text('${center.capacityPercentage.round()}% full'),
                            ],
                          ),
                          onTap: () => _showCenterDetails(center),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
} 