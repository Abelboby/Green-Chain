import 'package:cloud_firestore/cloud_firestore.dart';

class CleanUpEvent {
  final String id;
  final String title;
  final String description;
  final String organizerId;
  final String organizerName;
  final String location;
  final GeoPoint coordinates;
  final DateTime date;
  final DateTime startTime;
  final DateTime endTime;
  final int maxVolunteers;
  final List<String> volunteerIds;
  final List<String> equipmentNeeded;
  final String status; // 'upcoming', 'ongoing', 'completed', 'cancelled'
  final DateTime createdAt;
  final DateTime updatedAt;

  CleanUpEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.organizerId,
    required this.organizerName,
    required this.location,
    required this.coordinates,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.maxVolunteers,
    required this.volunteerIds,
    required this.equipmentNeeded,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CleanUpEvent.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CleanUpEvent(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      organizerId: data['organizerId'] ?? '',
      organizerName: data['organizerName'] ?? '',
      location: data['location'] ?? '',
      coordinates: data['coordinates'] as GeoPoint,
      date: (data['date'] as Timestamp).toDate(),
      startTime: (data['startTime'] as Timestamp).toDate(),
      endTime: (data['endTime'] as Timestamp).toDate(),
      maxVolunteers: data['maxVolunteers'] ?? 0,
      volunteerIds: List<String>.from(data['volunteerIds'] ?? []),
      equipmentNeeded: List<String>.from(data['equipmentNeeded'] ?? []),
      status: data['status'] ?? 'upcoming',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'organizerId': organizerId,
      'organizerName': organizerName,
      'location': location,
      'coordinates': coordinates,
      'date': Timestamp.fromDate(date),
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'maxVolunteers': maxVolunteers,
      'volunteerIds': volunteerIds,
      'equipmentNeeded': equipmentNeeded,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  bool get isUpcoming => date.isAfter(DateTime.now());
  bool get isOngoing => date.day == DateTime.now().day && 
      startTime.isBefore(DateTime.now()) && 
      endTime.isAfter(DateTime.now());
  bool get hasAvailableSpots => volunteerIds.length < maxVolunteers;
  double get volunteerProgress => maxVolunteers > 0 
      ? volunteerIds.length / maxVolunteers 
      : 0.0;
} 