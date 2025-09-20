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
  
  static const String agoraAppId = "bc1efcc9656b48bea1674c9afddf5f9a";
  static const String geminiApiKey = "AIzaSyA_0h7Xe1BCRdPRhiEsRCO2-on0KfTcHAw";
   static const String agoraToken = ""; // Use "" if no token
}
