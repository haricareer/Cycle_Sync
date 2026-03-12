import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/constants/colors.dart';
import '../../services/firestore_service.dart';
import 'doctor_profile_screen.dart';

class DoctorListScreen extends StatefulWidget {
  const DoctorListScreen({super.key});

  @override
  State<DoctorListScreen> createState() => _DoctorListScreenState();
}

class _DoctorListScreenState extends State<DoctorListScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _doctors = [];

  @override
  void initState() {
    super.initState();
    _fetchDoctors();
  }

  Future<void> _fetchDoctors() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final currentUserDoc = await FirestoreService().getUser(user.uid);
      final syncedDoctorsList = currentUserDoc?.syncedDoctors ?? [];
      final paidDoctorsList = currentUserDoc?.paidDoctors ?? [];

      final doctorsList = await FirestoreService().getAllDoctors();
      setState(() {
        _doctors = doctorsList
            .map(
              (doc) => {
                "uid": doc.uid,
                "name": doc.name,
                "specialty": doc.designation ?? "General Physician",
                "hospital": doc.hospital ?? "Not specified",
                "address": doc.address ?? "Not specified",
                "phone": doc.phone ?? "",
                "email": doc.email,
                "isSynced": syncedDoctorsList.contains(doc.uid),
                "isPaid": paidDoctorsList.contains(doc.uid),
              },
            )
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Doctor Sync')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _headerSection(),
            const SizedBox(height: 24),
            _sectionTitle("My Health Providers"),
            const SizedBox(height: 12),
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_doctors.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Text("No health providers registered yet."),
                ),
              )
            else
              ..._doctors.asMap().entries.map((entry) {
                int idx = entry.key;
                Map<String, dynamic> doctor = entry.value;
                return _doctorCard(doctor, idx);
              }),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ---------------- HEADER SECTION ----------------
  Widget _headerSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Row(
            children: [
              Icon(
                Icons.monitor_heart_outlined,
                color: AppColors.primary,
                size: 28,
              ),
              SizedBox(width: 12),
              Text(
                "Health Data Sync",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Text(
            "Safely share your cycle history, symptoms, and fertility logs directly with your trusted healthcare providers.",
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
        ],
      ),
    );
  }

  // ---------------- SECTION TITLE ----------------
  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }

  // ---------------- DOCTOR CARD ----------------
  Widget _doctorCard(Map<String, dynamic> doctor, int index) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DoctorProfileScreen(doctor: doctor),
          ),
        ).then((_) {
          // Refresh state when coming back in case synced status changed
          setState(() {});
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: AppColors.accent,
              radius: 28,
              child: Text(
                doctor["name"].isNotEmpty && doctor["name"].contains(' ')
                    ? doctor["name"].split(' ')[1][0]
                    : doctor["name"].isNotEmpty
                    ? doctor["name"][0]
                    : '?',
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doctor["name"],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    doctor["specialty"],
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    doctor["hospital"],
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: doctor["isSynced"]
                    ? AppColors.white
                    : AppColors.primary,
                foregroundColor: doctor["isSynced"]
                    ? AppColors.primary
                    : AppColors.white,
                side: BorderSide(color: AppColors.primary),
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                minimumSize: Size.zero,
              ),
              onPressed: () async {
                final user = FirebaseAuth.instance.currentUser;
                if (user == null) return;

                final bool willSync = !_doctors[index]["isSynced"];
                final String docUid = _doctors[index]["uid"];

                // UI optimistic update
                setState(() {
                  _doctors[index]["isSynced"] = willSync;
                });

                try {
                  await FirestoreService().toggleDoctorSync(
                    user.uid,
                    docUid,
                    willSync,
                  );
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          willSync
                              ? "Data sync enabled for ${doctor["name"]}"
                              : "Data sync revoked for ${doctor["name"]}",
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                } catch (e) {
                  // Revert if failed
                  if (mounted) {
                    setState(() {
                      _doctors[index]["isSynced"] = !willSync;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Failed to update sync status."),
                      ),
                    );
                  }
                }
              },
              child: Text(doctor["isSynced"] ? "Synced" : "Sync Data"),
            ),
          ],
        ),
      ),
    );
  }
}
