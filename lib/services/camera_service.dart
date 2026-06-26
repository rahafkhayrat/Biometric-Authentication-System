import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';

class CameraService {
  CameraController? controller;

  Future<void> init() async {
    try {
      // Request camera permission
      final status = await Permission.camera.request();
      if (!status.isGranted) {
        throw Exception('Camera permission denied');
      }

      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        throw Exception('No cameras available');
      }

      // Try to find front camera, fallback to first camera
      CameraDescription? front;
      try {
        front = cameras.firstWhere(
          (c) => c.lensDirection == CameraLensDirection.front,
        );
      } catch (e) {
        front = cameras.first;
      }

      controller = CameraController(
        front,
        ResolutionPreset.low,
        enableAudio: false,
      );

      await controller!.initialize();
    } catch (e) {
      throw Exception('Failed to initialize camera: $e');
    }
  }

  bool get isReady => controller != null && controller!.value.isInitialized;

  CameraPreview? getPreview() {
    if (controller == null || !isReady) return null;
    return CameraPreview(controller!);
  }

  Future<XFile> takePicture() async {
    return await controller!.takePicture();
  }

  void dispose() {
    controller?.dispose();
  }
}
