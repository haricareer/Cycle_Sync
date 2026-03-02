class ReminderModel {
  final String id;                 // document id
  final String type;               // Period / Ovulation / Medication
  final DateTime reminderTime;     // scheduled time
  final bool isEnabled;            // reminder status
  final DateTime createdAt;

  ReminderModel({
    required this.id,
    required this.type,
    required this.reminderTime,
    this.isEnabled = true,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // ---------------- FROM MAP (Firestore → App) ----------------
  factory ReminderModel.fromMap(String id, Map<String, dynamic> map) {
    return ReminderModel(
      id: id,
      type: map['type'],
      reminderTime: DateTime.parse(map['reminderTime']),
      isEnabled: map['isEnabled'] ?? true,
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  // ---------------- TO MAP (App → Firestore) ----------------
  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'reminderTime': reminderTime.toIso8601String(),
      'isEnabled': isEnabled,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
