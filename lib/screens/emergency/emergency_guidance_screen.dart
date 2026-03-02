import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/colors.dart';

class EmergencyGuidanceScreen extends StatelessWidget {
  const EmergencyGuidanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Emergency Guidance")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _alertBanner(),
            const SizedBox(height: 20),

            _sectionTitle("When to Seek Immediate Help"),
            const SizedBox(height: 12),
            _warningCard(
              icon: Icons.warning_amber_rounded,
              title: "Severe Bleeding",
              description:
                  "Soaking through pads or tampons every hour for several hours.",
            ),
            _warningCard(
              icon: Icons.warning_amber_rounded,
              title: "Severe Pain",
              description:
                  "Intense pelvic or abdominal pain not relieved by medication.",
            ),
            _warningCard(
              icon: Icons.warning_amber_rounded,
              title: "Missed Periods",
              description:
                  "Missing periods for more than 3 months without known cause.",
            ),
            _warningCard(
              icon: Icons.warning_amber_rounded,
              title: "Sudden Symptoms",
              description: "Dizziness, fainting, fever, or unusual discharge.",
            ),

            const SizedBox(height: 24),
            _sectionTitle("Quick Actions"),
            const SizedBox(height: 12),
            _actionButton(
              icon: Icons.local_hospital,
              label: "Contact Doctor",
              onTap: () {
                Navigator.pushNamed(context, '/doctor');
              },
            ),
            const SizedBox(height: 12),
            _actionButton(
              icon: Icons.phone_in_talk,
              label: "Emergency Call",
              onTap: () async {
                final Uri url = Uri(scheme: 'tel', path: '911');
                if (await canLaunchUrl(url)) {
                  await launchUrl(url);
                } else {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Could not open dialer.')),
                    );
                  }
                }
              },
            ),
            const SizedBox(height: 24),

            _disclaimer(),
          ],
        ),
      ),
    );
  }

  // ---------------- ALERT BANNER ----------------
  Widget _alertBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: const [
          Icon(Icons.health_and_safety, color: Colors.red, size: 30),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              "If you feel your condition is life-threatening, seek immediate medical care.",
              style: TextStyle(fontWeight: FontWeight.w600, color: Colors.red),
            ),
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

  // ---------------- WARNING CARD ----------------
  Widget _warningCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.red),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- ACTION BUTTON ----------------
  Widget _actionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon),
        label: Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
      ),
    );
  }

  // ---------------- DISCLAIMER ----------------
  Widget _disclaimer() {
    return Text(
      "Disclaimer: This app provides guidance only and does not replace professional medical advice.",
      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
      textAlign: TextAlign.center,
    );
  }
}
