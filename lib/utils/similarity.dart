import 'dart:math';

double cosineSimilarity(List<double> e1, List<double> e2) {
  double dot = 0;
  double mag1 = 0;
  double mag2 = 0;

  for (int i = 0; i < e1.length; i++) {
    dot += e1[i] * e2[i];
    mag1 += e1[i] * e1[i];
    mag2 += e2[i] * e2[i];
  }

  return dot / (sqrt(mag1) * sqrt(mag2));
}
