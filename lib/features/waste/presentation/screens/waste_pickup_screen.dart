import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../providers/waste_provider.dart';
import '../../models/index.dart';
import 'package:geolocator/geolocator.dart';

class WastePickupScreen extends StatefulWidget {
  const WastePickupScreen({Key? key}) : super(key: key);

  @override
  State<WastePickupScreen> createState() => _WastePickupScreenState();
}

class _WastePickupScreenState extends State<WastePickupScreen> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  final List<String> _selectedWasteTypes = [];
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _instructionsController = TextEditingController();

  final List<String> wasteTypes = [
    'Plastic',
    'Paper',
    'Glass',
    'Metal',
    'E-waste',
    'Organic',
    'Hazardous',
    'Others'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule Waste Pickup'),
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Date and Time Selection
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'When would you like the pickup?',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now().add(const Duration(days: 1)),
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(const Duration(days: 30)),
                              );
                              if (date != null) {
                                setState(() => _selectedDate = date);
                              }
                            },
                            icon: const Icon(Icons.calendar_today),
                            label: Text(
                              _selectedDate != null
                                  ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                                  : 'Select Date',
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final time = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.now(),
                              );
                              if (time != null) {
                                setState(() => _selectedTime = time);
                              }
                            },
                            icon: const Icon(Icons.access_time),
                            label: Text(
                              _selectedTime != null
                                  ? '${_selectedTime!.hour}:${_selectedTime!.minute.toString().padLeft(2, '0')}'
                                  : 'Select Time',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Waste Types Selection
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'What types of waste do you have?',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: wasteTypes.map((type) {
                        final isSelected = _selectedWasteTypes.contains(type);
                        return FilterChip(
                          label: Text(type),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedWasteTypes.add(type);
                              } else {
                                _selectedWasteTypes.remove(type);
                              }
                            });
                          },
                          selectedColor: AppColors.primaryGreen.withOpacity(0.2),
                          checkmarkColor: AppColors.primaryGreen,
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Address and Weight
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _addressController,
                      decoration: const InputDecoration(
                        labelText: 'Pickup Address',
                        prefixIcon: Icon(Icons.location_on),
                      ),
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Please enter the pickup address';
                        }
                        return null;
                      },
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _weightController,
                      decoration: const InputDecoration(
                        labelText: 'Estimated Weight (kg)',
                        prefixIcon: Icon(Icons.scale),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Please enter estimated weight';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Special Instructions
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextFormField(
                  controller: _instructionsController,
                  decoration: const InputDecoration(
                    labelText: 'Special Instructions (Optional)',
                    prefixIcon: Icon(Icons.note),
                  ),
                  maxLines: 3,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Submit Button
            ElevatedButton(
              onPressed: _submitPickupRequest,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Schedule Pickup',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submitPickupRequest() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select date and time')),
      );
      return;
    }
    if (_selectedWasteTypes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one waste type')),
      );
      return;
    }

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final wasteProvider = Provider.of<WasteProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // Get current location for the pickup
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Create the pickup request
      final pickup = WastePickup(
        id: '', // Will be set by Firestore
        userId: authProvider.user!.uid,
        scheduledDate: _selectedDate!,
        preferredTime: _selectedTime!,
        address: _addressController.text,
        location: GeoPoint(position.latitude, position.longitude),
        wasteTypes: _selectedWasteTypes,
        estimatedWeight: double.parse(_weightController.text),
        specialInstructions: _instructionsController.text,
        status: PickupStatus.scheduled,
        frequency: PickupFrequency.oneTime,
        isPaid: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await wasteProvider.schedulePickup(pickup);
      
      if (mounted) {
        Navigator.pop(context); // Dismiss loading dialog
        Navigator.pop(context); // Return to previous screen
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pickup scheduled successfully!'),
            backgroundColor: AppColors.primaryGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Dismiss loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    _weightController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }
} 