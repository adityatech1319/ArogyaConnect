import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/patient.dart';
import '../helpers/database_helper.dart';
import 'dart:io';

class PatientProvider with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  List<Patient> _patients = [];

  List<Patient> get patients => _patients;

  /// Helper: check internet
  Future<bool> _hasInternet() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  /// Load patients (prefers Firestore, falls back to SQLite)
  Future<void> loadPatients() async {
    if (await _hasInternet()) {
      try {
        final snapshot = await _db.collection('patients').get();
        _patients = snapshot.docs.map((doc) => Patient.fromMap(doc.data(), doc.id)).toList();

        // ✅ also save to SQLite for offline use
        for (var p in _patients) {
          await DatabaseHelper.instance.insertOrUpdatePatient(p);
        }
      } catch (e) {
        debugPrint("Firestore load failed: $e");
        _patients = await DatabaseHelper.instance.getPatients();
      }
    } else {
      // offline → load from SQLite
      _patients = await DatabaseHelper.instance.getPatients();
    }

    notifyListeners();
  }

  /// Add new patient
  Future<void> addPatient(Patient patient) async {
    if (await _hasInternet()) {
      // Save to Firestore
      final docRef = await _db.collection('patients').add(patient.toMap());

      // Save to SQLite with Firestore ID
      final syncedPatient = Patient(
        id: docRef.id,
        name: patient.name,
        age: patient.age,
        weight: patient.weight,
        height: patient.height,
        gender: patient.gender,
        address: patient.address,
        phone: patient.phone,
        lastAppointmentDate: patient.lastAppointmentDate,
      );
      await DatabaseHelper.instance.insertOrUpdatePatient(syncedPatient);
    } else {
      // Offline → save locally with temporary ID
      await DatabaseHelper.instance.insertPatient(patient);
    }
    await loadPatients();
  }

  /// Update patient
  Future<void> updatePatient(Patient patient) async {
    if (await _hasInternet()) {
      await _db.collection('patients').doc(patient.id).update(patient.toMap());
      await DatabaseHelper.instance.insertOrUpdatePatient(patient);
    } else {
      await DatabaseHelper.instance.updatePatient(patient);
    }
    await loadPatients();
  }

  /// Delete patient
  Future<void> deletePatient(String id) async {
    if (await _hasInternet()) {
      await _db.collection('patients').doc(id).delete();
    }
    await DatabaseHelper.instance.deletePatient(id);
    await loadPatients();
  }
}
