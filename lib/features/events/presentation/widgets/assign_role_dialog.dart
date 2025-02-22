import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class AssignRoleDialog extends StatefulWidget {
  final String volunteerId;
  final String? currentRole;

  const AssignRoleDialog({
    Key? key,
    required this.volunteerId,
    this.currentRole,
  }) : super(key: key);

  @override
  State<AssignRoleDialog> createState() => _AssignRoleDialogState();
}

class _AssignRoleDialogState extends State<AssignRoleDialog> {
  late String _selectedRole;
  final List<String> _availableRoles = [
    'Team Leader',
    'Waste Collector',
    'Recycling Specialist',
    'Equipment Manager',
    'First Aid',
    'Photographer',
    'General Volunteer',
  ];

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.currentRole ?? _availableRoles.last;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.assignment_ind,
                  color: AppColors.primaryGreen,
                  size: 28,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Assign Role',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                  color: Colors.grey,
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Select a role for this volunteer:',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _availableRoles.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final role = _availableRoles[index];
                  return RadioListTile(
                    title: Text(role),
                    value: role,
                    groupValue: _selectedRole,
                    onChanged: (value) {
                      setState(() {
                        _selectedRole = value.toString();
                      });
                    },
                    activeColor: AppColors.primaryGreen,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey,
                      side: const BorderSide(color: Colors.grey),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, _selectedRole);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Assign'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 