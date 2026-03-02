class CycleModel {
  final String id;                 // document id
  final DateTime startDate;         // period start date
  final DateTime? endDate;          // period end date
  final int cycleLength;            // total cycle length in days
  final String flowIntensity;       // Light / Medium / Heavy
  final DateTime createdAt;

  CycleModel({
    required this.id,
    required this.startDate,
    this.endDate,
    required this.cycleLength,
    required this.flowIntensity,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // ---------------- FROM MAP (Firestore → App) ----------------
  factory CycleModel.fromMap(String id, Map<String, dynamic> map) {
    return CycleModel(
      id: id,
      startDate: DateTime.parse(map['startDate']),
      endDate: map['endDate'] != null
          ? DateTime.parse(map['endDate'])
          : null,
      cycleLength: map['cycleLength'],
      flowIntensity: map['flowIntensity'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  // ---------------- TO MAP (App → Firestore) ----------------
  Map<String, dynamic> toMap() {
    return {
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'cycleLength': cycleLength,
      'flowIntensity': flowIntensity,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
