import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/cycle_model.dart';
import '../models/symptom_model.dart';
import '../models/reminder_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ============================================================
  // USER
  // ============================================================

  Future<void> saveUser(UserModel user) async {
    await _firestore.collection('users').doc(user.uid).set(user.toMap());
  }

  Future<UserModel?> getUser(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();

    if (doc.exists) {
      return UserModel.fromMap(doc.data()!);
    }
    return null;
  }

  // ============================================================
  // CYCLES
  // ============================================================

  Future<void> addCycle(String uid, CycleModel cycle) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('cycles')
        .doc(cycle.id)
        .set(cycle.toMap());
  }

  Future<List<CycleModel>> getCycles(String uid) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('cycles')
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => CycleModel.fromMap(doc.id, doc.data()))
        .toList();
  }

  Stream<List<CycleModel>> streamCycles(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('cycles')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => CycleModel.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  // ============================================================
  // SYMPTOMS
  // ============================================================

  Future<void> addSymptom(String uid, SymptomModel symptom) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('symptoms')
        .doc(symptom.id)
        .set(symptom.toMap());
  }

  Future<List<SymptomModel>> getSymptoms(String uid) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('symptoms')
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => SymptomModel.fromMap(doc.id, doc.data()))
        .toList();
  }

  Stream<List<SymptomModel>> streamSymptoms(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('symptoms')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => SymptomModel.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  // ============================================================
  // REMINDERS
  // ============================================================

  Future<void> addReminder(String uid, ReminderModel reminder) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('reminders')
        .doc(reminder.id)
        .set(reminder.toMap());
  }

  Future<List<ReminderModel>> getReminders(String uid) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('reminders')
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => ReminderModel.fromMap(doc.id, doc.data()))
        .toList();
  }
}
