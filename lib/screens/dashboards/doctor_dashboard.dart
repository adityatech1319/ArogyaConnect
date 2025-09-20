import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:arogyaconnect/services/database_service.dart';
import 'package:arogyaconnect/screens/login_screen.dart';
import 'package:arogyaconnect/screens/calls/video_call_screen.dart';

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

  /// 🔹 Accept Teleconsultation → update Firestore + open video call
Future<void> _acceptSession(String sessionId, String channelName) async {
  // For now, token is empty (replace later with generated one)
  const String token = "";

  await FirebaseFirestore.instance
      .collection('sessions')
      .doc(sessionId)
      .update({
        "status": "accepted",
        "token": token,
      });

  if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("✅ Session accepted")),
    );

    Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => const VideoCallScreen(channelName: "arogya_demo"),
  ),
);

  }
}

  /// 🔹 Reject Teleconsultation
  Future<void> _rejectSession(String sessionId) async {
    await FirebaseFirestore.instance
        .collection('sessions')
        .doc(sessionId)
        .update({"status": "rejected"});

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("❌ Session rejected")),
    );
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

                const SizedBox(height: 10),

                /// 🔹 Pending teleconsultations
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection("sessions")
                        .where("doctorId", isEqualTo: widget.userId)
                        .where("status", isEqualTo: "pending")
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(
                            child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(
                          child: Text("No teleconsultation requests yet."),
                        );
                      }

                      final sessions = snapshot.data!.docs;

                      return ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: sessions.length,
                        itemBuilder: (context, index) {
                          final session = sessions[index];
                          final data =
                              session.data() as Map<String, dynamic>;

                          return Card(
                            child: ListTile(
                              leading: const Icon(Icons.video_call,
                                  color: Colors.blue),
                              title: Text("Patient: ${data['patientId']}"),
                              subtitle: Text(
                                "Channel: ${data['channelName'] ?? 'N/A'}",
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.check,
                                        color: Colors.green),
                                    onPressed: () => _acceptSession(
                                      session.id,
                                      data['channelName'] ?? "defaultChannel",
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.close,
                                        color: Colors.red),
                                    onPressed: () =>
                                        _rejectSession(session.id),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
