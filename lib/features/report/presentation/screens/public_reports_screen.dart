import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../wallet/providers/wallet_provider.dart';
import '../../providers/reports_provider.dart';
import '../widgets/reports_list.dart';

class PublicReportsScreen extends StatelessWidget {
  const PublicReportsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text(
          'Latest Reports',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<ReportsProvider>().refreshReports();
            },
            tooltip: 'Refresh Reports',
          ),
        ],
      ),
      body: Consumer<WalletProvider>(
        builder: (context, walletProvider, _) {
          return Column(
            children: [
              // Stats Section
              Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primaryGreen.withOpacity(0.8),
                      AppColors.primaryGreen,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryGreen.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Consumer<ReportsProvider>(
                  builder: (context, reportsProvider, _) {
                    final totalReports = reportsProvider.reports.length;
                    final verifiedReports = reportsProvider.reports
                        .where((report) => report.verified)
                        .length;

                    return Padding(
                      padding: const EdgeInsets.all(20),
                      child: IntrinsicHeight(
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildStatItem(
                                context,
                                'Total Reports',
                                totalReports.toString(),
                                Icons.description_outlined,
                              ),
                            ),
                            const VerticalDivider(
                              color: Colors.white24,
                              width: 32,
                            ),
                            Expanded(
                              child: _buildStatItem(
                                context,
                                'Verified',
                                verifiedReports.toString(),
                                Icons.verified_outlined,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Reports List Section
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.background,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                    child: ReportsList(
                      showUserReportsOnly: false,
                      userAddress: walletProvider.address,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String title,
    String value,
    IconData icon,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: Colors.white,
          size: 28,
        ),
        const SizedBox(height: 12),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
} 