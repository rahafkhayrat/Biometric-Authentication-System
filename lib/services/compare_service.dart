import 'dart:math';

class CompareService {
  static double cosineSimilarity(List<double> a, List<double> b) {
    if (a.length != b.length) return -1;

    double dot = 0;
    double normA = 0;
    double normB = 0;

    for (int i = 0; i < a.length; i++) {
      dot += a[i] * b[i];
      normA += a[i] * a[i];
      normB += b[i] * b[i];
    }

    return dot / (sqrt(normA) * sqrt(normB));
  }

  static bool isSamePerson(
    List<double> a,
    List<double> b, {
    double threshold = 0.8,
  }) {
    final sim = cosineSimilarity(a, b);
    return sim >= threshold;
  }
}
