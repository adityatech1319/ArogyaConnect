// lib/helpers/firebase_helper.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:arogyaconnect/core/constants.dart';
import 'package:arogyaconnect/models/patient.dart';

class FirebaseHelper {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 🔹 Get user by username
  Future<Map<String, dynamic>?> getUserByUsername(String username) async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.usersCollection)
          .where('username', isEqualTo: username)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.first.data();
      }
      return null;
    } catch (e) {
      print("❌ Error in getUserByUsername: $e");
      return null;
    }
  }

  // 🔹 Get user by ID
  Future<Map<String, dynamic>?> getUserById(String userId) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .get();

      return doc.data();
    } catch (e) {
      print("❌ Error in getUserById: $e");
      return null;
    }
  }

  // 🔹 Get patient by phone
  Future<Patient?> getPatientByPhone(String phone) async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.patientsCollection)
          .where('phone', isEqualTo: phone)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final doc = snapshot.docs.first;
        return Patient.fromMap(doc.data(), doc.id);
      }
      return null;
    } catch (e) {
      print("❌ Error in getPatientByPhone: $e");
      return null;
    }
  }

  // 🔹 Get patients assigned to an ASHA worker
  Future<List<Patient>> getAshaPatients(String ashaId) async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.patientsCollection)
          .where('ashaId', isEqualTo: ashaId)
          .get();

      return snapshot.docs
          .map((doc) => Patient.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print("❌ Error in getAshaPatients: $e");
      return [];
    }
  }

  // 🔹 Add new patient
  Future<void> addPatient(Patient patient, String ashaId) async {
    try {
      await _firestore.collection(AppConstants.patientsCollection).add({
        ...patient.toMap(),
        'ashaId': ashaId,
      });
    } catch (e) {
      print("❌ Error in addPatient: $e");
    }
  }

  // 🔹 Update patient
  Future<void> updatePatient(String patientId, Patient updated) async {
    try {
      await _firestore
          .collection(AppConstants.patientsCollection)
          .doc(patientId)
          .update(updated.toMap());
    } catch (e) {
      print("❌ Error in updatePatient: $e");
    }
  }

  // 🔹 Update ASHA status
  Future<void> updateAshaStatus(String ashaId, String status) async {
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(ashaId)
          .update({'status': status});
    } catch (e) {
      print("❌ Error in updateAshaStatus: $e");
    }
  }

  // 🔹 Update ASHA duty timings
  Future<void> updateAshaDuty(String ashaId, String start, String end) async {
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(ashaId)
          .update({'dutyStart': start, 'dutyEnd': end});
    } catch (e) {
      print("❌ Error in updateAshaDuty: $e");
    }
  }
}
