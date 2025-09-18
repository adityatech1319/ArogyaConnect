// lib/models/user.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String id;
  final String username;
  final String role; // e.g. "admin", "doctor", "asha", "patient"
  final String password; // ⚠️ In real apps, don’t store plain text passwords
  final String status; // available/unavailable (for ASHA/Doctor)
  final String dutyStart;
  final String dutyEnd;

  AppUser({
    required this.id,
    required this.username,
    required this.role,
    required this.password,
    this.status = "unavailable",
    this.dutyStart = "",
    this.dutyEnd = "",
  });

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'role': role,
      'password': password,
      'status': status,
      'dutyStart': dutyStart,
      'dutyEnd': dutyEnd,
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> data, String documentId) {
    return AppUser(
      id: documentId,
      username: data['username'] ?? '',
      role: data['role'] ?? '',
      password: data['password'] ?? '',
      status: data['status'] ?? 'unavailable',
      dutyStart: data['dutyStart'] ?? '',
      dutyEnd: data['dutyEnd'] ?? '',
    );
  }
}
