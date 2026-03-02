import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/firestore_service.dart';
import '../../models/cycle_model.dart';
import '../../models/symptom_model.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  bool _isLoading = true;
  int _avgCycleLength = 0;
  double _regularity = 0.0;
  int _totalCycles = 0;
  String _mostFrequentSymptom = "Not enough data";
  Map<String, double> _symptomFreq = {};

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    final firestore = FirestoreService();
    // Use Future.wait to fetch both simultaneously for better performance
    final results = await Future.wait([
      firestore.getCycles(user.uid),
      firestore.getSymptoms(user.uid),
    ]);

    final cycles = results[0] as List<CycleModel>;
    final symptoms = results[1] as List<SymptomModel>;

    if (!mounted) return;

    if (cycles.isEmpty) {
      setState(() => _isLoading = false);
      return;
    }

    _totalCycles = cycles.length;

    // 1. Calculations for Average Cycle Length (Distance between start dates)
    if (cycles.length >= 2) {
      // Sort cycles by date ascending (oldest first) to calculate intervals
      cycles.sort((a, b) => a.startDate.compareTo(b.startDate));

      int totalCycleLength = 0;
      int regularCount = 0;
      List<int> cycleLengths = [];

      for (int i = 0; i < cycles.length - 1; i++) {
        final length = cycles[i + 1].startDate
            .difference(cycles[i].startDate)
            .inDays;
        totalCycleLength += length;
        cycleLengths.add(length);
      }

      int calculatedAvgCycle = (totalCycleLength / (cycles.length - 1)).round();
      _avgCycleLength = calculatedAvgCycle;

      // 3. Regularity calculations (defined as being within 3 days of average)
      for (int length in cycleLengths) {
        if ((length - calculatedAvgCycle).abs() <= 3) {
          regularCount++;
        }
      }
      _regularity = regularCount / cycleLengths.length;
    } else {
      // Default / Placeholder assumption if only 1 cycle is logged
      _avgCycleLength = 28;
      _regularity = 1.0;
    }

    // 4. Symptoms Frequency Calculations
    Map<String, int> counts = {};
    for (var s in symptoms) {
      for (var sym in s.symptoms) {
        counts[sym] = (counts[sym] ?? 0) + 1;
      }
    }

    if (symptoms.isNotEmpty && counts.isNotEmpty) {
      int totalSymptoms = symptoms.length;
      counts.forEach((key, value) {
        // frequency = appearances / total logged symptom days
        _symptomFreq[key] = value / totalSymptoms;
      });

      // Sort by frequency
      var sortedEntries = _symptomFreq.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      _symptomFreq = Map.fromEntries(sortedEntries);
      _mostFrequentSymptom = _symptomFreq.keys.first;
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text("Analytics")),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Analytics")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle("Cycle Statistics"),
            const SizedBox(height: 12),
            _statCard(
              title: "Average Cycle Length",
              // Handle default 0 display gracefully
              value: _avgCycleLength > 0
                  ? "$_avgCycleLength Days"
                  : "Not enough data",
              icon: Icons.calendar_today,
            ),
            _statCard(
              title: "Total Cycles",
              value: _totalCycles > 0
                  ? "$_totalCycles Cycles"
                  : "Not enough data",
              icon: Icons.repeat,
            ),
            _statCard(
              title: "Most Frequent Symptom",
              value: _mostFrequentSymptom,
              icon: Icons.healing,
            ),
            const SizedBox(height: 24),

            _sectionTitle("Cycle Regularity"),
            const SizedBox(height: 12),
            _progressCard(
              label: "Regular Cycles",
              percentage: _regularity,
              color: AppColors.primary,
            ),
            const SizedBox(height: 24),

            _sectionTitle("Symptoms Frequency"),
            const SizedBox(height: 12),
            if (_symptomFreq.isEmpty)
              const Text(
                "No symptom data logged yet.",
                style: TextStyle(color: Colors.grey),
              ),
            ..._symptomFreq.entries
                .take(5)
                .map((e) => _symptomBar(e.key, e.value)),
          ],
        ),
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

  // ---------------- STAT CARD ----------------
  Widget _statCard({
    required String title,
    required String value,
    required IconData icon,
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
        children: [
          Icon(icon, size: 32, color: AppColors.primary),
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
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------- PROGRESS CARD ----------------
  Widget _progressCard({
    required String label,
    required double percentage,
    required Color color,
  }) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: percentage,
            backgroundColor: Colors.grey.shade300,
            color: color,
            minHeight: 8,
          ),
          const SizedBox(height: 6),
          Text("${(percentage * 100).toInt()}%"),
        ],
      ),
    );
  }

  // ---------------- SYMPTOM BAR ----------------
  Widget _symptomBar(String label, double value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label),
          const SizedBox(height: 6),
          LinearProgressIndicator(
            value: value,
            backgroundColor: Colors.grey.shade300,
            color: AppColors.accent,
            minHeight: 6,
          ),
        ],
      ),
    );
  }
}
