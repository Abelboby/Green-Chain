import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:web3dart/web3dart.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../wallet/providers/wallet_provider.dart';
import '../../../wallet/widgets/import_wallet_dialog.dart';
import '../../../report/presentation/screens/report_submission_screen.dart';
import '../../../report/presentation/screens/user_reports_screen.dart';
import '../../../report/presentation/widgets/reports_list.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  void _importWallet(BuildContext context) async {
    final privateKey = await showDialog<String>(
      context: context,
      builder: (context) => const ImportWalletDialog(),
    );

    if (privateKey != null && context.mounted) {
      try {
        await context.read<WalletProvider>().importWallet(privateKey);
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
      appBar: AppBar(
        title: const Text('Green Chain'),
        actions: [
          Consumer<WalletProvider>(
            builder: (context, walletProvider, _) {
              if (walletProvider.isLoading) {
                return const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  ),
                );
              }
              return IconButton(
                icon: Icon(
                  walletProvider.hasWallet
                      ? Icons.account_balance_wallet
                      : Icons.account_balance_wallet_outlined,
                ),
                onPressed: () => walletProvider.hasWallet
                    ? walletProvider.refreshBalance()
                    : _importWallet(context),
                tooltip: walletProvider.hasWallet
                    ? 'Refresh Balance'
                    : 'Import Wallet',
              );
            },
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
            icon: const Icon(Icons.add_photo_alternate),
            label: const Text('Report Issue'),
          );
        },
      ),
      body: Consumer<WalletProvider>(
        builder: (context, walletProvider, _) {
          return SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Wallet Balance Card
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Wallet Balance',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                              if (walletProvider.hasWallet)
                                IconButton(
                                  icon: const Icon(Icons.refresh),
                                  onPressed: walletProvider.refreshBalance,
                                  tooltip: 'Refresh Balance',
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _formatBalance(walletProvider.balance),
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (!walletProvider.hasWallet) ...[
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: () => _importWallet(context),
                              icon: const Icon(Icons.add),
                              label: const Text('Import Wallet'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryGreen,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),

                // Reports Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Recent Reports',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (walletProvider.hasWallet)
                        TextButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const UserReportsScreen(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.person),
                          label: const Text('My Reports'),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.primaryGreen,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // Reports List
                Expanded(
                  child: walletProvider.hasWallet
                      ? ReportsList(
                          showUserReportsOnly: false,
                          userAddress: walletProvider.address,
                        )
                      : const Center(
                          child: Text(
                            'Connect your wallet to view and submit reports',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
} 