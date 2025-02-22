import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart' as http;
import '../../features/report/models/report_data.dart';

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

  Future<List<ReportData>> getVisibleReports() async {
    final function = _contract.function('getVisibleReports');
    
    try {
      final result = await _client.call(
        contract: _contract,
        function: function,
        params: [],
      );

      return (result[0] as List<dynamic>).map((report) {
        return ReportData(
          id: (report[0] as BigInt).toInt(),
          reporter: report[1].toString(),
          description: report[2].toString(),
          location: report[3].toString(),
          evidenceLink: report[4].toString(),
          verified: report[5] as bool,
          reward: (report[6] as BigInt).toInt(),
          timestamp: (report[7] as BigInt).toInt(),
          visibility: report[8] as bool,
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch reports: $e');
    }
  }

  Future<List<ReportData>> getReportsByAddress(String address) async {
    final function = _contract.function('getReportsByAddress');
    
    try {
      final result = await _client.call(
        contract: _contract,
        function: function,
        params: [EthereumAddress.fromHex(address)],
      );

      return (result[0] as List<dynamic>).map((report) {
        return ReportData(
          id: (report[0] as BigInt).toInt(),
          reporter: report[1].toString(),
          description: report[2].toString(),
          location: report[3].toString(),
          evidenceLink: report[4].toString(),
          verified: report[5] as bool,
          reward: (report[6] as BigInt).toInt(),
          timestamp: (report[7] as BigInt).toInt(),
          visibility: report[8] as bool,
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch reports: $e');
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