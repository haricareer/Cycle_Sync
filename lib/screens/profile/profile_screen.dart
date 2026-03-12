import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/constants/colors.dart';
import '../../models/user_model.dart';
import '../../services/firestore_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: user == null
          ? const Center(child: Text("Not logged in."))
          : FutureBuilder<UserModel?>(
              future: FirestoreService().getUser(user.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return const Center(child: Text("Error fetching profile."));
                }

                final userModel = snapshot.data;
                final name = userModel?.name ?? 'Unknown';
                final email = userModel?.email ?? user.email ?? 'Unknown';

                String initial = "?";
                if (name.isNotEmpty) {
                  initial = name[0].toUpperCase();
                } else if (email.isNotEmpty) {
                  initial = email[0].toUpperCase();
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: AppColors.primary.withValues(
                          alpha: 0.15,
                        ),
                        foregroundColor: AppColors.primary,
                        child: Text(
                          initial,
                          style: const TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        email,
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildStatsRow(userModel),
                      const SizedBox(height: 32),
                      _buildProfileItem(Icons.settings, "Settings", () {
                        Navigator.pushNamed(context, '/settings');
                      }),
                      _buildProfileItem(Icons.info_outline, "About App", () {
                        Navigator.pushNamed(context, '/about');
                      }),
                      _buildProfileItem(Icons.logout, "Logout", () async {
                        await FirebaseAuth.instance.signOut();
                        if (context.mounted) {
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/login',
                            (route) => false,
                          );
                        }
                      }, isDestructive: true),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildProfileItem(
    IconData icon,
    String title,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? Colors.red : AppColors.primary,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? Colors.red : AppColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey,
      ),
      onTap: onTap,
    );
  }

  Widget _buildStatsRow(UserModel? userModel) {
    if (userModel?.isDoctor == true) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatCard(
            "Specialty",
            userModel?.designation?.isNotEmpty == true
                ? userModel!.designation!
                : "-",
          ),
          _buildStatCard(
            "Hospital",
            userModel?.hospital?.isNotEmpty == true
                ? userModel!.hospital!
                : "-",
          ),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatCard("Age", userModel?.age?.toString() ?? "-"),
        _buildStatCard("Cycle", "${userModel?.cycleLength ?? '-'} d"),
        _buildStatCard("Period", "${userModel?.periodDuration ?? '-'} d"),
      ],
    );
  }

  Widget _buildStatCard(String label, String value) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
