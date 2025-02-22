import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../../core/theme/app_colors.dart';

class WalletQRScanner extends StatefulWidget {
  final Function(String) onDetect;

  const WalletQRScanner({
    Key? key,
    required this.onDetect,
  }) : super(key: key);

  @override
  State<WalletQRScanner> createState() => _WalletQRScannerState();
}

class _WalletQRScannerState extends State<WalletQRScanner> {
  MobileScannerController controller = MobileScannerController();
  bool isScanning = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Wallet QR Code'),
        actions: [
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: controller.torchState,
              builder: (context, state, child) {
                switch (state as TorchState) {
                  case TorchState.off:
                    return const Icon(Icons.flash_off);
                  case TorchState.on:
                    return const Icon(Icons.flash_on);
                }
              },
            ),
            onPressed: () => controller.toggleTorch(),
          ),
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: controller.cameraFacingState,
              builder: (context, state, child) {
                switch (state as CameraFacing) {
                  case CameraFacing.front:
                    return const Icon(Icons.camera_front);
                  case CameraFacing.back:
                    return const Icon(Icons.camera_rear);
                }
              },
            ),
            onPressed: () => controller.switchCamera(),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                MobileScanner(
                  controller: controller,
                  onDetect: (capture) {
                    final List<Barcode> barcodes = capture.barcodes;
                    for (final barcode in barcodes) {
                      if (barcode.rawValue != null && 
                          isValidPrivateKey(barcode.rawValue!)) {
                        widget.onDetect(barcode.rawValue!);
                        Navigator.pop(context);
                        return;
                      }
                    }
                  },
                ),
                // Scanning overlay
                CustomPaint(
                  size: Size.infinite,
                  painter: ScannerOverlayPainter(),
                ),
                // Scanning indicator
                Positioned(
                  bottom: 40,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Align QR code within the frame',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (isScanning)
                          const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.primaryGreen,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool isValidPrivateKey(String key) {
    // Remove '0x' prefix if present
    final cleanKey = key.toLowerCase().startsWith('0x') 
        ? key.substring(2) 
        : key;

    // Check if it's a valid hex string of correct length (64 characters = 32 bytes)
    if (cleanKey.length != 64) return false;

    // Check if it contains only valid hex characters
    return RegExp(r'^[0-9a-f]{64}$').hasMatch(cleanKey);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

class ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.fill;

    const scanAreaSize = 250.0;
    final scanAreaRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: scanAreaSize,
      height: scanAreaSize,
    );

    // Draw semi-transparent overlay
    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
        Path()..addRect(scanAreaRect),
      ),
      paint,
    );

    // Draw scanning area border
    final borderPaint = Paint()
      ..color = AppColors.primaryGreen
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    canvas.drawRect(scanAreaRect, borderPaint);

    // Draw corner markers
    const markerLength = 30.0;
    final cornerPaint = Paint()
      ..color = AppColors.primaryGreen
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;

    // Top-left corner
    canvas.drawLine(
      scanAreaRect.topLeft,
      scanAreaRect.topLeft.translate(markerLength, 0),
      cornerPaint,
    );
    canvas.drawLine(
      scanAreaRect.topLeft,
      scanAreaRect.topLeft.translate(0, markerLength),
      cornerPaint,
    );

    // Top-right corner
    canvas.drawLine(
      scanAreaRect.topRight,
      scanAreaRect.topRight.translate(-markerLength, 0),
      cornerPaint,
    );
    canvas.drawLine(
      scanAreaRect.topRight,
      scanAreaRect.topRight.translate(0, markerLength),
      cornerPaint,
    );

    // Bottom-left corner
    canvas.drawLine(
      scanAreaRect.bottomLeft,
      scanAreaRect.bottomLeft.translate(markerLength, 0),
      cornerPaint,
    );
    canvas.drawLine(
      scanAreaRect.bottomLeft,
      scanAreaRect.bottomLeft.translate(0, -markerLength),
      cornerPaint,
    );

    // Bottom-right corner
    canvas.drawLine(
      scanAreaRect.bottomRight,
      scanAreaRect.bottomRight.translate(-markerLength, 0),
      cornerPaint,
    );
    canvas.drawLine(
      scanAreaRect.bottomRight,
      scanAreaRect.bottomRight.translate(0, -markerLength),
      cornerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
} 