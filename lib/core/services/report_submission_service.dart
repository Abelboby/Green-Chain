import 'dart:io';
import 'package:web3dart/web3dart.dart';
import 'ipfs_service.dart';
import 'contract_service.dart';

class ReportSubmissionService {
  final IpfsService _ipfsService;
  final ContractService _contractService;
  final Credentials _credentials;

  ReportSubmissionService({
    required String ipfsApiKey,
    required String ipfsApiSecret,
    required String rpcUrl,
    required String contractAddress,
    required String contractAbi,
    required Credentials credentials,
  })  : _ipfsService = IpfsService(
          apiKey: ipfsApiKey,
          apiSecret: ipfsApiSecret,
        ),
        _contractService = ContractService(
          rpcUrl: rpcUrl,
          contractAddress: contractAddress,
          contractAbi: contractAbi,
        ),
        _credentials = credentials;

  Future<String> submitReport({
    required File mediaFile,
    required String description,
    required String location,
    required bool isVisible,
  }) async {
    try {
      // 1. Upload media to IPFS
      final String ipfsHash = await _ipfsService.uploadFile(mediaFile);

      // 2. Estimate gas fee
      final double estimatedGas = await _contractService.estimateReportGasFee(
        credentials: _credentials,
        description: description,
        location: location,
        evidenceLink: ipfsHash,
        visibility: isVisible,
      );

      // 3. Submit report to blockchain
      final String transactionHash = await _contractService.submitReport(
        credentials: _credentials,
        description: description,
        location: location,
        evidenceLink: ipfsHash,
        visibility: isVisible,
      );

      return transactionHash;
    } catch (e) {
      throw Exception('Failed to submit report: $e');
    }
  }

  void dispose() {
    _contractService.dispose();
  }
} 