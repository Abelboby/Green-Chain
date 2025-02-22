import 'package:cloud_firestore/cloud_firestore.dart';

class CollectionCenter {
  final String id;
  final String name;
  final String address;
  final GeoPoint location;
  final List<String> acceptedWasteTypes;
  final Map<String, dynamic> operatingHours;
  final int currentCapacity;
  final int maxCapacity;
  final bool isOpen;
  final String contactNumber;
  final String email;
  final Map<String, dynamic> facilities;
  final int averageWaitTime; // in minutes
  final double rating;
  final int totalRatings;

  const CollectionCenter({
    required this.id,
    required this.name,
    required this.address,
    required this.location,
    required this.acceptedWasteTypes,
    required this.operatingHours,
    required this.currentCapacity,
    required this.maxCapacity,
    required this.isOpen,
    required this.contactNumber,
    required this.email,
    required this.facilities,
    required this.averageWaitTime,
    required this.rating,
    required this.totalRatings,
  });

  factory CollectionCenter.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CollectionCenter(
      id: doc.id,
      name: data['name'] ?? '',
      address: data['address'] ?? '',
      location: data['location'] as GeoPoint,
      acceptedWasteTypes: List<String>.from(data['acceptedWasteTypes'] ?? []),
      operatingHours: Map<String, dynamic>.from(data['operatingHours'] ?? {}),
      currentCapacity: data['currentCapacity'] ?? 0,
      maxCapacity: data['maxCapacity'] ?? 100,
      isOpen: data['isOpen'] ?? false,
      contactNumber: data['contactNumber'] ?? '',
      email: data['email'] ?? '',
      facilities: Map<String, dynamic>.from(data['facilities'] ?? {}),
      averageWaitTime: data['averageWaitTime'] ?? 0,
      rating: (data['rating'] ?? 0.0).toDouble(),
      totalRatings: data['totalRatings'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'address': address,
      'location': location,
      'acceptedWasteTypes': acceptedWasteTypes,
      'operatingHours': operatingHours,
      'currentCapacity': currentCapacity,
      'maxCapacity': maxCapacity,
      'isOpen': isOpen,
      'contactNumber': contactNumber,
      'email': email,
      'facilities': facilities,
      'averageWaitTime': averageWaitTime,
      'rating': rating,
      'totalRatings': totalRatings,
    };
  }

  double get capacityPercentage => (currentCapacity / maxCapacity) * 100;

  String get waitTimeText {
    if (averageWaitTime < 1) return 'No wait';
    if (averageWaitTime < 60) return '$averageWaitTime mins';
    return '${(averageWaitTime / 60).round()} hours';
  }

  bool get isAtCapacity => currentCapacity >= maxCapacity;
} 