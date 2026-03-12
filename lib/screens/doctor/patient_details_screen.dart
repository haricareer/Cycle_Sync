import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../models/user_model.dart';
import '../../models/cycle_model.dart';
import '../../models/symptom_model.dart';
import '../../services/firestore_service.dart';
import '../chat/chat_screen.dart';
import 'package:intl/intl.dart';

class PatientDetailsScreen extends StatelessWidget {
  final UserModel patient;

  const PatientDetailsScreen({super.key, required this.patient});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(title: Text('${patient.name}\'s Profile'), elevation: 0),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 16),
            _buildInfoCard(),
            const SizedBox(height: 16),
            _buildCycleHistoryHeader(),
            _buildCycleHistoryList(),
            const SizedBox(height: 16),
            _buildSymptomsHeader(),
            _buildSymptomsList(),
            const SizedBox(height: 40),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreen(
                otherUserId: patient.uid,
                otherUserName: patient.name,
              ),
            ),
          );
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.chat, color: Colors.white),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.accent,
            radius: 40,
            child: Text(
              patient.name.isNotEmpty ? patient.name[0].toUpperCase() : '?',
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            patient.name,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            patient.email,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Card(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _infoRow("Age", patient.age?.toString() ?? "N/A"),
              const Divider(),
              _infoRow(
                "Avg Cycle Length",
                patient.cycleLength != null
                    ? "${patient.cycleLength} Days"
                    : "N/A",
              ),
              const Divider(),
              _infoRow(
                "Avg Period Duration",
                patient.periodDuration != null
                    ? "${patient.periodDuration} Days"
                    : "N/A",
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCycleHistoryHeader() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Text(
        "Cycle History",
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildCycleHistoryList() {
    return StreamBuilder<List<CycleModel>>(
      stream: FirestoreService().streamCycles(patient.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return const Center(child: Text("Error loading cycle data."));
        }

        final cycles = snapshot.data ?? [];

        if (cycles.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              "No cycle history logged yet.",
              style: TextStyle(color: AppColors.textSecondary),
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: cycles.length,
          itemBuilder: (context, index) {
            final cycle = cycles[index];
            final startFormat = DateFormat(
              'MMM dd, yyyy',
            ).format(cycle.startDate);
            final endFormat = cycle.endDate != null
                ? DateFormat('MMM dd, yyyy').format(cycle.endDate!)
                : 'Present';

            return Card(
              color: Colors.white,
              elevation: 0,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: const Icon(Icons.water_drop, color: AppColors.primary),
                title: Text(
                  "$startFormat - $endFormat",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text("Flow: ${cycle.flowIntensity}"),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSymptomsHeader() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Text(
        "Recent Symptoms",
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildSymptomsList() {
    return StreamBuilder<List<SymptomModel>>(
      stream: FirestoreService().streamSymptoms(patient.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return const Center(child: Text("Error loading symptoms."));
        }

        final symptoms = snapshot.data ?? [];

        if (symptoms.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              "No layout symptoms logged yet.",
              style: TextStyle(color: AppColors.textSecondary),
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: symptoms.length > 5 ? 5 : symptoms.length, // Show top 5
          itemBuilder: (context, index) {
            final symptom = symptoms[index];
            final dateStr = DateFormat('MMM dd, yyyy').format(symptom.date);

            return Card(
              color: Colors.white,
              elevation: 0,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: const Icon(Icons.healing, color: AppColors.accent),
                title: Text(
                  symptom.symptoms.isNotEmpty
                      ? symptom.symptoms.join(', ')
                      : "Symptom Logging",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(dateStr),
              ),
            );
          },
        );
      },
    );
  }
}
