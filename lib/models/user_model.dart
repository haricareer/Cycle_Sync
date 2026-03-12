class UserModel {
  final String uid;
  final String name;
  final String email;
  final int? age;
  final int? cycleLength;
  final int? periodDuration;
  final bool doctorAccessEnabled;
  final bool isDoctor;
  final String? designation;
  final String? hospital;
  final String? address;
  final String? phone;
  final List<String> syncedDoctors;
  final List<String> paidDoctors;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.age,
    this.cycleLength,
    this.periodDuration,
    this.doctorAccessEnabled = false,
    this.isDoctor = false,
    this.designation,
    this.hospital,
    this.address,
    this.phone,
    this.syncedDoctors = const [],
    this.paidDoctors = const [],
  });

  // ---------------- FROM MAP (Firestore → App) ----------------
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      age: map['age'],
      cycleLength: map['cycleLength'],
      periodDuration: map['periodDuration'],
      doctorAccessEnabled: map['doctorAccessEnabled'] ?? false,
      isDoctor: map['isDoctor'] ?? false,
      designation: map['designation'],
      hospital: map['hospital'],
      address: map['address'],
      phone: map['phone'],
      syncedDoctors: List<String>.from(map['syncedDoctors'] ?? []),
      paidDoctors: List<String>.from(map['paidDoctors'] ?? []),
    );
  }

  // ---------------- TO MAP (App → Firestore) ----------------
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'age': age,
      'cycleLength': cycleLength,
      'periodDuration': periodDuration,
      'doctorAccessEnabled': doctorAccessEnabled,
      'isDoctor': isDoctor,
      'designation': designation,
      'hospital': hospital,
      'address': address,
      'phone': phone,
      'syncedDoctors': syncedDoctors,
      'paidDoctors': paidDoctors,
    };
  }
}
