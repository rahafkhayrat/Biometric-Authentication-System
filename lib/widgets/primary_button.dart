import 'package:flutter/material.dart';
import '../utils/constants.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  const PrimaryButton({required this.text, this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.neon,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: AppColors.neon.withValues(alpha: 0.4), blurRadius: 8, spreadRadius: 1)],
        ),
        child: Text(text, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.background, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
