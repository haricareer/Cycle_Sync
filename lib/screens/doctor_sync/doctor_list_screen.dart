import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';

class DoctorListScreen extends StatefulWidget {
  const DoctorListScreen({super.key});

  @override
  State<DoctorListScreen> createState() => _DoctorListScreenState();
}

class _DoctorListScreenState extends State<DoctorListScreen> {
  // Dummy data for available doctors
  final List<Map<String, dynamic>> _doctors = [
    {
      "name": "Dr. Sarah Jenkins",
      "specialty": "Gynecologist",
      "hospital": "City Care Hospital",
      "isSynced": true,
    },
    {
      "name": "Dr. Emily Chen",
      "specialty": "Endocrinologist",
      "hospital": "Women's Health Clinic",
      "isSynced": false,
    },
    {
      "name": "Dr. Michael Ross",
      "specialty": "General Physician",
      "hospital": "Metro Medical Center",
      "isSynced": false,
    },
  ];

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
            ..._doctors.asMap().entries.map((entry) {
              int idx = entry.key;
              Map<String, dynamic> doctor = entry.value;
              return _doctorCard(doctor, idx);
            }),
            const SizedBox(height: 24),
            _generateReportButton(),
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
    return Container(
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
              doctor["name"].split(' ')[1][0], // First letter of last name
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              minimumSize: Size.zero,
            ),
            onPressed: () {
              setState(() {
                _doctors[index]["isSynced"] = !_doctors[index]["isSynced"];
              });

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    _doctors[index]["isSynced"]
                        ? "Data sync enabled for ${doctor["name"]}"
                        : "Data sync revoked for ${doctor["name"]}",
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: Text(doctor["isSynced"] ? "Synced" : "Sync Data"),
          ),
        ],
      ),
    );
  }

  // ---------------- GENERATE REPORT BUTTON ----------------
  Widget _generateReportButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: const Icon(Icons.picture_as_pdf, color: AppColors.primary),
        label: const Text(
          "Download PDF Report",
          style: TextStyle(
            fontSize: 16,
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "Generating health report... PDF will be saved to your device.",
              ),
            ),
          );
        },
      ),
    );
  }
}
