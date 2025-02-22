import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../wallet/providers/wallet_provider.dart';
import '../../../../core/services/report_submission_service.dart';

class ReportSubmissionScreen extends StatefulWidget {
  const ReportSubmissionScreen({Key? key}) : super(key: key);

  @override
  State<ReportSubmissionScreen> createState() => _ReportSubmissionScreenState();
}

class _ReportSubmissionScreenState extends State<ReportSubmissionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  File? _mediaFile;
  Position? _currentPosition;
  bool _isVisible = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        final permissionStatus = await Geolocator.requestPermission();
        if (permissionStatus == LocationPermission.denied) {
          throw Exception('Location permission denied');
        }
      }

      final position = await Geolocator.getCurrentPosition();
      setState(() => _currentPosition = position);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error getting location: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _captureMedia(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? media = await picker.pickImage(source: source);

      if (media?.path != null) {
        setState(() => _mediaFile = File(media!.path));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error capturing media: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate() || _mediaFile == null || _currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final walletProvider = context.read<WalletProvider>();
      final credentials = walletProvider.credentials;
      
      if (!walletProvider.hasWallet || credentials == null) {
        throw Exception('No wallet connected');
      }

      final reportService = ReportSubmissionService(
        ipfsApiKey: AppConstants.ipfsApiKey,
        ipfsApiSecret: AppConstants.ipfsApiSecret,
        rpcUrl: AppConstants.rpcUrl,
        contractAddress: AppConstants.contractAddress,
        contractAbi: AppConstants.contractAbi,
        credentials: credentials,
      );

      final location = '${_currentPosition!.latitude},${_currentPosition!.longitude}';
      final txHash = await reportService.submitReport(
        mediaFile: _mediaFile!,
        description: _descriptionController.text,
        location: location,
        isVisible: _isVisible,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Report submitted successfully!'),
            backgroundColor: AppColors.success,
            action: SnackBarAction(
              label: 'View TX',
              textColor: Colors.white,
              onPressed: () async {
                final url = AppConstants.getTransactionUrl(txHash);
                if (await canLaunchUrl(Uri.parse(url))) {
                  await launchUrl(Uri.parse(url));
                }
              },
            ),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error submitting report: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Submit Report'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Media Preview/Capture
              Center(
                child: GestureDetector(
                  onTap: () => showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Choose Image Source'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            leading: const Icon(Icons.camera),
                            title: const Text('Camera'),
                            onTap: () {
                              Navigator.pop(context);
                              _captureMedia(ImageSource.camera);
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.photo_library),
                            title: const Text('Gallery'),
                            onTap: () {
                              Navigator.pop(context);
                              _captureMedia(ImageSource.gallery);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  child: Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: _mediaFile != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              _mediaFile!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(
                                Icons.add_a_photo,
                                size: 48,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Tap to add photo',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Describe the environmental issue...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Location
              Card(
                child: ListTile(
                  leading: const Icon(Icons.location_on),
                  title: Text(
                    _currentPosition != null
                        ? 'Location: ${_currentPosition!.latitude.toStringAsFixed(4)}, ${_currentPosition!.longitude.toStringAsFixed(4)}'
                        : 'Getting location...',
                  ),
                  trailing: _currentPosition == null
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.check, color: AppColors.success),
                ),
              ),
              const SizedBox(height: 16),

              // Visibility Toggle
              SwitchListTile(
                title: const Text('Make Report Public'),
                subtitle: const Text('Allow others to see this report'),
                value: _isVisible,
                onChanged: (value) => setState(() => _isVisible = value),
              ),
              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitReport,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Submit Report'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 