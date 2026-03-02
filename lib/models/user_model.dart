class UserModel {
  final String uid;
  final String name;
  final String email;
  final int? age;
  final bool doctorAccessEnabled;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.age,
    this.doctorAccessEnabled = false,
  });

  // ---------------- FROM MAP (Firestore → App) ----------------
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      age: map['age'],
      doctorAccessEnabled: map['doctorAccessEnabled'] ?? false,
    );
  }

  // ---------------- TO MAP (App → Firestore) ----------------
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'age': age,
      'doctorAccessEnabled': doctorAccessEnabled,
    };
  }
}
