import 'package:cloud_firestore/cloud_firestore.dart';

class Patient {
  final String id;
  final String name;
  final int age;
  final double weight;
  final double height;
  final String gender;
  final String address;
  final String phone;
  final DateTime? lastAppointmentDate;

  /// 🔹 New fields for linking doctor + ASHA
  final String? doctorId;
  final String? doctorName; // ✅ Added for storing assigned doctor name
  final String? ashaId;

  Patient({
    required this.id,
    required this.name,
    required this.age,
    required this.weight,
    required this.height,
    required this.gender,
    required this.address,
    required this.phone,
    this.lastAppointmentDate,
    this.doctorId,
    this.doctorName, // ✅ Added
    this.ashaId,
  });

  /// 🔹 Convert Patient object to Firestore Map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'age': age,
      'weight': weight,
      'height': height,
      'gender': gender,
      'address': address,
      'phone': phone,
      'lastAppointmentDate': lastAppointmentDate != null
          ? Timestamp.fromDate(lastAppointmentDate!)
          : null,

      // ✅ New fields
      'doctorId': doctorId,
      'doctorName': doctorName,
      'ashaId': ashaId,
    };
  }

  /// 🔹 Convert Firestore Map to Patient object
  factory Patient.fromMap(Map<String, dynamic> data, String documentId) {
    return Patient(
      id: documentId,
      name: data['name'] ?? '',
      age: (data['age'] ?? 0).toInt(),
      weight: (data['weight'] ?? 0).toDouble(),
      height: (data['height'] ?? 0).toDouble(),
      gender: data['gender'] ?? '',
      address: data['address'] ?? '',
      phone: data['phone'] ?? '',
      lastAppointmentDate: data['lastAppointmentDate'] != null
          ? (data['lastAppointmentDate'] is Timestamp
              ? (data['lastAppointmentDate'] as Timestamp).toDate()
              : (data['lastAppointmentDate'] as DateTime))
          : null,

      // ✅ Read doctor + ASHA IDs safely
      doctorId: data['doctorId'],
      doctorName: data['doctorName'], // ✅ Added
      ashaId: data['ashaId'],
    );
  }
}
