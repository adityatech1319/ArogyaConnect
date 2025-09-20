import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/patient.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ---------------- Patients ----------------

  /// Add a new patient to the database
  Future<void> addPatient(Patient patient, String ashaId) async {
    await _db.collection('patients').add({
      ...patient.toMap(),
      'ashaId': ashaId, // ✅ Link patient to ASHA
      'doctorId': null, // ✅ Initialize doctorId
      'doctorName': null, // ✅ Initialize doctorName
      'createdBy': ashaId,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Update an existing patient's information
  Future<void> updatePatient(String patientId, Patient patient) async {
    await _db.collection('patients').doc(patientId).update(patient.toMap());
  }

  /// Delete a patient from the database
  Future<void> deletePatient(String patientId) async {
    await _db.collection('patients').doc(patientId).delete();
  }

  /// Get all patients in real-time as a stream
  Stream<List<Patient>> getPatients() {
    return _db.collection('patients').snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => Patient.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  /// Get patients assigned to a specific ASHA worker
  Future<List<Map<String, dynamic>>> getAshaPatients(String ashaId) async {
    final snapshot =
        await _db.collection('patients').where('ashaId', isEqualTo: ashaId).get();

    return snapshot.docs
        .map((doc) => {'id': doc.id, ...doc.data()})
        .toList();
  }

  /// Find a patient by phone number
  Future<Patient?> getPatientByPhone(String phone) async {
    final snapshot = await _db
        .collection('patients')
        .where('phone', isEqualTo: phone)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      return Patient.fromMap(
        snapshot.docs.first.data(),
        snapshot.docs.first.id,
      );
    }
    return null;
  }

  /// ✅ Get patient by Firestore document ID (needed for dashboard)
  Future<Map<String, dynamic>?> getPatientById(String patientId) async {
    final doc = await _db.collection('patients').doc(patientId).get();
    return doc.exists ? {'id': doc.id, ...doc.data()!} : null;
  }

  // ---------------- Users (Admin, Doctor, ASHA) ----------------

  /// Create a user with full data (for complex user creation)
  Future<void> createUserWithData(Map<String, dynamic> userData) async {
    await _db.collection('users').add({
      ...userData,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Create a new user with basic credentials (admin dashboard use)
  Future<void> createUser(String username, String password, String role) async {
    await _db.collection('users').add({
      'username': username,
      'password': password, // ⚠️ In production, hash this!
      'role': role,
      'status': role == 'doctor' || role == 'asha' ? 'unavailable' : null,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Find a user by their username
  Future<Map<String, dynamic>?> getUserByUsername(String username) async {
    final snapshot = await _db
        .collection('users')
        .where('username', isEqualTo: username)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      return {'id': snapshot.docs.first.id, ...snapshot.docs.first.data()};
    }
    return null;
  }

  /// ✅ Get user by Firestore document ID
  Future<Map<String, dynamic>?> getUserById(String userId) async {
    final doc = await _db.collection('users').doc(userId).get();
    return doc.exists ? {'id': doc.id, ...doc.data()!} : null;
  }

  /// Get all doctors as a stream
  Stream<List<Map<String, dynamic>>> getDoctors() {
    return _db
        .collection('users')
        .where('role', isEqualTo: 'doctor')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList());
  }

  /// Get all ASHA workers as a stream
  Stream<List<Map<String, dynamic>>> getAshaWorkers() {
    return _db
        .collection('users')
        .where('role', isEqualTo: 'asha')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList());
  }

  /// Update doctor status and duty timings together
  Future<void> updateDoctorStatusAndDuty(
      String userId, String status, String dutyStart, String dutyEnd) async {
    await _db.collection('users').doc(userId).update({
      'status': status,
      'dutyStart': dutyStart,
      'dutyEnd': dutyEnd,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Update only doctor availability status
  Future<void> updateDoctorStatus(String userId, String status) async {
    await _db.collection('users').doc(userId).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Update only doctor duty timings
  Future<void> updateDoctorDuty(String userId, String start, String end) async {
    await _db.collection('users').doc(userId).update({
      'dutyStart': start,
      'dutyEnd': end,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Update ASHA worker availability status
  Future<void> updateAshaStatus(String ashaId, String status) async {
    await _db.collection('users').doc(ashaId).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Update ASHA worker duty timings
  Future<void> updateAshaDuty(String ashaId, String start, String end) async {
    await _db.collection('users').doc(ashaId).update({
      'dutyStart': start,
      'dutyEnd': end,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ---------------- Admin Dashboard Stats ----------------

  /// Get statistics for admin dashboard
  Future<Map<String, int>> getAdminStats() async {
    final doctors =
        await _db.collection('users').where('role', isEqualTo: 'doctor').get();
    final ashas =
        await _db.collection('users').where('role', isEqualTo: 'asha').get();
    final patients = await _db.collection('patients').get();

    return {
      'doctorCount': doctors.size,
      'ashaCount': ashas.size,
      'patientCount': patients.size,
    };
  }

  /// ✅ Get doctor availability counts
  Future<Map<String, int>> getDoctorAvailabilityCounts() async {
    final available = await _db
        .collection('users')
        .where('role', isEqualTo: 'doctor')
        .where('status', isEqualTo: 'available')
        .get();

    final unavailable = await _db
        .collection('users')
        .where('role', isEqualTo: 'doctor')
        .where('status', isEqualTo: 'unavailable')
        .get();

    return {
      'available': available.size,
      'unavailable': unavailable.size,
    };
  }

  /// Count documents in a collection with optional filtering
  Future<int> getCollectionCount(
    String collectionName, {
    String? filterField,
    String? filterValue,
  }) async {
    Query query = _db.collection(collectionName);
    if (filterField != null && filterValue != null) {
      query = query.where(filterField, isEqualTo: filterValue);
    }
    final snapshot = await query.get();
    return snapshot.size;
  }

  /// ✅ Assign doctor (saves both doctorId + doctorName)
 Future<void> assignDoctorToPatient(
    String patientId, String doctorId, String doctorName) async {
  await FirebaseFirestore.instance
      .collection("patients")
      .doc(patientId)
      .update({
    "doctorId": doctorId,
    "doctorName": doctorName,
  });
}


  /// Assign ASHA worker to patient
  Future<void> assignAshaToPatient(String patientId, String ashaId) async {
    await _db.collection('patients').doc(patientId).update({
      'ashaId': ashaId,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Get username by userId
  Future<String?> getUserNameById(String userId) async {
    final doc = await _db.collection('users').doc(userId).get();
    if (doc.exists) {
      return doc['username'];
    }
    return null;
  }

  // ---------------- Symptom Checks ----------------

  /// Add a new symptom check for a patient
  Future<void> addSymptomCheck({
    required String patientId,
    required List<String> symptoms,
    required String result,
    required String emergencyLevel,
    required String checkedBy,
  }) async {
    await _db.collection('symptomChecks').add({
      'patientId': patientId,
      'symptoms': symptoms,
      'result': result,
      'emergencyLevel': emergencyLevel,
      'checkedBy': checkedBy,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Get all symptom checks for a specific patient
  Stream<List<Map<String, dynamic>>> getSymptomChecks(String patientId) {
    return _db
        .collection('symptomChecks')
        .where('patientId', isEqualTo: patientId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList());
  }
}
