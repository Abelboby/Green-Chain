import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../wallet/providers/wallet_provider.dart';
import '../../providers/reports_provider.dart';

class UserReportsScreen extends StatefulWidget {
  const UserReportsScreen({Key? key}) : super(key: key);

  @override
  State<UserReportsScreen> createState() => _UserReportsScreenState();
}

class _UserReportsScreenState extends State<UserReportsScreen> {
  @override
  void initState() {
    super.initState();
    // Schedule the state update after the build phase
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserReports();
    });
  }

  Future<void> _loadUserReports() async {
    if (!mounted) return;
    final address = context.read<WalletProvider>().address;
    if (address != null) {
      await context.read<ReportsProvider>().loadUserReports(address);
    }
  }

  @override
  Widget build(BuildContext context) {
    final walletProvider = context.watch<WalletProvider>();
    final reportsProvider = context.watch<ReportsProvider>();
    final address = walletProvider.address;

    if (address == null) {
      return const Scaffold(
        body: Center(
          child: Text('No wallet connected'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Reports'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Row(
                    children: [
                      Icon(Icons.info, color: AppColors.primaryGreen),
                      const SizedBox(width: 8),
                      const Text('Report Status Guide'),
                    ],
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStatusItem(
                        context,
                        'Pending',
                        'Reports awaiting verification',
                        Icons.pending,
                        Colors.orange,
                      ),
                      const SizedBox(height: 12),
                      _buildStatusItem(
                        context,
                        'Verified',
                        'Reports that have been verified and rewarded',
                        Icons.verified,
                        AppColors.success,
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              );
            },
            tooltip: 'Status Guide',
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey.withOpacity(0.2),
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.account_balance_wallet,
                  color: AppColors.primaryGreen,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Wallet: ${_formatAddress(address)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                if (!mounted) return;
                await reportsProvider.refreshUserReports(address);
              },
              child: reportsProvider.isLoadingUserReports
                  ? const Center(child: CircularProgressIndicator())
                  : reportsProvider.error != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Error: ${reportsProvider.error}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: AppColors.error),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _loadUserReports,
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        )
                      : reportsProvider.userReports.isEmpty
                          ? const Center(
                              child: Text('You haven\'t submitted any reports yet'),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: reportsProvider.userReports.length,
                              itemBuilder: (context, index) {
                                final report = reportsProvider.userReports[index];
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      AspectRatio(
                                        aspectRatio: 16 / 9,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.grey[200],
                                            borderRadius: const BorderRadius.vertical(
                                              top: Radius.circular(4),
                                            ),
                                          ),
                                          child: Image.network(
                                            'https://ipfs.io/ipfs/${report.evidenceLink}',
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) {
                                              return const Center(
                                                child: Icon(
                                                  Icons.error_outline,
                                                  size: 48,
                                                  color: Colors.grey,
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              report.description,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Row(
                                              children: [
                                                const Icon(Icons.location_on, size: 16),
                                                const SizedBox(width: 4),
                                                Text(_formatLocation(report.location)),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                const Icon(Icons.access_time, size: 16),
                                                const SizedBox(width: 4),
                                                Text(_formatTimestamp(report.timestamp)),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: report.verified
                                                    ? AppColors.success.withOpacity(0.1)
                                                    : Colors.orange.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    report.verified
                                                        ? Icons.verified
                                                        : Icons.pending,
                                                    size: 16,
                                                    color: report.verified
                                                        ? AppColors.success
                                                        : Colors.orange,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    report.verified
                                                        ? 'Verified - Reward: ${report.reward} ETH'
                                                        : 'Pending Verification',
                                                    style: TextStyle(
                                                      color: report.verified
                                                          ? AppColors.success
                                                          : Colors.orange,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusItem(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Icon(icon, color: color),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatAddress(String address) {
    if (address.length < 10) return address;
    return '${address.substring(0, 6)}...${address.substring(address.length - 4)}';
  }

  String _formatLocation(String location) {
    final coordinates = location.split(',');
    if (coordinates.length != 2) return location;
    return '${coordinates[0].substring(0, 7)}, ${coordinates[1].substring(0, 7)}';
  }

  String _formatTimestamp(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
  }
} 