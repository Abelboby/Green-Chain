import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../models/report_data.dart';
import '../../providers/reports_provider.dart';

class ReportsList extends StatelessWidget {
  final bool showUserReportsOnly;
  final String? userAddress;

  const ReportsList({
    Key? key,
    this.showUserReportsOnly = false,
    this.userAddress,
  }) : super(key: key);

  String _formatTimestamp(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
  }

  String _formatLocation(String location) {
    final coordinates = location.split(',');
    if (coordinates.length != 2) return location;
    return '${coordinates[0].substring(0, 7)}, ${coordinates[1].substring(0, 7)}';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ReportsProvider>(
      builder: (context, reportsProvider, _) {
        if (reportsProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (reportsProvider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Error loading reports: ${reportsProvider.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.error),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: reportsProvider.refreshReports,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final reports = showUserReportsOnly && userAddress != null
            ? reportsProvider.reports
                .where((report) => report.reporter == userAddress)
                .toList()
            : reportsProvider.reports;

        if (reports.isEmpty) {
          return Center(
            child: Text(
              showUserReportsOnly
                  ? 'You haven\'t submitted any reports yet'
                  : 'No reports available',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: reportsProvider.refreshReports,
          child: ListView.builder(
            itemCount: reports.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final report = reports[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image from IPFS
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
                          if (report.verified) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.success.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.verified,
                                    size: 16,
                                    color: AppColors.success,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Verified - Reward: ${report.reward} ETH',
                                    style: const TextStyle(
                                      color: AppColors.success,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
} 