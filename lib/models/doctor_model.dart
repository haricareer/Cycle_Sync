class DoctorModel {
  final String id;                     // doctor document id
  final String name;                   // doctor name
  final String specialization;         // gynecologist / family doctor
  final String email;                  // doctor contact email
  final String phone;                  // contact number
  final List<String> assignedUserIds;  // users assigned to this doctor
  final DateTime createdAt;

  DoctorModel({
    required this.id,
    required this.name,
    required this.specialization,
    required this.email,
    required this.phone,
    this.assignedUserIds = const [],
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // ---------------- FROM MAP (Firestore → App) ----------------
  factory DoctorModel.fromMap(String id, Map<String, dynamic> map) {
    return DoctorModel(
      id: id,
      name: map['name'] ?? '',
      specialization: map['specialization'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      assignedUserIds:
          List<String>.from(map['assignedUserIds'] ?? []),
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  // ---------------- TO MAP (App → Firestore) ----------------
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'specialization': specialization,
      'email': email,
      'phone': phone,
      'assignedUserIds': assignedUserIds,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
