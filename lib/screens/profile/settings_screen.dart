import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/theme_notifier.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _darkMode = false;
  bool _biometricsEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
      _darkMode = prefs.getBool('darkMode') ?? false;
      _biometricsEnabled = prefs.getBool('biometricsEnabled') ?? false;
    });
  }

  Future<void> _savePreference(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  void _onChangePassword() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && user.email != null) {
      try {
        await FirebaseAuth.instance.sendPasswordResetEmail(email: user.email!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Password reset email sent! Check your inbox.'),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      }
    }
  }

  void _onDeleteAccount() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to permanently delete your account? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                final user = FirebaseAuth.instance.currentUser;
                if (user != null) {
                  await user.delete();
                }
                if (mounted) {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/login',
                    (route) => false,
                  );
                }
              } on FirebaseAuthException catch (e) {
                if (e.code == 'requires-recent-login' && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Please log out and log back in before deleting your account for security purposes.',
                      ),
                    ),
                  );
                } else if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: ${e.message}')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 20),
        children: [
          _buildSectionHeader("Preferences"),
          _buildSwitchTile(
            "Push Notifications",
            "Get reminders for periods and medications",
            Icons.notifications_active_outlined,
            _notificationsEnabled,
            (val) {
              setState(() => _notificationsEnabled = val);
              _savePreference('notificationsEnabled', val);
            },
          ),
          _buildSwitchTile(
            "Dark Mode",
            "Adjust the appearance of the app",
            Icons.dark_mode_outlined,
            _darkMode,
            (val) {
              setState(() => _darkMode = val);
              _savePreference('darkMode', val);
              appThemeNotifier.value = val ? ThemeMode.dark : ThemeMode.light;
            },
          ),

          const Divider(height: 32),
          _buildSectionHeader("Privacy & Security"),
          _buildSwitchTile(
            "Biometric Authentication",
            "Lock app with Face ID or fingerprint",
            Icons.fingerprint,
            _biometricsEnabled,
            (val) {
              setState(() => _biometricsEnabled = val);
              _savePreference('biometricsEnabled', val);
            },
          ),
          ListTile(
            leading: const Icon(Icons.lock_reset, color: AppColors.primary),
            title: const Text("Change Password"),
            trailing: const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey,
            ),
            onTap: _onChangePassword,
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text(
              "Delete Account",
              style: TextStyle(color: Colors.red),
            ),
            onTap: _onDeleteAccount,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppColors.textSecondary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    Function(bool) onChanged,
  ) {
    return SwitchListTile(
      activeThumbColor: AppColors.primary,
      secondary: Icon(icon, color: AppColors.primary),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      value: value,
      onChanged: onChanged,
    );
  }
}
