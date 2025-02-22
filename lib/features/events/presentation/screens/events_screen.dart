import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../providers/events_provider.dart';
import '../widgets/event_card.dart';
import 'create_event_screen.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({Key? key}) : super(key: key);

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  String _selectedFilter = 'upcoming';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<EventsProvider>().fetchEvents();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            expandedHeight: 200,
            floating: true,
            pinned: true,
            backgroundColor: AppColors.primaryGreen,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Clean-Up Events',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 28,
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/images/cleanup_banner.jpg',
                    fit: BoxFit.cover,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          AppColors.primaryGreen.withOpacity(0.8),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Search Bar
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search events...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: 16),
                  // Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        FilterChip(
                          label: const Text('Upcoming'),
                          selected: _selectedFilter == 'upcoming',
                          onSelected: (selected) {
                            setState(() => _selectedFilter = 'upcoming');
                          },
                        ),
                        const SizedBox(width: 8),
                        FilterChip(
                          label: const Text('Ongoing'),
                          selected: _selectedFilter == 'ongoing',
                          onSelected: (selected) {
                            setState(() => _selectedFilter = 'ongoing');
                          },
                        ),
                        const SizedBox(width: 8),
                        FilterChip(
                          label: const Text('Past'),
                          selected: _selectedFilter == 'past',
                          onSelected: (selected) {
                            setState(() => _selectedFilter = 'past');
                          },
                        ),
                        const SizedBox(width: 8),
                        FilterChip(
                          label: const Text('My Events'),
                          selected: _selectedFilter == 'my_events',
                          onSelected: (selected) {
                            setState(() => _selectedFilter = 'my_events');
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Consumer2<EventsProvider, AuthProvider>(
                builder: (context, eventsProvider, authProvider, _) {
                  if (eventsProvider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (eventsProvider.error != null) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 48,
                            color: Colors.red,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            eventsProvider.error!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.red,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => eventsProvider.fetchEvents(),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  final events = eventsProvider.events.where((event) {
                    // Apply search filter
                    if (_searchController.text.isNotEmpty) {
                      final searchTerm = _searchController.text.toLowerCase();
                      return event.title.toLowerCase().contains(searchTerm) ||
                          event.description.toLowerCase().contains(searchTerm) ||
                          event.location.toLowerCase().contains(searchTerm);
                    }
                    
                    // Apply category filter
                    switch (_selectedFilter) {
                      case 'upcoming':
                        return event.isUpcoming;
                      case 'ongoing':
                        return event.isOngoing;
                      case 'past':
                        return !event.isUpcoming && !event.isOngoing;
                      case 'my_events':
                        return event.organizerId == authProvider.user?.uid ||
                            event.volunteerIds.contains(authProvider.user?.uid);
                      default:
                        return true;
                    }
                  }).toList();

                  if (events.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.event_busy,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No events found',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: EventCard(event: events[index]),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          if (authProvider.user == null) return const SizedBox.shrink();
          
          return FloatingActionButton.extended(
            heroTag: 'events_create_fab',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CreateEventScreen(),
                ),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Create Event'),
            backgroundColor: AppColors.primaryGreen,
          );
        },
      ),
    );
  }
} 