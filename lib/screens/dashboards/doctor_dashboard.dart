// lib/screens/dashboards/doctor_dashboard.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // ✅ Add FirebaseAuth for sign out
import 'package:arogyaconnect/services/database_service.dart';
import 'package:arogyaconnect/models/patient.dart';
import 'package:arogyaconnect/widgets/patient_card.dart';
import 'package:arogyaconnect/main.dart'; // ✅ For LoginScreen
import 'package:arogyaconnect/screens/login_screen.dart'; // ✅ For LoginScreen

class DoctorDashboard extends StatefulWidget {
  final String userId;

  const DoctorDashboard({super.key, required this.userId});

  @override
  State<DoctorDashboard> createState() => _DoctorDashboardState();
}

class _DoctorDashboardState extends State<DoctorDashboard> {
  final DatabaseService _dbService = DatabaseService();

  bool _loading = true;
  String _status = "unavailable";
  String _dutyStart = "";
  String _dutyEnd = "";

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  /// 🔹 Load doctor info from database
  Future<void> _loadUserData() async {
    final user = await _dbService.getUserById(widget.userId);

    setState(() {
      _status = user?['status'] ?? "unavailable";
      _dutyStart = user?['dutyStart'] ?? "";
      _dutyEnd = user?['dutyEnd'] ?? "";
      _loading = false;
    });
  }

  /// 🔹 Update availability status in DB
  Future<void> _updateStatus(String newStatus) async {
    await _dbService.updateDoctorStatus(widget.userId, newStatus);
    setState(() => _status = newStatus);
  }

  /// 🔹 Set duty timings
  Future<void> _setDutyTiming() async {
    TimeOfDay? startTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (startTime == null) return;

    TimeOfDay? endTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (endTime == null) return;

    final startStr = startTime.format(context);
    final endStr = endTime.format(context);

    await _dbService.updateDoctorDuty(widget.userId, startStr, endStr);
    setState(() {
      _dutyStart = startStr;
      _dutyEnd = endStr;
    });
  }

  /// 🔹 Logout method
  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Doctor Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: "Logout",
            onPressed: _logout,
          ),
          PopupMenuButton<String>(
            onSelected: (val) {
              if (val == "available" || val == "unavailable") {
                _updateStatus(val);
              } else if (val == "timing") {
                _setDutyTiming();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: "available",
                child: Text("Set Available"),
              ),
              const PopupMenuItem(
                value: "unavailable",
                child: Text("Set Unavailable"),
              ),
              const PopupMenuItem(
                value: "timing",
                child: Text("Set Duty Timings"),
              ),
            ],
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                /// 🔹 Doctor status card
                Card(
                  margin: const EdgeInsets.all(12),
                  color: _status == "available"
                      ? Colors.green[100]
                      : Colors.red[100],
                  child: ListTile(
                    leading: Icon(
                      _status == "available"
                          ? Icons.check_circle
                          : Icons.cancel,
                      color:
                          _status == "available" ? Colors.green : Colors.red,
                    ),
                    title: Text("Status: $_status"),
                    subtitle: Text(
                      _dutyStart.isNotEmpty && _dutyEnd.isNotEmpty
                          ? "Duty: $_dutyStart - $_dutyEnd"
                          : "Duty timings not set",
                    ),
                  ),
                ),

                /// 🔹 Patients assigned to doctor
                Expanded(
                  child: StreamBuilder<List<Patient>>(
                    stream: _dbService.getPatients(), // 🔥 live updates
                    builder: (context, snapshot) {
                      if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(
                            child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(
                          child: Text("No patients assigned yet."),
                        );
                      }

                      final patients = snapshot.data!;
                      return RefreshIndicator(
                        onRefresh: _loadUserData,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: patients.length,
                          itemBuilder: (context, index) {
                            return PatientCard(patient: patients[index]);
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
