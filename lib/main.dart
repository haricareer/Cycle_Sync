import 'package:cycle_sync/screens/dashboard/analytics_screen.dart';
import 'package:cycle_sync/screens/cycle/cycle_calendar_screen.dart';
import 'package:cycle_sync/screens/emergency/emergency_guidance_screen.dart';
import 'package:cycle_sync/screens/fertility/fertility_window_screen.dart';
import 'package:cycle_sync/screens/fertility/ovulation_screen.dart';
import 'package:cycle_sync/screens/reminders/reminder_screen.dart';
import 'package:cycle_sync/screens/doctor_sync/doctor_list_screen.dart';
import 'package:cycle_sync/screens/chatbot/chatbot_screen.dart';
import 'package:cycle_sync/screens/symptoms/symptom_history_screen.dart';
import 'package:cycle_sync/screens/profile/profile_screen.dart';
import 'package:cycle_sync/screens/profile/settings_screen.dart';
import 'package:cycle_sync/screens/profile/about_screen.dart';
import 'package:flutter/material.dart';
import 'package:cycle_sync/core/constants/app_theme.dart';
import 'package:cycle_sync/screens/auth/register_screen.dart';
import 'package:cycle_sync/screens/dashboard/home_screen.dart';
import 'package:cycle_sync/screens/splash/splash_screen.dart';
import 'package:cycle_sync/screens/landing/landing_screen.dart';
import 'package:cycle_sync/screens/auth/login_screen.dart';
import 'package:cycle_sync/screens/auth/email_verification_screen.dart';
import 'package:cycle_sync/screens/doctor/doctor_home_screen.dart';
import 'package:cycle_sync/screens/symptoms/symptom_log_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cycle_sync/firebase_options.dart';
import 'package:cycle_sync/services/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cycle_sync/core/constants/theme_notifier.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationService().init();

  final prefs = await SharedPreferences.getInstance();
  final isDarkMode = prefs.getBool('darkMode') ?? false;
  appThemeNotifier.value = isDarkMode ? ThemeMode.dark : ThemeMode.light;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: appThemeNotifier,
      builder: (context, ThemeMode currentMode, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: currentMode,
          initialRoute: '/',
          routes: {
            '/': (context) => const SplashScreen(),
            '/landing': (context) => const LandingScreen(),
            '/login': (context) => const LoginScreen(),
            '/register': (context) => const RegisterScreen(),
            '/home': (context) => const HomeScreen(),
            '/cycle-calendar': (context) => const CycleCalendarScreen(),
            '/analytics': (context) => const AnalyticsScreen(),
            '/symptoms': (context) => const SymptomLogScreen(),
            '/symptom-history': (context) => const SymptomHistoryScreen(),
            '/reminders': (context) => const ReminderScreen(),
            '/emergency': (context) => const EmergencyGuidanceScreen(),
            '/ovulation': (context) => const OvulationScreen(),
            '/fertility': (context) => const FertilityWindowScreen(),
            '/doctor': (context) => const DoctorListScreen(),
            '/chatbot': (context) => const ChatbotScreen(),
            '/profile': (context) => const ProfileScreen(),
            '/settings': (context) => const SettingsScreen(),
            '/about': (context) => const AboutScreen(),
            '/verify-email': (context) => const EmailVerificationScreen(),
            '/doctor-home': (context) => const DoctorHomeScreen(),
          },
        );
      },
    );
  }
}
