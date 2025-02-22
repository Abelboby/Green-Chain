import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/waste_pickup.dart';
import '../models/collection_center.dart';

class WasteProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<CollectionCenter> _centers = [];
  List<WastePickup> _pickups = [];
  bool _isLoading = false;
  String? _error;

  List<CollectionCenter> get centers => _centers;
  List<WastePickup> get pickups => _pickups;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Demo data for collection centers
  final List<CollectionCenter> _demoCenters = [
    CollectionCenter(
      id: '1',
      name: 'Green Recycling Center',
      address: 'Kakkanad, Kochi',
      location: const GeoPoint(10.0159, 76.3419), // Kakkanad coordinates
      acceptedWasteTypes: ['Plastic', 'Paper', 'Glass', 'Metal'],
      operatingHours: {
        'weekdays': '9:00 AM - 6:00 PM',
        'weekends': '10:00 AM - 4:00 PM'
      },
      currentCapacity: 60,
      maxCapacity: 100,
      isOpen: true,
      contactNumber: '+91 9876543210',
      email: 'green@recycling.com',
      facilities: {
        'parking': true,
        'weighing': true,
        'sorting': true
      },
      averageWaitTime: 15,
      rating: 4.5,
      totalRatings: 120,
    ),
    CollectionCenter(
      id: '2',
      name: 'EcoWaste Solutions',
      address: 'Edappally, Kochi',
      location: const GeoPoint(10.0247, 76.3079), // Edappally coordinates
      acceptedWasteTypes: ['E-waste', 'Hazardous', 'Metal'],
      operatingHours: {
        'weekdays': '8:00 AM - 5:00 PM',
        'weekends': '9:00 AM - 3:00 PM'
      },
      currentCapacity: 45,
      maxCapacity: 100,
      isOpen: true,
      contactNumber: '+91 9876543211',
      email: 'eco@waste.com',
      facilities: {
        'parking': true,
        'ewaste_processing': true
      },
      averageWaitTime: 25,
      rating: 4.2,
      totalRatings: 85,
    ),
    CollectionCenter(
      id: '3',
      name: 'Organic Waste Center',
      address: 'Kaloor, Kochi',
      location: const GeoPoint(9.9894, 76.2959), // Kaloor coordinates
      acceptedWasteTypes: ['Organic', 'Paper'],
      operatingHours: {
        'weekdays': '7:00 AM - 7:00 PM',
        'weekends': '8:00 AM - 5:00 PM'
      },
      currentCapacity: 30,
      maxCapacity: 100,
      isOpen: true,
      contactNumber: '+91 9876543212',
      email: 'organic@waste.com',
      facilities: {
        'composting': true,
        'biogas': true
      },
      averageWaitTime: 10,
      rating: 4.7,
      totalRatings: 150,
    ),
    CollectionCenter(
      id: '4',
      name: 'City Recyclers',
      address: 'Palarivattom, Kochi',
      location: const GeoPoint(10.0082, 76.3089), // Palarivattom coordinates
      acceptedWasteTypes: ['Plastic', 'Glass', 'Metal', 'Paper'],
      operatingHours: {
        'weekdays': '9:00 AM - 6:00 PM',
        'weekends': '10:00 AM - 4:00 PM'
      },
      currentCapacity: 75,
      maxCapacity: 100,
      isOpen: true,
      contactNumber: '+91 9876543213',
      email: 'city@recyclers.com',
      facilities: {
        'parking': true,
        'sorting': true
      },
      averageWaitTime: 30,
      rating: 4.0,
      totalRatings: 95,
    ),
    CollectionCenter(
      id: '5',
      name: 'E-Waste Hub',
      address: 'Vyttila, Kochi',
      location: const GeoPoint(9.9724, 76.3188), // Vyttila coordinates
      acceptedWasteTypes: ['E-waste', 'Hazardous'],
      operatingHours: {
        'weekdays': '10:00 AM - 7:00 PM',
        'weekends': '11:00 AM - 5:00 PM'
      },
      currentCapacity: 50,
      maxCapacity: 100,
      isOpen: true,
      contactNumber: '+91 9876543214',
      email: 'ewaste@hub.com',
      facilities: {
        'parking': true,
        'ewaste_processing': true,
        'data_destruction': true
      },
      averageWaitTime: 20,
      rating: 4.6,
      totalRatings: 110,
    ),
    CollectionCenter(
      id: '6',
      name: 'Green Earth Recycling',
      address: 'Tripunithura, Kochi',
      location: const GeoPoint(9.9516, 76.3411), // Tripunithura coordinates
      acceptedWasteTypes: ['Plastic', 'Paper', 'Glass', 'Organic'],
      operatingHours: {
        'weekdays': '8:30 AM - 6:30 PM',
        'weekends': '9:00 AM - 4:00 PM'
      },
      currentCapacity: 40,
      maxCapacity: 100,
      isOpen: true,
      contactNumber: '+91 9876543215',
      email: 'green.earth@recycling.com',
      facilities: {
        'parking': true,
        'composting': true
      },
      averageWaitTime: 15,
      rating: 4.4,
      totalRatings: 75,
    ),
    CollectionCenter(
      id: '7',
      name: 'Metro Waste Center',
      address: 'Aluva, Kochi',
      location: const GeoPoint(10.1004, 76.3570), // Aluva coordinates
      acceptedWasteTypes: ['Plastic', 'Metal', 'E-waste', 'Hazardous'],
      operatingHours: {
        'weekdays': '9:00 AM - 8:00 PM',
        'weekends': '10:00 AM - 6:00 PM'
      },
      currentCapacity: 65,
      maxCapacity: 100,
      isOpen: true,
      contactNumber: '+91 9876543216',
      email: 'metro@waste.com',
      facilities: {
        'parking': true,
        'weighing': true
      },
      averageWaitTime: 25,
      rating: 4.3,
      totalRatings: 90,
    ),
    CollectionCenter(
      id: '8',
      name: 'Industrial Recyclers',
      address: 'Kalamassery, Kochi',
      location: const GeoPoint(10.0552, 76.3219), // Kalamassery coordinates
      acceptedWasteTypes: ['Metal', 'E-waste', 'Hazardous'],
      operatingHours: {
        'weekdays': '8:00 AM - 5:00 PM',
        'weekends': 'Closed'
      },
      currentCapacity: 80,
      maxCapacity: 100,
      isOpen: false,
      contactNumber: '+91 9876543217',
      email: 'industrial@recyclers.com',
      facilities: {
        'parking': true,
        'industrial_processing': true
      },
      averageWaitTime: 40,
      rating: 4.1,
      totalRatings: 60,
    ),
  ];

  Future<void> loadCollectionCenters() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Instead of loading from Firestore, use demo data
      _centers = _demoCenters;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load collection centers: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadUserPickups(String userId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final snapshot = await _firestore
          .collection('pickups')
          .where('userId', isEqualTo: userId)
          .orderBy('scheduledDate', descending: true)
          .get();

      _pickups = snapshot.docs
          .map((doc) => WastePickup.fromFirestore(doc))
          .toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load pickups: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String> schedulePickup(WastePickup pickup) async {
    try {
      final doc = await _firestore.collection('pickups').add(pickup.toFirestore());
      return doc.id;
    } catch (e) {
      throw Exception('Failed to schedule pickup: $e');
    }
  }

  Future<void> cancelPickup(String pickupId) async {
    try {
      await _firestore.collection('pickups').doc(pickupId).update({
        'status': PickupStatus.cancelled.toString(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      await loadUserPickups(_pickups.first.userId);
    } catch (e) {
      throw Exception('Failed to cancel pickup: $e');
    }
  }

  Future<void> ratePickup(String pickupId, double rating, String? feedback) async {
    try {
      await _firestore.collection('pickups').doc(pickupId).update({
        'rating': rating,
        'feedback': feedback,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      await loadUserPickups(_pickups.first.userId);
    } catch (e) {
      throw Exception('Failed to rate pickup: $e');
    }
  }

  Stream<List<CollectionCenter>> streamNearbyCenters(GeoPoint userLocation) {
    // Implement geohashing for efficient location queries
    const double radiusInKm = 10.0;
    
    return _firestore
        .collection('collectionCenters')
        .where('isActive', isEqualTo: true)
        // Add GeoFlutterFire queries here
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CollectionCenter.fromFirestore(doc))
            .toList());
  }
} 