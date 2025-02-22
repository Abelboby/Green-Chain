import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event_model.dart';

class EventsProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<CleanUpEvent> _events = [];
  bool _isLoading = false;
  String? _error;

  List<CleanUpEvent> get events => _events;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<CleanUpEvent> get upcomingEvents => 
      _events.where((event) => event.isUpcoming).toList();
  
  List<CleanUpEvent> get ongoingEvents =>
      _events.where((event) => event.isOngoing).toList();

  Future<void> fetchEvents() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final querySnapshot = await _firestore
          .collection('events')
          .orderBy('date', descending: false)
          .get();

      _events = querySnapshot.docs
          .map((doc) => CleanUpEvent.fromFirestore(doc))
          .toList();
    } catch (e) {
      _error = 'Failed to fetch events: $e';
      debugPrint(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<CleanUpEvent?> createEvent(Map<String, dynamic> eventData) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final docRef = await _firestore.collection('events').add({
        ...eventData,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final docSnapshot = await docRef.get();
      final newEvent = CleanUpEvent.fromFirestore(docSnapshot);
      
      _events.add(newEvent);
      _events.sort((a, b) => a.date.compareTo(b.date));
      
      return newEvent;
    } catch (e) {
      _error = 'Failed to create event: $e';
      debugPrint(_error);
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> joinEvent(String eventId, String userId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _firestore.collection('events').doc(eventId).update({
        'volunteerIds': FieldValue.arrayUnion([userId]),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final eventIndex = _events.indexWhere((e) => e.id == eventId);
      if (eventIndex != -1) {
        final event = _events[eventIndex];
        _events[eventIndex] = CleanUpEvent(
          id: event.id,
          title: event.title,
          description: event.description,
          organizerId: event.organizerId,
          organizerName: event.organizerName,
          location: event.location,
          coordinates: event.coordinates,
          date: event.date,
          startTime: event.startTime,
          endTime: event.endTime,
          maxVolunteers: event.maxVolunteers,
          volunteerIds: [...event.volunteerIds, userId],
          equipmentNeeded: event.equipmentNeeded,
          status: event.status,
          createdAt: event.createdAt,
          updatedAt: DateTime.now(),
        );
      }

      return true;
    } catch (e) {
      _error = 'Failed to join event: $e';
      debugPrint(_error);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> leaveEvent(String eventId, String userId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _firestore.collection('events').doc(eventId).update({
        'volunteerIds': FieldValue.arrayRemove([userId]),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final eventIndex = _events.indexWhere((e) => e.id == eventId);
      if (eventIndex != -1) {
        final event = _events[eventIndex];
        _events[eventIndex] = CleanUpEvent(
          id: event.id,
          title: event.title,
          description: event.description,
          organizerId: event.organizerId,
          organizerName: event.organizerName,
          location: event.location,
          coordinates: event.coordinates,
          date: event.date,
          startTime: event.startTime,
          endTime: event.endTime,
          maxVolunteers: event.maxVolunteers,
          volunteerIds: event.volunteerIds.where((id) => id != userId).toList(),
          equipmentNeeded: event.equipmentNeeded,
          status: event.status,
          createdAt: event.createdAt,
          updatedAt: DateTime.now(),
        );
      }

      return true;
    } catch (e) {
      _error = 'Failed to leave event: $e';
      debugPrint(_error);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateEventStatus(String eventId, String status) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _firestore.collection('events').doc(eventId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final eventIndex = _events.indexWhere((e) => e.id == eventId);
      if (eventIndex != -1) {
        final event = _events[eventIndex];
        _events[eventIndex] = CleanUpEvent(
          id: event.id,
          title: event.title,
          description: event.description,
          organizerId: event.organizerId,
          organizerName: event.organizerName,
          location: event.location,
          coordinates: event.coordinates,
          date: event.date,
          startTime: event.startTime,
          endTime: event.endTime,
          maxVolunteers: event.maxVolunteers,
          volunteerIds: event.volunteerIds,
          equipmentNeeded: event.equipmentNeeded,
          status: status,
          createdAt: event.createdAt,
          updatedAt: DateTime.now(),
        );
      }

      return true;
    } catch (e) {
      _error = 'Failed to update event status: $e';
      debugPrint(_error);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
} 