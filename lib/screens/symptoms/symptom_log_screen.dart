import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/symptom_model.dart';
import '../../services/firestore_service.dart';

class SymptomLogScreen extends StatefulWidget {
  const SymptomLogScreen({super.key});

  @override
  State<SymptomLogScreen> createState() => _SymptomLogScreenState();
}

class _SymptomLogScreenState extends State<SymptomLogScreen> {
  final TextEditingController _notesController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();
  bool _isLoading = false;

  final Map<String, bool> _symptoms = {
    "Cramps": false,
    "Headache": false,
    "Mood Swings": false,
    "Back Pain": false,
    "Fatigue": false,
    "Nausea": false,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Log Symptoms")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle("Select Symptoms"),
            const SizedBox(height: 12),
            _symptomChecklist(),
            const SizedBox(height: 24),
            _sectionTitle("Additional Notes"),
            const SizedBox(height: 8),
            _notesField(),
            const Spacer(),
            _saveButton(),
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

  // ---------------- SYMPTOM CHECKLIST ----------------
  Widget _symptomChecklist() {
    return Column(
      children: _symptoms.keys.map((symptom) {
        return CheckboxListTile(
          title: Text(symptom),
          activeColor: AppColors.primary,
          value: _symptoms[symptom],
          onChanged: (value) {
            setState(() {
              _symptoms[symptom] = value!;
            });
          },
        );
      }).toList(),
    );
  }

  // ---------------- NOTES FIELD ----------------
  Widget _notesField() {
    return TextFormField(
      controller: _notesController,
      maxLines: 4,
      decoration: const InputDecoration(
        hintText: "Add any additional notes (optional)",
      ),
    );
  }

  // ---------------- SAVE BUTTON ----------------
  Widget _saveButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveSymptoms,
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
                "Save Symptoms",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
      ),
    );
  }

  Future<void> _saveSymptoms() async {
    final selectedSymptoms = _symptoms.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();

    if (selectedSymptoms.isEmpty) {
      _showMessage("Please select at least one symptom");
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showMessage("User not logged in");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final symptomId = FirebaseFirestore.instance.collection('temp').doc().id;
      final symptom = SymptomModel(
        id: symptomId,
        date: DateTime.now(),
        symptoms: selectedSymptoms,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );

      await _firestoreService.addSymptom(user.uid, symptom);

      if (mounted) {
        _showMessage("Symptoms saved successfully");
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        _showMessage("Error saving symptoms: $e");
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // ---------------- MESSAGE ----------------
  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
