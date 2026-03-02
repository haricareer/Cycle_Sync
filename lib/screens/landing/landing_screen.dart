import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/strings.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(elevation: 0),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),
              _appIcon(),
              const SizedBox(height: 30),
              _title(),
              const SizedBox(height: 16),
              _subtitle(),
              const Spacer(),
              _loginButton(context),
              const SizedBox(height: 16),
              _registerButton(context),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- APP ICON ----------------
  Widget _appIcon() {
    return Container(
      height: 110,
      width: 110,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.favorite_outline,
        size: 60,
        color: AppColors.primary,
      ),
    );
  }

  // ---------------- TITLE ----------------
  Widget _title() {
    return Text(
      AppStrings.appName,
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }

  // ---------------- SUBTITLE ----------------
  Widget _subtitle() {
    return Text(
      "Smart tracking of menstrual cycle,\novulation & fertility health",
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 16,
        color: AppColors.textSecondary,
        height: 1.4,
      ),
    );
  }

  // ---------------- LOGIN BUTTON ----------------
  Widget _loginButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        onPressed: () {
          Navigator.pushNamed(context, '/login');
        },
        child: const Text(
          "Login",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.white,
          ),
        ),
      ),
    );
  }

  // ---------------- REGISTER BUTTON ----------------
  Widget _registerButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        onPressed: () {
          Navigator.pushNamed(context, '/register');
        },
        child: const Text(
          "Create Account",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}
