import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../routes/app_routes.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();

    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // زر Logout المؤقت
                  InkWell(
                    onTap: () => _logout(context),
                    child: const Icon(
                      Icons.logout,
                      color: Colors.redAccent,
                      size: 28,
                    ),
                  ),
                  Row(
                    children: const [
                      Icon(Icons.settings, color: AppColors.neon, size: 28),
                      SizedBox(width: 12),
                      Icon(Icons.info_outline, color: AppColors.neon, size: 28),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 40),

              const Text(
                "BIOMETRIC\nSYSTEM",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.neon,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),

              const SizedBox(height: 6),
              const Text(
                "Secure Authentication",
                style: TextStyle(color: AppColors.textLight, fontSize: 14),
              ),

              const SizedBox(height: 40),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 22),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.glow, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.neon.withOpacity(0.4),
                      blurRadius: 12,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: const Text(
                  "CONNECTED",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.neon,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 60),

              _menuButton(
                text: "ENROLL USER",
                icon: Icons.person_add_alt,
                onTap: () =>
                    Navigator.pushNamed(context, AppRoutes.faceRegister),
              ),

              const SizedBox(height: 20),

              _menuButton(
                text: "IDENTIFY USER",
                icon: Icons.face,
                onTap: () => Navigator.pushNamed(context, AppRoutes.faceLogin),
              ),

              const SizedBox(height: 20),

              _menuButton(
                text: "TEST SQLITE",
                icon: Icons.storage,
                onTap: () => Navigator.pushNamed(context, '/sqlite_test'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _menuButton({
  required String text,
  required IconData icon,
  required VoidCallback onTap,
}) {
  return InkWell(
    onTap: onTap,
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: AppColors.buttonDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.textLight, size: 24),
          const SizedBox(width: 12),
          Text(
            text,
            style: const TextStyle(
              color: AppColors.textLight,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ),
  );
}
