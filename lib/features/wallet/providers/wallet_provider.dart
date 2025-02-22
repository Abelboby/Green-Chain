import 'package:flutter/material.dart';
import 'package:web3dart/web3dart.dart';
import '../../../core/services/wallet_service.dart';

class WalletProvider extends ChangeNotifier {
  final WalletService _walletService;
  
  Credentials? _credentials;
  String? _address;
  EtherAmount? _balance;
  bool _isLoading = false;

  WalletProvider(this._walletService) {
    _initWallet();
  }

  bool get hasWallet => _credentials != null;
  String? get address => _address;
  EtherAmount? get balance => _balance;
  bool get isLoading => _isLoading;
  Credentials? get credentials => _credentials;

  Future<void> _initWallet() async {
    final privateKey = await _walletService.getStoredPrivateKey();
    if (privateKey != null) {
      await importWallet(privateKey);
    }
  }

  Future<void> importWallet(String privateKey) async {
    try {
      _isLoading = true;
      notifyListeners();

      _credentials = await _walletService.importWallet(privateKey);
      _address = (await _credentials!.extractAddress()).hex;
      await _updateBalance();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _updateBalance() async {
    if (_address != null) {
      _balance = await _walletService.getBalance(_address!);
      notifyListeners();
    }
  }

  Future<void> removeWallet() async {
    await _walletService.removeWallet();
    _credentials = null;
    _address = null;
    _balance = null;
    notifyListeners();
  }

  Future<void> refreshBalance() async {
    await _updateBalance();
  }
} 