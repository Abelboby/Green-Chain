import 'package:flutter/material.dart' show TimeOfDay;
import 'package:cloud_firestore/cloud_firestore.dart';

enum PickupStatus {
  scheduled,
  confirmed,
  inProgress,
  completed,
  cancelled,
}

enum PickupFrequency {
  oneTime,
  daily,
  weekly,
  biWeekly,
  monthly,
}

class WastePickup {
  final String id;
  final String userId;
  final DateTime scheduledDate;
  final TimeOfDay preferredTime;
  final String address;
  final GeoPoint location;
  final List<String> wasteTypes;
  final double estimatedWeight;
  final String specialInstructions;
  final PickupStatus status;
  final PickupFrequency frequency;
  final String? assignedDriverId;
  final DateTime? completedAt;
  final String? qrCode;
  final double? rating;
  final String? feedback;
  final double? price;
  final bool isPaid;
  final DateTime createdAt;
  final DateTime updatedAt;

  const WastePickup({
    required this.id,
    required this.userId,
    required this.scheduledDate,
    required this.preferredTime,
    required this.address,
    required this.location,
    required this.wasteTypes,
    required this.estimatedWeight,
    required this.specialInstructions,
    required this.status,
    required this.frequency,
    this.assignedDriverId,
    this.completedAt,
    this.qrCode,
    this.rating,
    this.feedback,
    this.price,
    required this.isPaid,
    required this.createdAt,
    required this.updatedAt,
  });

  factory WastePickup.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return WastePickup(
      id: doc.id,
      userId: data['userId'] ?? '',
      scheduledDate: (data['scheduledDate'] as Timestamp).toDate(),
      preferredTime: _timeFromString(data['preferredTime'] ?? '09:00'),
      address: data['address'] ?? '',
      location: data['location'] as GeoPoint,
      wasteTypes: List<String>.from(data['wasteTypes'] ?? []),
      estimatedWeight: (data['estimatedWeight'] ?? 0.0).toDouble(),
      specialInstructions: data['specialInstructions'] ?? '',
      status: PickupStatus.values.firstWhere(
        (e) => e.toString() == data['status'],
        orElse: () => PickupStatus.scheduled,
      ),
      frequency: PickupFrequency.values.firstWhere(
        (e) => e.toString() == data['frequency'],
        orElse: () => PickupFrequency.oneTime,
      ),
      assignedDriverId: data['assignedDriverId'],
      completedAt: data['completedAt']?.toDate(),
      qrCode: data['qrCode'],
      rating: data['rating']?.toDouble(),
      feedback: data['feedback'],
      price: data['price']?.toDouble(),
      isPaid: data['isPaid'] ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'scheduledDate': Timestamp.fromDate(scheduledDate),
      'preferredTime': '${preferredTime.hour}:${preferredTime.minute}',
      'address': address,
      'location': location,
      'wasteTypes': wasteTypes,
      'estimatedWeight': estimatedWeight,
      'specialInstructions': specialInstructions,
      'status': status.toString(),
      'frequency': frequency.toString(),
      'assignedDriverId': assignedDriverId,
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'qrCode': qrCode,
      'rating': rating,
      'feedback': feedback,
      'price': price,
      'isPaid': isPaid,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  static TimeOfDay _timeFromString(String time) {
    final parts = time.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

  bool get isRecurring => frequency != PickupFrequency.oneTime;
  bool get isComplete => status == PickupStatus.completed;
  bool get isCancelled => status == PickupStatus.cancelled;
  bool get canBeCancelled => status == PickupStatus.scheduled || 
                            status == PickupStatus.confirmed;
  bool get canBeRated => isComplete && rating == null;
} 