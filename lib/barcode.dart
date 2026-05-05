// import 'dart:io';
// import 'dart:math';
// import 'dart:ui' as ui;
// import 'package:camera/camera.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:google_ml_kit/google_ml_kit.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:image/image.dart' as img;
//
// import 'package:scanai/services/chat_image_controller.dart';
//
// class BarcodeScannerView extends StatefulWidget {
//   final String? meal;
//
//   const BarcodeScannerView({super.key, this.meal});
//
//   @override
//   _BarcodeScannerViewState createState() => _BarcodeScannerViewState();
// }
//
// class _BarcodeScannerViewState extends State<BarcodeScannerView> {
//   CameraController? _cameraController;
//   late final BarcodeScanner _barcodeScanner;
//   bool _isScanning = false;
//   String _barcodeResult = '';
//   bool _isCameraInitialized = false;
//
//   String? imageFile;
//
//   ChatImageController chatImageController = Get.put(ChatImageController());
//
//   @override
//   void initState() {
//     super.initState();
//     _initializeCamera();
//     _barcodeScanner = GoogleMlKit.vision.barcodeScanner();
//   }
//
//   @override
//   void dispose() {
//     _cameraController?.dispose();
//     _barcodeScanner.close();
//     super.dispose();
//   }
//
//   Future<void> _initializeCamera() async {
//     final permissionStatus = await Permission.camera.request();
//     if (!permissionStatus.isGranted) {
//       print('Camera permission not granted');
//       return;
//     }
//
//     final cameras = await availableCameras();
//     _cameraController = CameraController(cameras[0], ResolutionPreset.high);
//
//     try {
//       await _cameraController?.initialize();
//       if (!mounted) return;
//       setState(() {
//         _isCameraInitialized = true;
//       });
//     } catch (e) {
//       print('Error initializing camera: $e');
//     }
//   }
//
//   Future<void> _scanBarcode() async {
//     if (_isScanning || !_isCameraInitialized) return;
//     _isScanning = true;
//
//     try {
//       final picture = await _cameraController?.takePicture();
//       if (picture == null) {
//         _isScanning = false;
//         return;
//       }
//
//       imageFile = picture.path;
//       chatImageController.imagePath.value = picture.path;
//       setState(() {});
//
//       // Crop image to the scan area before scanning
//       final croppedImagePath = await _cropToScanArea(picture.path);
//       final inputImage = InputImage.fromFilePath(croppedImagePath);
//       final barcodes = await _barcodeScanner.processImage(inputImage);
//
//       if (barcodes.isNotEmpty) {
//         for (Barcode barcode in barcodes) {
//           final displayValue = barcode.displayValue ?? '';
//           setState(() {
//             _barcodeResult = displayValue;
//           });
//           chatImageController.barCodeEnable = true;
//
//           await chatImageController.barCodeService(
//             context,
//             widget.meal,
//             _barcodeResult,
//           );
//         }
//       } else {
//         setState(() {
//           _barcodeResult = 'No barcode found';
//         });
//       }
//     } catch (e) {
//       print('Error scanning barcode: $e');
//     } finally {
//       _isScanning = false;
//     }
//   }
//
//   /// Crop image to rectangular scan area in center
//   Future<String> _cropToScanArea(String imagePath) async {
//     final bytes = await File(imagePath).readAsBytes();
//     final originalImage = img.decodeImage(bytes)!;
//
//     final centerX = originalImage.width / 2;
//     final centerY = originalImage.height / 2;
//     final rectWidth = originalImage.width * 0.6;
//     final rectHeight = originalImage.height * 0.3;
//
//     final left = (centerX - rectWidth / 2).round();
//     final top = (centerY - rectHeight / 2).round();
//
//     final cropped = img.copyCrop(
//       originalImage,
//       x: left,
//       y: top,
//       width: rectWidth.round(),
//       height: rectHeight.round(),
//     );
//
//     final croppedPath = '${Directory.systemTemp.path}/cropped_${Random().nextInt(9999)}.jpg';
//     await File(croppedPath).writeAsBytes(img.encodeJpg(cropped));
//     return croppedPath;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.sizeOf(context);
//     return Scaffold(
//       appBar: AppBar(title: const Text('Barcode Scanner')),
//       body: Stack(
//         alignment: Alignment.center,
//         children: [
//           if (_cameraController != null &&
//               _cameraController!.value.isInitialized)
//             SizedBox(
//               height: size.height,
//               width: size.width,
//               child: CameraPreview(_cameraController!),
//             ),
//
//           /// Rectangular scan overlay
//           Positioned.fill(
//             child: CustomPaint(
//               painter: ScannerOverlayPainter(),
//             ),
//           ),
//
//           /// Scan button
//           Positioned(
//             bottom: 20,
//             child: GetBuilder(
//               init: chatImageController,
//               builder: (controller) {
//                 if (controller.barcodeLoader) {
//                   return const CircularProgressIndicator(color: Colors.white);
//                 } else {
//                   return InkWell(
//                     onTap: _scanBarcode,
//                     child: Container(
//                       height: 80,
//                       width: 80,
//                       decoration: BoxDecoration(
//                         color: Colors.transparent,
//                         shape: BoxShape.circle,
//                         border: Border.all(color: Colors.white, width: 5),
//                       ),
//                       child: const Center(
//                         child: CircleAvatar(
//                           radius: 28,
//                           backgroundColor: Colors.white,
//                         ),
//                       ),
//                     ),
//                   );
//                 }
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class ScannerOverlayPainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = Colors.black54
//       ..style = PaintingStyle.fill;
//
//     final boxWidth = size.width * 0.7;
//     final boxHeight = size.height * 0.25;
//     final centerX = size.width / 2;
//     final centerY = size.height / 2;
//     final rect = Rect.fromCenter(
//       center: Offset(centerX, centerY),
//       width: boxWidth,
//       height: boxHeight,
//     );
//
//     // Draw background dim
//     canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
//
//     // Clear inside scan area
//     final clearPaint = Paint()
//       ..blendMode = BlendMode.clear
//       ..style = PaintingStyle.fill;
//     canvas.drawRRect(
//       RRect.fromRectAndRadius(rect, const Radius.circular(16)),
//       clearPaint,
//     );
//
//     // Draw border
//     final borderPaint = Paint()
//       ..color = Colors.white
//       ..strokeWidth = 3
//       ..style = PaintingStyle.stroke;
//     canvas.drawRRect(
//       RRect.fromRectAndRadius(rect, const Radius.circular(16)),
//       borderPaint,
//     );
//   }
//
//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
// }
