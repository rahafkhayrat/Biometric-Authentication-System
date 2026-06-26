import 'dart:math';

class CompareService {
  static double cosineSimilarity(List<double> a, List<double> b) {
    double dot = 0, magA = 0, magB = 0;

    for (int i = 0; i < a.length; i++) {
      dot += a[i] * b[i];
      magA += a[i] * a[i];
      magB += b[i] * b[i];
    }

    return dot / (sqrt(magA) * sqrt(magB));
  }

  /// If similarity > 0.8 → same person
  static bool isSamePerson(List<double> emb1, List<double> emb2) {
    return cosineSimilarity(emb1, emb2) > 0.80;
  }
}
