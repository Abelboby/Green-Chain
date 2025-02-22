import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart' as http;

class ContractService {
  final Web3Client _client;
  final DeployedContract _contract;
  final String _contractAddress;

  ContractService({
    required String rpcUrl,
    required String contractAddress,
    required String contractAbi,
  })  : _client = Web3Client(rpcUrl, http.Client()),
        _contract = DeployedContract(
          ContractAbi.fromJson(contractAbi, 'ReportAndReward'),
          EthereumAddress.fromHex(contractAddress),
        ),
        _contractAddress = contractAddress;

  Future<String> submitReport({
    required Credentials credentials,
    required String description,
    required String location,
    required String evidenceLink,
    required bool visibility,
  }) async {
    final function = _contract.function('submitReport');

    try {
      final result = await _client.sendTransaction(
        credentials,
        Transaction.callContract(
          contract: _contract,
          function: function,
          parameters: [description, location, evidenceLink, visibility],
          maxGas: 500000,
        ),
        chainId: 11155111, // Sepolia chain ID
      );

      return result;
    } catch (e) {
      throw Exception('Failed to submit report: $e');
    }
  }

  Future<double> estimateReportGasFee({
    required Credentials credentials,
    required String description,
    required String location,
    required String evidenceLink,
    required bool visibility,
  }) async {
    final function = _contract.function('submitReport');
    try {
      final gasEstimate = await _client.estimateGas(
        sender: await credentials.extractAddress(),
        to: EthereumAddress.fromHex(_contractAddress),
        data: function.encodeCall([description, location, evidenceLink, visibility]),
      );

      final gasPrice = await _client.getGasPrice();
      final gasCost = gasEstimate * gasPrice.getInWei;
      return EtherAmount.fromBigInt(EtherUnit.wei, gasCost)
          .getValueInUnit(EtherUnit.ether);
    } catch (e) {
      throw Exception('Failed to estimate gas: $e');
    }
  }

  void dispose() {
    _client.dispose();
  }
} 