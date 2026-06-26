import 'package:flutter/material.dart';
import '../utils/constants.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool obscure;
  final IconData icon;

  const CustomTextField({required this.controller, required this.hint, this.obscure = false, required this.icon, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: AppColors.buttonDark, borderRadius: BorderRadius.circular(12)),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        style: const TextStyle(color: AppColors.textLight),
        decoration: InputDecoration(prefixIcon: Icon(icon, color: AppColors.neon), hintText: hint, hintStyle: const TextStyle(color: Colors.white60), border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(vertical: 18)),
      ),
    );
  }
}
