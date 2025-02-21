import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../core/theme/app_colors.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _handleSignOut(BuildContext context) async {
    try {
      await context.read<AuthProvider>().signOut();
      // No need to navigate manually - AuthWrapper will handle it
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to sign out. Please try again.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final isLoading = context.watch<AuthProvider>().isLoading;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Green Token'),
        actions: [
          if (isLoading)
            const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              ),
            )
          else
            IconButton(
              onPressed: () => _handleSignOut(context),
              icon: const Icon(Icons.logout),
              tooltip: 'Sign Out',
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: Text('Welcome ${user?.name}!'),
      ),
    );
  }
} 