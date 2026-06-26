import 'dart:typed_data';
import 'dart:io';

import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class MLKitFaceService {
  late FaceDetector _faceDetector;
  bool _initialized = false;

  /// Initialize the ML Kit Face Detector
  Future<void> init() async {
    if (_initialized) return;

    final options = FaceDetectorOptions(
      enableTracking: true,
      enableClassification: true,
    );
    _faceDetector = FaceDetector(options: options);
    _initialized = true;
  }

  /// Detect faces in image bytes and return list of detected faces
  /// Note: This uses file-based detection for compatibility with camera output
  Future<List<Face>> detectFaces(Uint8List imageBytes) async {
    if (!_initialized) {
      throw Exception("ML Kit Face Detector not initialized");
    }

    try {
      // Write bytes to temporary file for ML Kit to process
      final tempDir = Directory.systemTemp;
      final tempFile = File(
        '${tempDir.path}/temp_face_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      await tempFile.writeAsBytes(imageBytes);

      try {
        final inputImage = InputImage.fromFilePath(tempFile.path);
        final faces = await _faceDetector.processImage(inputImage);
        return faces;
      } finally {
        // Clean up temp file
        if (await tempFile.exists()) {
          await tempFile.delete();
        }
      }
    } catch (e) {
      throw Exception("Face detection failed: $e");
    }
  }

  /// Detect faces from image file path
  Future<List<Face>> detectFacesFromFile(String filePath) async {
    if (!_initialized) {
      throw Exception("ML Kit Face Detector not initialized");
    }

    try {
      final file = File(filePath);
      final bytes = await file.readAsBytes();
      return await detectFaces(bytes);
    } catch (e) {
      throw Exception("Face detection from file failed: $e");
    }
  }

  /// Check if image has at least one face
  Future<bool> hasFace(Uint8List imageBytes) async {
    final faces = await detectFaces(imageBytes);
    return faces.isNotEmpty;
  }

  /// Get the number of faces detected
  Future<int> faceCount(Uint8List imageBytes) async {
    final faces = await detectFaces(imageBytes);
    return faces.length;
  }

  /// Dispose of resources
  void dispose() {
    if (_initialized) {
      _faceDetector.close();
      _initialized = false;
    }
  }

  bool get isInitialized => _initialized;
}
