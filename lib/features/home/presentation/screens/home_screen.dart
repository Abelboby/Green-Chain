import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Green Token'),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_balance_wallet_outlined),
            onPressed: () {
              // TODO: Implement wallet connection
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
              const Text(
                'Recent Transactions',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: 5, // Placeholder count
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Colors.green,
                        child: Icon(Icons.swap_horiz, color: Colors.white),
                      ),
                      title: Text('Transaction ${index + 1}'),
                      subtitle: Text('${DateTime.now().subtract(Duration(days: index)).toString().split('.')[0]}'),
                      trailing: Text(
                        '${index % 2 == 0 ? '+' : '-'}${(index + 1) * 10.0} GT',
                        style: TextStyle(
                          color: index % 2 == 0 ? Colors.green : Colors.red,
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