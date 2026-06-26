// Stub implementation for web platform
// TFLite doesn't work on web, so this provides a no-op implementation
import 'dart:typed_data';

class TFLiteService {
  Future<void> loadModel({String assetPath = 'assets/facenet.tflite'}) async {
    // No-op on web
  }

  List<double> runModel(Uint8List imageBytes) {
    // Return placeholder embedding on web
    return List.filled(512, 0.5);
  }

  void dispose() {
    // No-op on web
  }
}

