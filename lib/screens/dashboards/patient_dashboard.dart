import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import '../../services/database_service.dart';
import '../../providers/session_provider.dart';
import '../symptom_checker_screen.dart';
import 'package:arogyaconnect/screens/calls/video_call_screen.dart';

class PatientDashboard extends StatefulWidget {
  final String userId;
  const PatientDashboard({super.key, required this.userId});

  @override
  State<PatientDashboard> createState() => _PatientDashboardState();
}

class _PatientDashboardState extends State<PatientDashboard> {
  final DatabaseService _dbService = DatabaseService();

  Map<String, dynamic>? _patient;
  Map<String, dynamic>? _doctor;
  Map<String, dynamic>? _asha;
  bool _loading = true;

  int _availableDoctorsCount = 0;

  @override
  void initState() {
    super.initState();
    _loadPatient();
    _loadAvailableDoctors();
  }

  /// 🔹 Load patient + doctor + ASHA worker
  Future<void> _loadPatient() async {
    try {
      final data = await _dbService.getPatientById(widget.userId);

      Map<String, dynamic>? doctorData;
      Map<String, dynamic>? ashaData;

      if (data != null) {
        if (data['doctorId'] != null) {
          doctorData = await _dbService.getUserById(data['doctorId']);
        }
        if (data['ashaId'] != null) {
          ashaData = await _dbService.getUserById(data['ashaId']);
        }
      }

      setState(() {
        _patient = data;
        _doctor = doctorData;
        _asha = ashaData;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _patient = null;
        _loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Error loading patient: $e")),
      );
    }
  }

  /// 🔹 Load available doctors count
  Future<void> _loadAvailableDoctors() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'doctor')
          .where('status', isEqualTo: 'available')
          .get();

      setState(() {
        _availableDoctorsCount = snapshot.docs.length;
      });
    } catch (e) {
      debugPrint("Error fetching doctors: $e");
    }
  }

  /// 🔹 Helper for showing patient details
  Widget _buildDetail(String label, dynamic value, {IconData? icon}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: Icon(icon ?? Icons.info, color: Colors.teal),
        title: Text(
          "$label: ${value ?? 'N/A'}",
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  /// 🔹 Request Teleconsultation
  Future<void> _requestTeleconsultation() async {
    try {
      if (_patient == null || _doctor == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Doctor or patient info missing")),
        );
        return;
      }

      final sessionProvider =
          Provider.of<SessionProvider>(context, listen: false);

      // ✅ Generate unique channel
      String channelName = "session_${DateTime.now().millisecondsSinceEpoch}";

      // ✅ Create session in Firestore
      String sessionId = await sessionProvider.createSession(
        _patient!['id'] ?? widget.userId, // patientId
        _doctor!['id'] ?? "doctor001",    // doctorId fallback
        channelName: channelName,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("✅ Teleconsultation requested (ID: $sessionId)")),
      );

      // ✅ Navigate patient to Video Call
      if (mounted) {
        Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => const VideoCallScreen(channelName: "arogya_demo"),
  ),
);

      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Error requesting teleconsultation: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Patient Dashboard"),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _loadPatient();
              _loadAvailableDoctors();
            },
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _patient == null
              ? const Center(child: Text("❌ Patient not found"))
              : RefreshIndicator(
                  onRefresh: () async {
                    await _loadPatient();
                    await _loadAvailableDoctors();
                  },
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      const Text(
                        "👤 Patient Details",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),

                      _buildDetail("Name", _patient!['name'],
                          icon: Icons.person),
                      _buildDetail("Phone", _patient!['phone'],
                          icon: Icons.phone),
                      _buildDetail("Age", _patient!['age'], icon: Icons.cake),
                      _buildDetail("Gender", _patient!['gender'],
                          icon: Icons.wc),

                      const SizedBox(height: 20),
                      const Text(
                        "🩺 Assigned Doctor",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      _doctor != null
                          ? _buildDetail("Doctor", _doctor!['username'],
                              icon: Icons.medical_services)
                          : const Text("No doctor assigned"),

                      const SizedBox(height: 20),
                      const Text(
                        "👩‍⚕️ Assigned ASHA Worker",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      _asha != null
                          ? _buildDetail("ASHA Worker", _asha!['username'],
                              icon: Icons.people)
                          : const Text("No ASHA worker assigned"),

                      const SizedBox(height: 20),
                      const Text(
                        "📊 Doctor Availability",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      _buildDetail("Available Doctors",
                          _availableDoctorsCount.toString(),
                          icon: Icons.local_hospital),

                      const SizedBox(height: 30),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const SymptomCheckerScreen()),
                          );
                        },
                        icon: const Icon(Icons.health_and_safety),
                        label: const Text("AI Symptom Checker"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 14),
                        ),
                      ),

                      const SizedBox(height: 20),

                      /// ✅ Teleconsultation button
                      ElevatedButton.icon(
                        onPressed: _requestTeleconsultation,
                        icon: const Icon(Icons.video_call),
                        label: const Text("Request Teleconsultation"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 14),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
