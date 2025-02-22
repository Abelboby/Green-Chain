import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../models/event_model.dart';
import '../../providers/events_provider.dart';

class ManageVolunteersScreen extends StatefulWidget {
  final CleanUpEvent event;

  const ManageVolunteersScreen({
    Key? key,
    required this.event,
  }) : super(key: key);

  @override
  State<ManageVolunteersScreen> createState() => _ManageVolunteersScreenState();
}

class _ManageVolunteersScreenState extends State<ManageVolunteersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
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
          'Manage Volunteers',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 28,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Assigned'),
            Tab(text: 'Check-in'),
          ],
          labelColor: AppColors.primaryGreen,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppColors.primaryGreen,
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search volunteers...',
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
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          // Stats Cards
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total',
                    widget.event.volunteerIds.length.toString(),
                    Icons.group,
                    AppColors.primaryGreen,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    'Available',
                    (widget.event.maxVolunteers - widget.event.volunteerIds.length)
                        .toString(),
                    Icons.person_add,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    'Checked In',
                    '0', // TODO: Implement check-in tracking
                    Icons.check_circle,
                    Colors.blue,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildVolunteersList(context, 'all'),
                _buildVolunteersList(context, 'assigned'),
                _buildVolunteersList(context, 'checkin'),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Implement volunteer assignment
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Coming soon: Volunteer assignment feature'),
            ),
          );
        },
        icon: const Icon(Icons.person_add),
        label: const Text('Assign Roles'),
        backgroundColor: AppColors.primaryGreen,
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVolunteersList(BuildContext context, String type) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final volunteers = widget.event.volunteerIds;
        if (volunteers.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.people_outline,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No volunteers yet',
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
          itemCount: volunteers.length,
          itemBuilder: (context, index) {
            final volunteerId = volunteers[index];
            // TODO: Fetch volunteer details from Firestore
            return Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.primaryGreen.withOpacity(0.1),
                  child: const Icon(
                    Icons.person,
                    color: AppColors.primaryGreen,
                  ),
                ),
                title: Text(
                  'Volunteer #${index + 1}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(volunteerId),
                trailing: PopupMenuButton(
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'assign',
                      child: Text('Assign Role'),
                    ),
                    const PopupMenuItem(
                      value: 'message',
                      child: Text('Send Message'),
                    ),
                    const PopupMenuItem(
                      value: 'remove',
                      child: Text('Remove'),
                    ),
                  ],
                  onSelected: (value) {
                    // TODO: Implement volunteer management actions
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Action $value coming soon'),
                      ),
                    );
                  },
                ),
                onTap: () {
                  // TODO: Show volunteer details dialog
                },
              ),
            );
          },
        );
      },
    );
  }
} 