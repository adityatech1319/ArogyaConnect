import 'package:flutter/foundation.dart';
import '../models/patient.dart';
import '../helpers/database_helper.dart';

class PatientProvider with ChangeNotifier {
  List<Patient> _patients = [];

  List<Patient> get patients => _patients;

  Future<void> loadPatients() async {
    _patients = await DatabaseHelper.instance.getPatients();
    notifyListeners();
  }

  Future<void> addPatient(Patient patient) async {
    await DatabaseHelper.instance.insertPatient(patient);
    await loadPatients(); // reload after insert
  }

  Future<void> updatePatient(Patient patient) async {
    await DatabaseHelper.instance.updatePatient(patient);
    await loadPatients();
  }

  Future<void> deletePatient(int id) async {
    await DatabaseHelper.instance.deletePatient(id);
    await loadPatients();
  }
}
