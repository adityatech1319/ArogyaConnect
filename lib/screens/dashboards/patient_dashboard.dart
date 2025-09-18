import 'package:flutter/material.dart';
import 'package:arogyaconnect/services/database_service.dart';
import 'package:arogyaconnect/models/patient.dart';
import 'package:arogyaconnect/screens/symptom_checker_screen.dart';

class PatientDashboard extends StatefulWidget {
  final String userId;
  const PatientDashboard({super.key, required this.userId});

  @override
  State<PatientDashboard> createState() => _PatientDashboardState();
}

class _PatientDashboardState extends State<PatientDashboard> {
  final DatabaseService _dbService = DatabaseService();

  Patient? _patient;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPatient();
  }

  Future<void> _loadPatient() async {
    final user = await _dbService.getUserById(widget.userId);

    setState(() {
      _patient = user != null ? Patient.fromMap(user, widget.userId) : null;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Patient Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPatient,
          )
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _patient == null
              ? const Center(child: Text("No patient data found"))
              : RefreshIndicator(
                  onRefresh: _loadPatient,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // 👤 Patient basic info
                      Card(
                        elevation: 3,
                        child: ListTile(
                          leading: const Icon(Icons.person, size: 40),
                          title: Text(
                            _patient!.name,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          subtitle: Text(
                              "Age: ${_patient!.age} | Gender: ${_patient!.gender}"),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 📞 Contact
                      Card(
                        child: ListTile(
                          leading: const Icon(Icons.phone),
                          title: Text("Phone: ${_patient!.phone}"),
                        ),
                      ),
                      // 🏠 Address
                      Card(
                        child: ListTile(
                          leading: const Icon(Icons.home),
                          title: Text("Address: ${_patient!.address}"),
                        ),
                      ),
                      // ⚖️ Weight
                      Card(
                        child: ListTile(
                          leading: const Icon(Icons.monitor_weight),
                          title: Text("Weight: ${_patient!.weight} kg"),
                        ),
                      ),
                      // 📏 Height
                      Card(
                        child: ListTile(
                          leading: const Icon(Icons.height),
                          title: Text("Height: ${_patient!.height} cm"),
                        ),
                      ),
                      // 📅 Last Appointment
                      Card(
                        child: ListTile(
                          leading: const Icon(Icons.calendar_today),
                          title: Text(
                            _patient!.lastAppointmentDate == null
                                ? "Last Appointment: Not set"
                                : "Last Appointment: ${_patient!.lastAppointmentDate!.toLocal().toString().split(' ')[0]}",
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // 🩺 Symptom Checker Button
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SymptomCheckerScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.medical_information),
                        label: const Text("Check My Symptoms"),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          textStyle: const TextStyle(fontSize: 18),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
