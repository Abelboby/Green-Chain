import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../models/event_model.dart';
import '../screens/event_details_screen.dart';

class EventCard extends StatelessWidget {
  final CleanUpEvent event;

  const EventCard({
    Key? key,
    required this.event,
  }) : super(key: key);

  String _formatDate(DateTime date) {
    return DateFormat('EEE, MMM d, y').format(date);
  }

  String _formatTime(DateTime time) {
    return DateFormat('h:mm a').format(time);
  }

  Widget _buildStatusChip() {
    Color backgroundColor;
    Color textColor = Colors.white;
    String text;

    if (event.isOngoing) {
      backgroundColor = AppColors.success;
      text = 'Ongoing';
    } else if (event.isUpcoming) {
      backgroundColor = AppColors.primaryGreen;
      text = 'Upcoming';
    } else {
      backgroundColor = Colors.grey;
      text = 'Past';
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EventDetailsScreen(event: event),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Image and Status
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: Image.asset(
                    'assets/images/cleanup_event.jpg',
                    height: 150,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: _buildStatusChip(),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Date
                  Text(
                    event.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(event.date),
                        style: const TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Icon(
                        Icons.access_time,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${_formatTime(event.startTime)} - ${_formatTime(event.endTime)}',
                        style: const TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Location
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          event.location,
                          style: const TextStyle(
                            color: Colors.grey,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Progress Bar
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Volunteers: ${event.volunteerIds.length}/${event.maxVolunteers}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '${(event.volunteerProgress * 100).toInt()}%',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: event.volunteerProgress,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          event.hasAvailableSpots
                              ? AppColors.primaryGreen
                              : Colors.red,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Join Button
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, _) {
                      final user = authProvider.user;
                      if (user == null) return const SizedBox.shrink();

                      final isOrganizer = event.organizerId == user.uid;
                      final hasJoined = event.volunteerIds.contains(user.uid);

                      if (isOrganizer) {
                        return OutlinedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    EventDetailsScreen(event: event),
                              ),
                            );
                          },
                          icon: const Icon(Icons.edit),
                          label: const Text('Manage Event'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primaryGreen,
                            side: const BorderSide(
                              color: AppColors.primaryGreen,
                            ),
                          ),
                        );
                      }

                      if (!event.isUpcoming) {
                        return const SizedBox.shrink();
                      }

                      return ElevatedButton.icon(
                        onPressed: hasJoined || !event.hasAvailableSpots
                            ? null
                            : () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        EventDetailsScreen(event: event),
                                  ),
                                );
                              },
                        icon: Icon(
                          hasJoined ? Icons.check : Icons.person_add,
                        ),
                        label: Text(
                          hasJoined
                              ? 'Joined'
                              : event.hasAvailableSpots
                                  ? 'Join Event'
                                  : 'Event Full',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: hasJoined
                              ? Colors.grey
                              : AppColors.primaryGreen,
                          disabledBackgroundColor: Colors.grey,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 