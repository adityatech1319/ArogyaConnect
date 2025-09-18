import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/database_service.dart';

// Dashboards
import 'dashboards/admin_dashboard.dart';
import 'dashboards/doctor_dashboard.dart';
import 'dashboards/asha_dashboard.dart';
import 'dashboards/patient_dashboard.dart';


// Models
import '../models/patient.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  bool _isLoading = false;
  final DatabaseService _dbService = DatabaseService();

  Future<void> _login() async {
    setState(() => _isLoading = true);

    String username = _usernameController.text.trim();
    String password = _passwordController.text.trim();
    String phone = _phoneController.text.trim();

    try {
      // ✅ ADMIN LOGIN (hardcoded)
      if (username.toLowerCase() == "admin" && password == "1234") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AdminDashboard()),
        );
      }

      // ✅ DOCTOR LOGIN
      else if (username.toUpperCase().startsWith("DOC")) {
        final user = await _dbService.getUserByUsername(username);
        if (user != null &&
            user['role'] == 'doctor' &&
            user['password'] == password) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (_) => DoctorDashboard(userId: user['id'])),
          );
        } else {
          _showError("Invalid Doctor login!");
        }
      }

      // ✅ ASHA LOGIN
      else if (username.toUpperCase().startsWith("ASHA")) {
        final user = await _dbService.getUserByUsername(username);
        if (user != null &&
            user['role'] == 'asha' &&
            user['password'] == password) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (_) => AshaDashboard(userId: user['id'])),
          );
        } else {
          _showError("Invalid ASHA Worker login!");
        }
      }

      // ✅ PATIENT LOGIN (via phone only)
      else if (phone.isNotEmpty) {
        final Patient? patient = await _dbService.getPatientByPhone(phone);
        if (patient != null) {
          Navigator.pushReplacement(
  context,
  MaterialPageRoute(
    builder: (_) => PatientDashboard(userId: patient.id),
  ),
);

        } else {
          _showError("No patient found with this phone number.");
        }
      }

      // ❌ INVALID LOGIN
      else {
        _showError("Enter valid credentials.");
      }
    } catch (e) {
      _showError("Login failed: $e");
    }

    setState(() => _isLoading = false);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.local_hospital,
                  size: 100, color: Colors.green),
              const SizedBox(height: 20),
              const Text(
                "ArogyaConnect",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),

              // Username (for Admin/Doctor/ASHA)
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: "Username (Admin/DOC/ASHA)",
                ),
              ),
              const SizedBox(height: 20),

              // Password (Admin/Doctor/ASHA only)
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Password",
                ),
              ),
              const SizedBox(height: 20),

              // Phone (for Patient login only)
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: "Patient Phone (for Patient login)",
                ),
              ),
              const SizedBox(height: 30),

              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 50, vertical: 15),
                      ),
                      child: const Text(
                        "Login",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
