import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/strings.dart';
import '../../services/firestore_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateNext();
  }

  void _navigateNext() {
    Timer(const Duration(seconds: 3), () async {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        if (user.emailVerified) {
          final userModel = await FirestoreService().getUser(user.uid);
          if (!mounted) return;
          if (userModel != null && userModel.isDoctor) {
            Navigator.pushReplacementNamed(context, '/doctor-home');
          } else {
            Navigator.pushReplacementNamed(context, '/home');
          }
        } else {
          Navigator.pushReplacementNamed(context, '/verify-email');
        }
      } else {
        // First time or logged out
        Navigator.pushReplacementNamed(context, '/landing');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [_appIcon(), const SizedBox(height: 24), _appName()],
        ),
      ),
    );
  }

  Widget _appIcon() {
    return Container(
      height: 100,
      width: 100,
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.favorite, size: 60, color: AppColors.white),
    );
  }

  Widget _appName() {
    return Text(
      AppStrings.appName,
      style: const TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.bold,
        color: AppColors.white,
        letterSpacing: 1.2,
      ),
    );
  }
}
