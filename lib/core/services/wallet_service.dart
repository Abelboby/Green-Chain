import 'package:web3dart/web3dart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class WalletService {
  static const String _privateKeyKey = 'private_key';
  static const String _rpcUrl = 'https://sepolia.infura.io/v3/75e1ccf8e39e4f67b34e691671471204'; // Replace with your Infura project ID

  final Web3Client _client;
  final SharedPreferences _prefs;

  WalletService(this._prefs) : _client = Web3Client(_rpcUrl, http.Client());

  Future<Credentials> importWallet(String privateKey) async {
    try {
      final credentials = EthPrivateKey.fromHex(privateKey);
      final address = await credentials.extractAddress();

      // Save private key securely
      await _prefs.setString(_privateKeyKey, privateKey);

      return credentials;
    } catch (e) {
      throw Exception('Invalid private key');
    }
  }

  Future<String?> getStoredPrivateKey() async {
    return _prefs.getString(_privateKeyKey);
  }

  Future<EtherAmount> getBalance(String address) async {
    final ethAddress = EthereumAddress.fromHex(address);
    return await _client.getBalance(ethAddress);
  }

  Future<void> removeWallet() async {
    await _prefs.remove(_privateKeyKey);
  }

  Future<bool> hasWallet() async {
    return _prefs.containsKey(_privateKeyKey);
  }

  void dispose() {
    _client.dispose();
  }
} 