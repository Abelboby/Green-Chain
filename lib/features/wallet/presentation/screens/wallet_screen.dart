import 'package:flutter/material.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wallet'),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: () {
              // TODO: Implement wallet connect via QR
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total Balance',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '1,234.56 GT',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Icon(
                            Icons.eco,
                            color: Colors.green,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'CO₂ Saved: 45.6 kg',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // TODO: Implement send
                      },
                      icon: const Icon(Icons.send),
                      label: const Text('Send'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // TODO: Implement receive
                      },
                      icon: const Icon(Icons.qr_code),
                      label: const Text('Receive'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Recent Activity',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: 5,
                  itemBuilder: (context, index) {
                    final bool isSent = index % 2 == 0;
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: isSent ? Colors.red[100] : Colors.green[100],
                        child: Icon(
                          isSent ? Icons.arrow_upward : Icons.arrow_downward,
                          color: isSent ? Colors.red : Colors.green,
                        ),
                      ),
                      title: Text(
                        isSent ? 'Sent GT' : 'Received GT',
                      ),
                      subtitle: Text(
                        DateTime.now()
                            .subtract(Duration(days: index))
                            .toString()
                            .split('.')[0],
                      ),
                      trailing: Text(
                        '${isSent ? '-' : '+'}${(index + 1) * 10.0} GT',
                        style: TextStyle(
                          color: isSent ? Colors.red : Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 