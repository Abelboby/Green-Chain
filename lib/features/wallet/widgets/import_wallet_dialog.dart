import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class ImportWalletDialog extends StatefulWidget {
  const ImportWalletDialog({super.key});

  @override
  State<ImportWalletDialog> createState() => _ImportWalletDialogState();
}

class _ImportWalletDialogState extends State<ImportWalletDialog> {
  final _privateKeyController = TextEditingController();
  bool _isPrivateKeyValid = true;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.account_balance_wallet, color: AppColors.primaryGreen),
          const SizedBox(width: 8),
          const Text('Import Wallet'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _privateKeyController,
            decoration: InputDecoration(
              labelText: 'Private Key',
              errorText: _isPrivateKeyValid ? null : 'Invalid private key',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.key),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          const Text(
            'Enter your Sepolia testnet wallet private key',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '• Make sure you are on Sepolia testnet\n• Never share your private key\n• Keep it safe and secure',
            style: TextStyle(
              color: AppColors.warning,
              fontSize: 12,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style: TextStyle(color: AppColors.textSecondaryLight),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            final privateKey = _privateKeyController.text.trim();
            if (privateKey.length == 64 || privateKey.length == 66) {
              Navigator.pop(context, privateKey);
            } else {
              setState(() => _isPrivateKeyValid = false);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryGreen,
          ),
          child: const Text('Import'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _privateKeyController.dispose();
    super.dispose();
  }
} 