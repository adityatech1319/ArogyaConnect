// lib/core/constants.dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  static const String appName = "ArogyaConnect";

  // Firebase collections
  static const String usersCollection = "users";
  static const String patientsCollection = "patients";
  static const String doctorsCollection = "doctors";
  static const String ashaCollection = "asha_workers";
  static const String appointmentsCollection = "appointments";

  // Roles
  static const String roleAdmin = "admin";
  static const String roleDoctor = "doctor";
  static const String rolePatient = "patient";
  static const String roleAsha = "asha";

  // Status
  static const String statusAvailable = "available";
  static const String statusUnavailable = "unavailable";

  // 🔹 Gemini API Key (from .env)
  static String get geminiApiKey => dotenv.env['GEMINI_API_KEY'] ?? "";
}
