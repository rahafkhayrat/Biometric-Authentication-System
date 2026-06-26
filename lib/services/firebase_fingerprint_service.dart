import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseFingerprintService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static Future<void> setFingerprintEnrolled(String uid, bool enrolled) async {
    await _db.collection('users').doc(uid).set({
      'fingerprint_enrolled': enrolled,
      'fingerprint_updated': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  static Future<bool> isFingerprintEnrolled(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return false;
    final data = doc.data();
    if (data == null) return false;
    final raw = data['fingerprint_enrolled'];
    if (raw is bool) return raw;
    return false;
  }
}
