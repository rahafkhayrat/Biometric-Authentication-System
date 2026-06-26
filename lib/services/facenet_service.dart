import 'dart:typed_data';
import 'dart:math';
import 'dart:ui';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class FaceNetService {
  Interpreter? _interpreter;
  bool _loaded = false;

  /// Model input size (adjust to your model, common: 112 or 160)
  final int inputSize = 160;
  final String modelPath = 'assets/models/facenet.tflite';

  Future<void> loadModel() async {
    if (_loaded) return;
    _interpreter = await Interpreter.fromAsset(modelPath);
    _loaded = true;
  }

  bool get isLoaded => _loaded;

  List<double> _l2Normalize(List<double> v) {
    double sum = 0;
    for (final x in v) {
      sum += x * x;
    }
    final norm = sqrt(sum);
    if (norm == 0) return v;
    return v.map((x) => x / norm).toList();
  }

  /// Generate embedding from full image bytes. Optionally pass [faceRect]
  /// in image coordinates (from ML Kit) to crop to the face before inference.
  List<double> generateEmbedding(Uint8List imageBytes, {Rect? faceRect}) {
    if (!_loaded) throw Exception('FaceNet model not loaded');

    final img.Image? image = img.decodeImage(imageBytes);
    if (image == null) throw Exception('Failed to decode image');

    img.Image cropped = image;
    if (faceRect != null) {
      final left = faceRect.left.toInt().clamp(0, image.width - 1);
      final top = faceRect.top.toInt().clamp(0, image.height - 1);
      final w = faceRect.width.toInt().clamp(1, image.width - left);
      final h = faceRect.height.toInt().clamp(1, image.height - top);
      cropped = img.copyCrop(image, x: left, y: top, width: w, height: h);
    }

    final resized = img.copyResize(
      cropped,
      width: inputSize,
      height: inputSize,
    );

    // Prepare input as nested List [1,inputSize,inputSize,3] with normalization to [-1,1]
    final input = List.generate(
      1,
      (_) => List.generate(
        inputSize,
        (y) => List.generate(inputSize, (x) => List.filled(3, 0.0)),
      ),
    );

    for (int y = 0; y < inputSize; y++) {
      for (int x = 0; x < inputSize; x++) {
        final px = resized.getPixel(x, y);
        // Pixel may be a Pixel object in this image package version
        final r = px.r;
        final g = px.g;
        final b = px.b;
        input[0][y][x][0] = (r - 128.0) / 128.0;
        input[0][y][x][1] = (g - 128.0) / 128.0;
        input[0][y][x][2] = (b - 128.0) / 128.0;
      }
    }

    // Prepare output buffer — model returns 512-length embedding
    const int outputDim = 512;
    final output = List.generate(1, (_) => List.filled(outputDim, 0.0));

    _interpreter!.run(input, output);

    final embedding = List<double>.from(
      output[0].map((e) => (e as num).toDouble()),
    );
    return _l2Normalize(embedding);
  }
}
