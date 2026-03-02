import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/constants/colors.dart';
import '../../core/utils/cycle_calculator.dart';
import '../../services/firestore_service.dart';
import '../../models/cycle_model.dart';

class OvulationScreen extends StatelessWidget {
  const OvulationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text("Ovulation & Fertility")),
      body: user == null
          ? const Center(child: Text("Please log in to see predictions."))
          : StreamBuilder<List<CycleModel>>(
              stream: FirestoreService().streamCycles(user.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return const Center(child: Text("Error loading cycles"));
                }

                final cycles = snapshot.data ?? [];

                if (cycles.isEmpty) {
                  return const Center(
                    child: Text(
                      "Log a cycle first to see ovulation predictions.",
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                // Get most recent cycle to base the prediction on
                final cyclesSorted = List.from(cycles)
                  ..sort(
                    (a, b) => b.startDate.compareTo(a.startDate),
                  ); // descending
                final latestCycle = cyclesSorted.first;

                // Dynamically calculate average cycle length
                final avgCycleLength =
                    CycleCalculator.calculateAverageCycleLength(cycles);

                // Predict ovulation based on next period Date (which functionally is lastPeriodStart + cycleLength - 14)
                final ovulationDate = CycleCalculator.predictOvulation(
                  latestCycle.startDate,
                  avgCycleLength,
                );

                final fertilityWindow = CycleCalculator.getFertilityWindow(
                  ovulationDate,
                );

                final dateFormat = DateFormat('d MMMM yyyy');
                final shortFormat = DateFormat('d MMMM');

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _infoCard(),
                      const SizedBox(height: 24),
                      _sectionTitle("Ovulation Prediction"),
                      const SizedBox(height: 12),
                      _detailCard(
                        title: "Estimated Ovulation Day",
                        value: dateFormat.format(ovulationDate),
                        icon: Icons.brightness_5_outlined,
                      ),
                      const SizedBox(height: 20),
                      _sectionTitle("Fertile Window"),
                      const SizedBox(height: 12),
                      _detailCard(
                        title: "Fertility Period",
                        value:
                            "${shortFormat.format(fertilityWindow['start']!)} – ${shortFormat.format(fertilityWindow['end']!)}",
                        icon: Icons.favorite_border,
                      ),
                      const SizedBox(height: 24),
                      _tipsCard(),
                    ],
                  ),
                );
              },
            ),
    );
  }

  // ---------------- INFO CARD ----------------
  Widget _infoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: const [
          Icon(Icons.info_outline, color: AppColors.primary, size: 28),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              "Ovulation predictions are estimates dynamically calculated from your cycle history. "
              "They may vary depending on individual health conditions.",
              style: TextStyle(color: AppColors.textPrimary, fontSize: 14),
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

  // ---------------- DETAIL CARD ----------------
  Widget _detailCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary, size: 28),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------- TIPS CARD ----------------
  Widget _tipsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            "Helpful Tips",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          SizedBox(height: 10),
          Text("• Maintain a healthy diet and hydration."),
          Text("• Track symptoms for better predictions."),
          Text("• Consult your doctor for irregular cycles."),
        ],
      ),
    );
  }
}
