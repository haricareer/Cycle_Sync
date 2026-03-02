import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../services/notification_service.dart';

class ReminderScreen extends StatefulWidget {
  const ReminderScreen({super.key});

  @override
  State<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen> {
  // Dummy reminder data utilizing TimeOfDay
  final List<Map<String, dynamic>> _reminders = [
    {
      "title": "Period Reminder",
      "time": const TimeOfDay(hour: 8, minute: 0),
      "enabled": true,
    },
    {
      "title": "Ovulation Reminder",
      "time": const TimeOfDay(hour: 9, minute: 0),
      "enabled": false,
    },
    {
      "title": "Medication Reminder",
      "time": const TimeOfDay(hour: 22, minute: 0),
      "enabled": true,
    },
  ];

  @override
  void initState() {
    super.initState();
    _rescheduleAll();
  }

  void _rescheduleAll() {
    for (int i = 0; i < _reminders.length; i++) {
      _applyNotification(i, _reminders[i]);
    }
  }

  void _applyNotification(int id, Map<String, dynamic> reminder) {
    if (reminder["enabled"]) {
      // Handle hot-reload state where time might still be a String
      TimeOfDay timeToSchedule;
      if (reminder["time"] is String) {
        timeToSchedule = const TimeOfDay(hour: 8, minute: 0);
        reminder["time"] = timeToSchedule;
      } else {
        timeToSchedule = reminder["time"] as TimeOfDay;
      }

      NotificationService().scheduleNotification(
        id: id,
        title: reminder["title"],
        body: "It's time for your ${reminder["title"].toLowerCase()}!",
        time: timeToSchedule,
      );
    } else {
      NotificationService().cancelNotification(id);
    }
  }

  Future<void> _editTime(int index) async {
    final Map<String, dynamic> reminder = _reminders[index];
    final TimeOfDay? newTime = await showTimePicker(
      context: context,
      initialTime: reminder["time"],
    );

    if (newTime != null) {
      setState(() {
        _reminders[index]["time"] = newTime;
        _reminders[index]["enabled"] = true; // Auto enable on time change
      });
      _applyNotification(index, _reminders[index]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Reminders")),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () {
          _showAddReminderDialog();
        },
        child: const Icon(Icons.add),
      ),
      body: _reminders.isEmpty ? _emptyState() : _reminderList(),
    );
  }

  // ---------------- REMINDER LIST ----------------
  Widget _reminderList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _reminders.length,
      itemBuilder: (context, index) {
        final reminder = _reminders[index];
        return _reminderCard(reminder, index);
      },
    );
  }

  // ---------------- REMINDER CARD ----------------
  Widget _reminderCard(Map<String, dynamic> reminder, int index) {
    return GestureDetector(
      onTap: () => _editTime(index),
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _reminderInfo(reminder),
            Switch(
              activeThumbColor: AppColors.primary,
              value: reminder["enabled"],
              onChanged: (value) {
                setState(() {
                  _reminders[index]["enabled"] = value;
                });
                _applyNotification(index, _reminders[index]);
              },
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- REMINDER INFO ----------------
  Widget _reminderInfo(Map<String, dynamic> reminder) {
    TimeOfDay t;
    if (reminder["time"] is String) {
      t = const TimeOfDay(hour: 8, minute: 0);
      reminder["time"] = t; // Update it internally so it stops crashing
    } else {
      t = reminder["time"] as TimeOfDay;
    }

    final timeStr = t.format(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          reminder["title"],
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "Time: $timeStr (Tap to Edit)",
          style: const TextStyle(color: AppColors.textSecondary),
        ),
      ],
    );
  }

  // ---------------- EMPTY STATE ----------------
  Widget _emptyState() {
    return const Center(
      child: Text(
        "No reminders added",
        style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
      ),
    );
  }

  // ---------------- ADD REMINDER DIALOG ----------------
  void _showAddReminderDialog() {
    String selectedType = "Period Reminder";

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add Reminder"),
          content: DropdownButtonFormField<String>(
            initialValue: selectedType,
            items: const [
              DropdownMenuItem(
                value: "Period Reminder",
                child: Text("Period Reminder"),
              ),
              DropdownMenuItem(
                value: "Ovulation Reminder",
                child: Text("Ovulation Reminder"),
              ),
              DropdownMenuItem(
                value: "Medication Reminder",
                child: Text("Medication Routine"),
              ),
              DropdownMenuItem(
                value: "PMS Prediction",
                child: Text("PMS Prediction"),
              ),
              DropdownMenuItem(
                value: "Doctor Appointment",
                child: Text("Doctor Appointment"),
              ),
            ],
            onChanged: (value) {
              selectedType = value!;
            },
            decoration: const InputDecoration(labelText: "Reminder Type"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                final newId = _reminders.length;
                final newReminder = {
                  "title": selectedType,
                  "time": const TimeOfDay(hour: 8, minute: 0),
                  "enabled": true,
                };

                setState(() {
                  _reminders.add(newReminder);
                });
                _applyNotification(newId, newReminder);
                Navigator.pop(context);
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }
}
