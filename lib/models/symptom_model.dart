class SymptomModel {
  final String id;                     // document id
  final DateTime date;                 // date of symptom log
  final List<String> symptoms;         // list of symptoms
  final String? notes;                 // optional notes
  final DateTime createdAt;

  SymptomModel({
    required this.id,
    required this.date,
    required this.symptoms,
    this.notes,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // ---------------- FROM MAP (Firestore → App) ----------------
  factory SymptomModel.fromMap(String id, Map<String, dynamic> map) {
    return SymptomModel(
      id: id,
      date: DateTime.parse(map['date']),
      symptoms: List<String>.from(map['symptoms'] ?? []),
      notes: map['notes'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  // ---------------- TO MAP (App → Firestore) ----------------
  Map<String, dynamic> toMap() {
    return {
      'date': date.toIso8601String(),
      'symptoms': symptoms,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
