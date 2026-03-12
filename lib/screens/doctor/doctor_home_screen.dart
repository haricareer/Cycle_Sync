import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/constants/colors.dart';
import '../../models/user_model.dart';
import '../../services/firestore_service.dart';
import 'patient_details_screen.dart';

class DoctorHomeScreen extends StatelessWidget {
  const DoctorHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor Portal'),
        actions: [_profileAction(context)],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder<UserModel?>(
              future: FirestoreService().getUser(
                FirebaseAuth.instance.currentUser!.uid,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Text(
                    "Welcome, Doctor...",
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  );
                }

                final user = snapshot.data;
                final name = user?.name ?? "Doctor";
                final title =
                    user?.designation != null && user!.designation!.isNotEmpty
                    ? user.designation
                    : "Physician";

                return Row(
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: AppColors.primary.withValues(
                        alpha: 0.15,
                      ),
                      foregroundColor: AppColors.primary,
                      child: Text(
                        name.isNotEmpty ? name[0].toUpperCase() : '?',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Welcome, Dr. $name!",
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: AppColors.primary.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Text(
                              title!,
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            const Text(
              "Here are the patients who have shared their cycle data with you.",
              style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 32),
            FutureBuilder<List<UserModel>>(
              future: FirestoreService().getSyncedPatients(
                FirebaseAuth.instance.currentUser!.uid,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final patients = snapshot.data ?? [];

                if (patients.isEmpty) {
                  return Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.monitor_heart_outlined,
                          size: 80,
                          color: AppColors.primary.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "No connected patients yet.",
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: patients.length,
                  itemBuilder: (context, index) {
                    final patient = patients[index];
                    return Card(
                      color: Colors.white,
                      elevation: 0,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: AppColors.primary.withValues(alpha: 0.1),
                        ),
                      ),
                      child: ListTile(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  PatientDetailsScreen(patient: patient),
                            ),
                          );
                        },
                        leading: CircleAvatar(
                          backgroundColor: AppColors.primary.withValues(
                            alpha: 0.2,
                          ),
                          child: Text(
                            patient.name.isNotEmpty
                                ? patient.name[0].toUpperCase()
                                : "?",
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          patient.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          patient.email,
                          style: const TextStyle(fontSize: 12),
                        ),
                        trailing: const Icon(
                          Icons.chevron_right,
                          color: AppColors.primary,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- PROFILE ACTION ----------------
  Widget _profileAction(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const SizedBox();

    return FutureBuilder<UserModel?>(
      future: FirestoreService().getUser(user.uid),
      builder: (context, snapshot) {
        String initial = "?";
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          final name = snapshot.data!.name.trim();
          if (name.isNotEmpty) {
            initial = name[0].toUpperCase();
          }
        } else {
          final email = user.email ?? "";
          if (email.isNotEmpty) {
            initial = email[0].toUpperCase();
          }
        }

        return PopupMenuButton<String>(
          offset: const Offset(0, 50),
          onSelected: (value) async {
            if (value == 'logout') {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (route) => false,
                );
              }
            } else if (value == 'profile') {
              Navigator.pushNamed(context, '/profile');
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: CircleAvatar(
              backgroundColor: AppColors.white,
              foregroundColor: AppColors.primary,
              radius: 18,
              child: Text(
                initial,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            const PopupMenuItem<String>(
              value: 'profile',
              child: ListTile(
                leading: Icon(Icons.person),
                title: Text('My Profile'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem<String>(
              value: 'logout',
              child: ListTile(
                leading: Icon(Icons.logout, color: Colors.red),
                title: Text('Logout', style: TextStyle(color: Colors.red)),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        );
      },
    );
  }
}
