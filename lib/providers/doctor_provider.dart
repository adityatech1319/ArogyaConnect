// lib/providers/doctor_provider.dart
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Doctor {
  final String id;
  final String name;
  final String specialization;
  final String phone;
  final String email;

  Doctor({
    required this.id,
    required this.name,
    required this.specialization,
    required this.phone,
    required this.email,
  });

  factory Doctor.fromMap(Map<String, dynamic> data, String documentId) {
    return Doctor(
      id: documentId,
      name: data['name'] ?? '',
      specialization: data['specialization'] ?? '',
      phone: data['phone'] ?? '',
      email: data['email'] ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'specialization': specialization,
        'phone': phone,
        'email': email,
      };
}

class DoctorProvider with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  List<Doctor> _doctors = [];
  bool _loading = false;

  List<Doctor> get doctors => _doctors;
  bool get loading => _loading;

  Future<void> fetchDoctors() async {
    _loading = true;
    notifyListeners();
    try {
      final snapshot = await _db.collection('doctors').get();
      _doctors = snapshot.docs
          .map((d) => Doctor.fromMap(d.data(), d.id))
          .toList(growable: false);
    } catch (e) {
      // handle/log
      _doctors = [];
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // add, update, delete helpers if needed...
}
