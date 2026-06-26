import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/camera_service.dart';
import '../services/facenet_service.dart';
import '../services/ml_kit_face_service.dart';
import '../services/firebase_embedding_service.dart';
import '../services/compare_service.dart';
import '../routes/app_routes.dart';
import '../utils/constants.dart';
import '../widgets/primary_button.dart';

class FaceLoginScreen extends StatefulWidget {
  final String? email;
  const FaceLoginScreen({super.key, this.email});

  @override
  State<FaceLoginScreen> createState() => _FaceLoginScreenState();
}

class _FaceLoginScreenState extends State<FaceLoginScreen> {
  final CameraService _cameraService = CameraService();
  final FaceNetService _faceNetService = FaceNetService();
  final MLKitFaceService _mlKitService = MLKitFaceService();

  bool _loading = false;
  String? _error;
  double? _lastSim;

  Future<void> _initIfNeeded() async {
    if (!_cameraService.isReady) await _cameraService.init();
    if (!_faceNetService.isLoaded) await _faceNetService.loadModel();
    if (!_mlKitService.isInitialized) await _mlKitService.init();
  }

  Future<void> _scan() async {
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
      final bbox = face.boundingBox;

      final newEmb = _faceNetService.generateEmbedding(bytes, faceRect: bbox);
      if (newEmb.isEmpty) throw "Face embedding generation failed";

      // Load face embedding from Firestore using UID only
      final stored = await FirebaseEmbeddingService.getEmbeddingForUid(uid);

      if (stored == null) throw "No stored face found";

      final sim = CompareService.cosineSimilarity(newEmb, stored);
      // debug log
      print('Face similarity: $sim');

      if (!mounted) return;

      if (sim >= 0.8) {
        setState(() {
          _lastSim = sim;
        });
        // Show match dialog
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Match!'),
            content: Text(
              'Face verified successfully!\n'
              'Similarity: ${sim.toStringAsFixed(3)}\n'
              'Proceeding to fingerprint...',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pushReplacementNamed(
                    context,
                    AppRoutes.fingerprint,
                    arguments: {'allowed': true},
                  );
                },
                child: const Text('Continue'),
              ),
            ],
          ),
        );
      } else {
        setState(() {
          _lastSim = sim;
          _error = "Face mismatch — score ${sim.toStringAsFixed(3)}";
        });
        // Show mismatch dialog
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Mismatch'),
            content: Text(
              'Face does not match stored face.\n'
              'Similarity: ${sim.toStringAsFixed(3)}\n'
              'Required: 0.8 or higher\n'
              'Please try again.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Retry'),
              ),
            ],
          ),
        );
      }
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
          "Face Login",
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
          if (_lastSim != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'Similarity: ${_lastSim!.toStringAsFixed(3)}',
                style: const TextStyle(color: Colors.white70),
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
              text: _loading ? "PROCESSING..." : "SCAN FACE",
              onTap: _loading ? null : _scan,
            ),
          ),
        ],
      ),
    );
  }
}
