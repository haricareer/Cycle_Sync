import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/constants/colors.dart';
import '../../models/symptom_model.dart';
import '../../services/firestore_service.dart';

class SymptomHistoryScreen extends StatelessWidget {
  const SymptomHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text("Symptom History")),
      body: user == null
          ? const Center(child: Text("Please log in to see symptom history."))
          : StreamBuilder<List<SymptomModel>>(
              stream: FirestoreService().streamSymptoms(user.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      "Error loading symptoms: ${snapshot.error}",
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }

                final symptoms = snapshot.data ?? [];

                if (symptoms.isEmpty) {
                  return _emptyState();
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: symptoms.length,
                  itemBuilder: (context, index) {
                    final entry = symptoms[index];
                    return _historyCard(entry);
                  },
                );
              },
            ),
    );
  }

  // ---------------- EMPTY STATE ----------------
  Widget _emptyState() {
    return const Center(
      child: Text(
        "No symptom history available",
        style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
      ),
    );
  }

  // ---------------- HISTORY CARD ----------------
  Widget _historyCard(SymptomModel entry) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _dateRow(entry.date),
          const SizedBox(height: 10),
          if (entry.symptoms.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: entry.symptoms.map<Widget>((symptom) {
                return Chip(
                  label: Text(symptom),
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  labelStyle: const TextStyle(color: AppColors.primary),
                );
              }).toList(),
            ),
          if (entry.notes != null && entry.notes!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              "Notes: ${entry.notes}",
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ],
      ),
    );
  }

  // ---------------- DATE ROW ----------------
  Widget _dateRow(DateTime date) {
    return Row(
      children: [
        const Icon(
          Icons.calendar_today,
          size: 16,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 6),
        Text(
          "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ],
    );
  }
}
