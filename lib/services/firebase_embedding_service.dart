import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseEmbeddingService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static Future<void> saveEmbeddingForUid(String uid, List<double> emb) async {
    await _db.collection("users").doc(uid).set({
      "embedding": emb,
      "updated": FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  static Future<List<double>?> getEmbeddingForUid(String uid) async {
    final doc = await _db.collection("users").doc(uid).get();
    if (!doc.exists) return null;

    final data = doc.data();
    final raw = data?["embedding"];
    if (raw == null) return null;

    return List<double>.from((raw as List).map((e) => (e as num).toDouble()));
  }
}
