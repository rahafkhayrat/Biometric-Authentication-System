import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/camera_service.dart';
import '../services/facenet_service.dart';
import '../services/ml_kit_face_service.dart';
import '../services/firebase_embedding_service.dart';
import '../routes/app_routes.dart';
import '../utils/constants.dart';
import '../widgets/primary_button.dart';

class FaceRegisterScreen extends StatefulWidget {
  final String? email;
  const FaceRegisterScreen({super.key, this.email});

  @override
  State<FaceRegisterScreen> createState() => _FaceRegisterScreenState();
}

class _FaceRegisterScreenState extends State<FaceRegisterScreen> {
  final CameraService _cameraService = CameraService();
  final FaceNetService _faceNetService = FaceNetService();
  final MLKitFaceService _mlKitService = MLKitFaceService();

  bool _loading = false;
  String? _error;

  Future<void> _initIfNeeded() async {
    try {
      if (!_cameraService.isReady) await _cameraService.init();
      if (!_faceNetService.isLoaded) await _faceNetService.loadModel();
      if (!_mlKitService.isInitialized) await _mlKitService.init();
    } catch (e) {
      throw Exception("Camera/model init failed: $e");
    }
  }

  Future<void> _capture() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _error = "Please login first");
      return;
    }

    final uid = user.uid;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await _initIfNeeded();

      final pic = await _cameraService.takePicture();
      final bytes = await File(pic.path).readAsBytes();

      // Detect face(s) using ML Kit and get bounding box for cropping
      final faces = await _mlKitService.detectFaces(bytes);
      if (faces.isEmpty) throw "No face detected. Please try again.";
      if (faces.length > 1) {
        throw "Multiple faces detected. Show only your face.";
      }

      final face = faces.first;
      final bbox = face.boundingBox; // Rect in image coordinates

      final emb = _faceNetService.generateEmbedding(bytes, faceRect: bbox);
      if (emb.isEmpty) throw "Face embedding generation failed";

      await FirebaseEmbeddingService.saveEmbeddingForUid(uid, emb);

      if (!mounted) return;
      // Show success dialog
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Success!'),
          content: Text(
            'Face embedding stored successfully.\n'
            'Embedding dimension: ${emb.length}\n'
            'Ready for fingerprint authentication.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pushNamed(context, AppRoutes.fingerprint);
              },
              child: const Text('Continue'),
            ),
          ],
        ),
      );
    } catch (e) {
      setState(() => _error = "Error: $e");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _cameraService.dispose();
    _mlKitService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          "Register Face",
          style: TextStyle(color: AppColors.neon),
        ),
        backgroundColor: AppColors.background,
        iconTheme: const IconThemeData(color: AppColors.neon),
      ),
      body: Column(
        children: [
          Expanded(
            child:
                _cameraService.getPreview() ??
                const Center(
                  child: Text(
                    "Camera preview not available",
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(_error!, style: const TextStyle(color: Colors.red)),
            ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: PrimaryButton(
              text: _loading ? "PROCESSING..." : "CAPTURE FACE",
              onTap: _loading ? null : _capture,
            ),
          ),
        ],
      ),
    );
  }
}
