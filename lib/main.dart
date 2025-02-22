import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme/app_theme.dart';
import 'core/services/wallet_service.dart';
import 'core/services/contract_service.dart';
import 'core/constants/app_constants.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/auth/screens/auth_wrapper.dart';
import 'features/wallet/providers/wallet_provider.dart';
import 'features/report/providers/reports_provider.dart';
import 'features/events/providers/events_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  final prefs = await SharedPreferences.getInstance();
  final walletService = WalletService(prefs);
  final contractService = ContractService(
    rpcUrl: AppConstants.rpcUrl,
    contractAddress: AppConstants.contractAddress,
    contractAbi: AppConstants.contractAbi,
  );

  runApp(MyApp(
    prefs: prefs,
    walletService: walletService,
    contractService: contractService,
  ));
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;
  final WalletService walletService;
  final ContractService contractService;

  const MyApp({
    Key? key,
    required this.prefs,
    required this.walletService,
    required this.contractService,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => WalletProvider(walletService)),
        ChangeNotifierProvider(create: (_) => ReportsProvider(contractService)),
        ChangeNotifierProvider(create: (_) => EventsProvider()),
      ],
      child: MaterialApp(
        title: 'Green Chain',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const AuthWrapper(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
