import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:web3dart/web3dart.dart';
import '../../../../core/theme/app_colors.dart';
import '../../providers/wallet_provider.dart';
import '../../widgets/import_wallet_dialog.dart';
import '../../../report/presentation/screens/report_submission_screen.dart';
import '../../../report/presentation/screens/user_reports_screen.dart';
import '../../../report/presentation/screens/public_reports_screen.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({Key? key}) : super(key: key);

  void _importWallet(BuildContext context) async {
    final privateKey = await showDialog<String>(
      context: context,
      builder: (context) => const ImportWalletDialog(),
    );

    if (privateKey != null && context.mounted) {
      try {
        await context.read<WalletProvider>().importWallet(privateKey);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Wallet imported successfully!'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  String _formatBalance(EtherAmount? balance) {
    if (balance == null) return '0.00 ETH';
    final inWei = balance.getInWei;
    final inEther = inWei.toDouble() / BigInt.from(10).pow(18).toDouble();
    return '${inEther.toStringAsFixed(4)} ETH';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text(
          'Wallet',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 28,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<WalletProvider>().refreshBalance(),
            tooltip: 'Refresh Balance',
          ),
        ],
      ),
      floatingActionButton: Consumer<WalletProvider>(
        builder: (context, walletProvider, _) {
          if (!walletProvider.hasWallet) return const SizedBox.shrink();
          
          return FloatingActionButton.extended(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ReportSubmissionScreen(),
                ),
              );
            },
            backgroundColor: AppColors.primaryGreen,
            elevation: 4,
            icon: const Icon(Icons.add_photo_alternate),
            label: const Text(
              'Report Issue',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          );
        },
      ),
      body: Consumer<WalletProvider>(
        builder: (context, walletProvider, _) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Wallet Section
                Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primaryGreen.withOpacity(0.8),
                        AppColors.primaryGreen,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryGreen.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.account_balance_wallet,
                                  color: Colors.white.withOpacity(0.9),
                                  size: 28,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Wallet Balance',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            if (walletProvider.hasWallet)
                              IconButton(
                                icon: Icon(
                                  Icons.logout,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                                onPressed: () => walletProvider.removeWallet(),
                                tooltip: 'Disconnect Wallet',
                              ),
                          ],
                        ),
                        if (walletProvider.hasWallet) ...[
                          const SizedBox(height: 16),
                          Text(
                            _formatBalance(walletProvider.balance),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${walletProvider.address?.substring(0, 6)}...${walletProvider.address?.substring(38)}',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ] else ...[
                          const SizedBox(height: 16),
                          const Text(
                            'Connect your wallet to start reporting environmental issues',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () => _importWallet(context),
                            icon: const Icon(Icons.add),
                            label: const Text(
                              'Import Wallet',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: AppColors.primaryGreen,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                // Action Buttons
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.background,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildActionButton(
                        context,
                        'View Public Reports',
                        Icons.public,
                        'See what others are reporting',
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PublicReportsScreen(),
                            ),
                          );
                        },
                      ),
                      if (walletProvider.hasWallet) ...[
                        const Divider(height: 1),
                        _buildActionButton(
                          context,
                          'My Reports',
                          Icons.person,
                          'View your submitted reports',
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const UserReportsScreen(),
                              ),
                            );
                          },
                        ),
                        const Divider(height: 1),
                        _buildActionButton(
                          context,
                          'Send',
                          Icons.send,
                          'Transfer tokens to another address',
                          () {
                            // TODO: Implement send functionality
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Coming soon!'),
                              ),
                            );
                          },
                        ),
                        const Divider(height: 1),
                        _buildActionButton(
                          context,
                          'Receive',
                          Icons.qr_code,
                          'Get your wallet address QR code',
                          () {
                            // TODO: Implement receive functionality
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Coming soon!'),
                              ),
                            );
                          },
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
  }

  Widget _buildActionButton(
    BuildContext context,
    String title,
    IconData icon,
    String subtitle,
    VoidCallback onPressed,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 20,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: AppColors.primaryGreen,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ],
          ),
        ),
      ),
    );
  }
} 