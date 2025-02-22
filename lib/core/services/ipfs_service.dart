import 'dart:io';
import 'package:dio/dio.dart';

class IpfsService {
  final String apiKey;
  final String apiSecret;
  final String? jwt;
  final Dio _dio;

  IpfsService({
    required this.apiKey,
    required this.apiSecret,
    this.jwt,
  }) : _dio = Dio(BaseOptions(
          baseUrl: 'https://api.pinata.cloud',
          headers: {
            if (jwt != null)
              'Authorization': 'Bearer $jwt'
            else ...<String, String>{
              'pinata_api_key': apiKey,
              'pinata_secret_api_key': apiSecret,
            },
          },
        ));

  Future<String> uploadFile(File file) async {
    try {
      String fileName = file.path.split('/').last;
      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: fileName,
        ),
      });

      final response = await _dio.post(
        '/pinning/pinFileToIPFS',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      if (response.statusCode == 200) {
        return response.data['IpfsHash'];
      } else {
        throw Exception('Failed to upload to IPFS: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error uploading to IPFS: $e');
    }
  }
} 