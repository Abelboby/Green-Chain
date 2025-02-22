import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../models/event_model.dart';
import '../../providers/events_provider.dart';
import '../widgets/assign_role_dialog.dart';
import '../widgets/check_in_dialog.dart';
import '../widgets/volunteer_details_dialog.dart';
import 'manage_volunteers_screen.dart';

class EventDetailsScreen extends StatelessWidget {
  final CleanUpEvent event;

  const EventDetailsScreen({
    Key? key,
    required this.event,
  }) : super(key: key);

  String _formatDate(DateTime date) {
    return DateFormat('EEEE, MMMM d, y').format(date);
  }

  String _formatTime(DateTime time) {
    return DateFormat('h:mm a').format(time);
  }

  void _showVolunteerDetails(BuildContext context, String volunteerId) {
    showDialog(
      context: context,
      builder: (context) => VolunteerDetailsDialog(
        volunteerId: volunteerId,
        role: 'General Volunteer', // TODO: Fetch actual role
      ),
    );
  }

  void _showAssignRoleDialog(BuildContext context, String volunteerId) {
    showDialog(
      context: context,
      builder: (context) => AssignRoleDialog(
        volunteerId: volunteerId,
        currentRole: 'General Volunteer', // TODO: Fetch actual role
      ),
    ).then((selectedRole) {
      if (selectedRole != null) {
        // TODO: Update role in Firebase
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Role updated to: $selectedRole'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    });
  }

  void _showCheckInDialog(BuildContext context, String volunteerId) {
    showDialog(
      context: context,
      builder: (context) => CheckInDialog(volunteerId: volunteerId),
    ).then((checkedIn) {
      if (checkedIn == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Volunteer checked in successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                event.title,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 24,
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/images/cleanup_event.png',
                    fit: BoxFit.cover,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Event Status
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: event.isOngoing
                          ? AppColors.success
                          : event.isUpcoming
                              ? AppColors.primaryGreen
                              : Colors.grey,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      event.isOngoing
                          ? 'Ongoing'
                          : event.isUpcoming
                              ? 'Upcoming'
                              : 'Past',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Date and Time
                  Container(
                    padding: const EdgeInsets.all(16),
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
                      children: [
                        ListTile(
                          leading: const Icon(Icons.calendar_today),
                          title: const Text('Date'),
                          subtitle: Text(_formatDate(event.date)),
                        ),
                        const Divider(),
                        ListTile(
                          leading: const Icon(Icons.access_time),
                          title: const Text('Time'),
                          subtitle: Text(
                            '${_formatTime(event.startTime)} - ${_formatTime(event.endTime)}',
                          ),
                        ),
                        const Divider(),
                        ListTile(
                          leading: const Icon(Icons.location_on),
                          title: const Text('Location'),
                          subtitle: Text(event.location),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Description
                  Container(
                    padding: const EdgeInsets.all(16),
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
                          'About this Event',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(event.description),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Equipment Needed
                  if (event.equipmentNeeded.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
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
                            'Equipment Needed',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            children: event.equipmentNeeded.map((equipment) {
                              return Chip(
                                label: Text(equipment),
                                backgroundColor: AppColors.primaryGreen.withOpacity(0.1),
                                labelStyle: const TextStyle(
                                  color: AppColors.primaryGreen,
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  // Volunteers Section
                  Container(
                    padding: const EdgeInsets.all(16),
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Volunteers',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ManageVolunteersScreen(
                                      event: event,
                                    ),
                                  ),
                                );
                              },
                              child: const Text('Manage'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Registered: ${event.volunteerIds.length}/${event.maxVolunteers}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '${(event.volunteerProgress * 100).toInt()}% Full',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: event.volunteerProgress,
                          backgroundColor: Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            event.hasAvailableSpots
                                ? AppColors.primaryGreen
                                : Colors.red,
                          ),
                        ),
                        if (event.volunteerIds.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          const Text(
                            'Recent Volunteers',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 60,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: event.volunteerIds.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: GestureDetector(
                                    onTap: () => _showVolunteerDetails(
                                      context,
                                      event.volunteerIds[index],
                                    ),
                                    child: CircleAvatar(
                                      radius: 30,
                                      backgroundColor: AppColors.primaryGreen.withOpacity(0.1),
                                      child: const Icon(
                                        Icons.person,
                                        color: AppColors.primaryGreen,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Consumer2<AuthProvider, EventsProvider>(
        builder: (context, authProvider, eventsProvider, _) {
          final user = authProvider.user;
          if (user == null) {
            return const SizedBox.shrink();
          }

          final isOrganizer = event.organizerId == user.uid;
          final hasJoined = event.volunteerIds.contains(user.uid);

          if (!event.isUpcoming) {
            return const SizedBox.shrink();
          }

          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.background,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: isOrganizer
                ? Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ManageVolunteersScreen(
                                  event: event,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.people),
                          label: const Text('Manage Volunteers'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primaryGreen,
                            side: const BorderSide(
                              color: AppColors.primaryGreen,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // TODO: Implement event edit
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Edit event coming soon!'),
                              ),
                            );
                          },
                          icon: const Icon(Icons.edit),
                          label: const Text('Edit Event'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryGreen,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ],
                  )
                : ElevatedButton(
                    onPressed: hasJoined || !event.hasAvailableSpots
                        ? hasJoined
                            ? () async {
                                final success = await eventsProvider.leaveEvent(
                                  event.id,
                                  user.uid,
                                );
                                if (success && context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('You have left the event'),
                                      backgroundColor: AppColors.success,
                                    ),
                                  );
                                }
                              }
                            : null
                        : () async {
                            final success = await eventsProvider.joinEvent(
                              event.id,
                              user.uid,
                            );
                            if (success && context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('You have joined the event!'),
                                  backgroundColor: AppColors.success,
                                ),
                              );
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: hasJoined
                          ? Colors.red
                          : AppColors.primaryGreen,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      hasJoined
                          ? 'Leave Event'
                          : event.hasAvailableSpots
                              ? 'Join Event'
                              : 'Event Full',
                    ),
                  ),
          );
        },
      ),
    );
  }
} 