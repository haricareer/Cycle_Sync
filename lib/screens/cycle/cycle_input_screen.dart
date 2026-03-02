import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/cycle_model.dart';
import '../../services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CycleInputScreen extends StatefulWidget {
  const CycleInputScreen({super.key, this.selectedDate});

  final DateTime? selectedDate;

  @override
  State<CycleInputScreen> createState() => _CycleInputScreenState();
}

class _CycleInputScreenState extends State<CycleInputScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirestoreService _firestoreService = FirestoreService();
  Future<void> _saveCycle() async {
    if (_startDate == null) {
      _showMessage("Please select start date");
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showMessage("User not logged in");
      return;
    }

    final cycleId = FirebaseFirestore.instance.collection('temp').doc().id;

    final cycleLength = _endDate != null
        ? _endDate!.difference(_startDate!).inDays + 1
        : 0;

    final cycle = CycleModel(
      id: cycleId,
      startDate: _startDate!,
      endDate: _endDate,
      cycleLength: cycleLength,
      flowIntensity: _flowIntensity,
    );

    await _firestoreService.addCycle(user.uid, cycle);

    if (mounted) {
      _showMessage("Cycle saved successfully");
      Navigator.pop(context);
    }
  }

  DateTime? _startDate;
  DateTime? _endDate;
  String _flowIntensity = "Medium";

  @override
  void initState() {
    super.initState();
    _startDate = widget.selectedDate;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Log Cycle")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle("Period Dates"),
              const SizedBox(height: 12),
              _datePickerTile(
                label: "Start Date",
                date: _startDate,
                onTap: () => _pickDate(isStart: true),
              ),
              const SizedBox(height: 12),
              _datePickerTile(
                label: "End Date",
                date: _endDate,
                onTap: () => _pickDate(isStart: false),
              ),
              const SizedBox(height: 24),
              _sectionTitle("Flow Intensity"),
              const SizedBox(height: 8),
              _flowSelector(),
              const Spacer(),
              _saveButton(),
            ],
          ),
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

  // ---------------- DATE PICKER TILE ----------------
  Widget _datePickerTile({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return ListTile(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      leading: const Icon(Icons.calendar_today),
      title: Text(label),
      subtitle: Text(
        date == null ? "Select date" : "${date.day}/${date.month}/${date.year}",
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _flowSelector() {
    return RadioGroup<String>(
      groupValue: _flowIntensity,
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _flowIntensity = value;
          });
        }
      },
      child: Column(
        children: ["Light", "Medium", "Heavy"].map((flow) {
          return RadioListTile<String>(
            value: flow,
            title: Text(flow),
            activeColor: AppColors.primary,
          );
        }).toList(),
      ),
    );
  }

  // ---------------- SAVE BUTTON ----------------
  Widget _saveButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _saveCycle,
        child: const Text(
          "Save Cycle",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  // ---------------- DATE PICKER ----------------
  Future<void> _pickDate({required bool isStart}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  // ---------------- MESSAGE ----------------
  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
