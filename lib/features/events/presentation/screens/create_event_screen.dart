import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../providers/events_provider.dart';
import '../widgets/location_picker_dialog.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({Key? key}) : super(key: key);

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _maxVolunteersController = TextEditingController();
  final _equipmentController = TextEditingController();
  final List<String> _equipmentNeeded = [];
  
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 12, minute: 0);
  GeoPoint _coordinates = const GeoPoint(0, 0);
  bool _isLoading = false;

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStartTime ? _startTime : _endTime,
    );
    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  void _addEquipment() {
    final equipment = _equipmentController.text.trim();
    if (equipment.isNotEmpty) {
      setState(() {
        _equipmentNeeded.add(equipment);
        _equipmentController.clear();
      });
    }
  }

  void _removeEquipment(int index) {
    setState(() {
      _equipmentNeeded.removeAt(index);
    });
  }

  Future<void> _createEvent() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authProvider = context.read<AuthProvider>();
      final user = authProvider.user;
      if (user == null) throw Exception('User not logged in');

      final startDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _startTime.hour,
        _startTime.minute,
      );

      final endDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _endTime.hour,
        _endTime.minute,
      );

      final eventData = {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'organizerId': user.uid,
        'organizerName': user.displayName ?? 'Anonymous',
        'location': _locationController.text.trim(),
        'coordinates': _coordinates,
        'date': Timestamp.fromDate(_selectedDate),
        'startTime': Timestamp.fromDate(startDateTime),
        'endTime': Timestamp.fromDate(endDateTime),
        'maxVolunteers': int.parse(_maxVolunteersController.text.trim()),
        'volunteerIds': [],
        'equipmentNeeded': _equipmentNeeded,
        'status': 'upcoming',
      };

      final eventsProvider = context.read<EventsProvider>();
      final event = await eventsProvider.createEvent(eventData);

      if (mounted && event != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Event created successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating event: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _pickLocation() async {
    final LatLng? initialLocation = _coordinates.latitude != 0 && _coordinates.longitude != 0
        ? LatLng(_coordinates.latitude, _coordinates.longitude)
        : null;

    final LatLng? result = await showDialog<LatLng>(
      context: context,
      builder: (context) => LocationPickerDialog(
        initialLocation: initialLocation,
      ),
    );

    if (result != null) {
      setState(() {
        _coordinates = GeoPoint(result.latitude, result.longitude);
      });
      
      try {
        final placemarks = await placemarkFromCoordinates(
          result.latitude,
          result.longitude,
        );
        
        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          final address = [
            place.street,
            place.subLocality,
            place.locality,
            place.postalCode,
            place.country,
          ].where((e) => e != null && e.isNotEmpty).join(', ');
          
          setState(() {
            _locationController.text = address;
          });
        } else {
          setState(() {
            _locationController.text = 'Location selected (${result.latitude.toStringAsFixed(6)}, ${result.longitude.toStringAsFixed(6)})';
          });
        }
      } catch (e) {
        setState(() {
          _locationController.text = 'Location selected (${result.latitude.toStringAsFixed(6)}, ${result.longitude.toStringAsFixed(6)})';
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not fetch address for selected location'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _maxVolunteersController.dispose();
    _equipmentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text(
          'Create Event',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 28,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Basic Information
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.background,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Basic Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Event Title',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.title),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter an event title';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.description),
                          hintText: 'Describe the clean-up event',
                        ),
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a description';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Date and Time
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.background,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Date and Time',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ListTile(
                        leading: const Icon(Icons.calendar_today),
                        title: const Text('Date'),
                        subtitle: Text(
                          DateFormat('EEE, MMM d, y').format(_selectedDate),
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: _selectDate,
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.access_time),
                        title: const Text('Start Time'),
                        subtitle: Text(_startTime.format(context)),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _selectTime(true),
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.access_time),
                        title: const Text('End Time'),
                        subtitle: Text(_endTime.format(context)),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _selectTime(false),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Location
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.background,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Location',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _locationController,
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: 'Location',
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.location_on),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.map),
                            onPressed: _pickLocation,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please select a location';
                          }
                          return null;
                        },
                        onTap: _pickLocation,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Volunteers and Equipment
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.background,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Volunteers and Equipment',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _maxVolunteersController,
                        decoration: const InputDecoration(
                          labelText: 'Maximum Volunteers',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.group),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter maximum volunteers';
                          }
                          if (int.tryParse(value) == null || int.parse(value) <= 0) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _equipmentController,
                              decoration: const InputDecoration(
                                labelText: 'Add Equipment',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.build),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: _addEquipment,
                            icon: const Icon(Icons.add),
                            color: AppColors.primaryGreen,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: _equipmentNeeded.asMap().entries.map((entry) {
                          return Chip(
                            label: Text(entry.value),
                            deleteIcon: const Icon(Icons.close, size: 16),
                            onDeleted: () => _removeEquipment(entry.key),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : _createEvent,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Create Event',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 