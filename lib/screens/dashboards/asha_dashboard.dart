import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // ✅ Add this for logout
import 'package:arogyaconnect/services/database_service.dart';
import 'package:arogyaconnect/models/patient.dart';
import 'package:arogyaconnect/widgets/patient_card.dart';
import 'package:arogyaconnect/screens/symptom_checker_screen.dart';

class AshaDashboard extends StatefulWidget {
  final String userId;

  const AshaDashboard({super.key, required this.userId});

  @override
  State<AshaDashboard> createState() => _AshaDashboardState();
}

class _AshaDashboardState extends State<AshaDashboard> {
  final DatabaseService _dbService = DatabaseService();

  List<Patient> _patients = [];
  bool _loading = true;
  String _status = "unavailable";
  String _dutyStart = "";
  String _dutyEnd = "";

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final patientsData = await _dbService.getAshaPatients(widget.userId);
      final user = await _dbService.getUserById(widget.userId);

      setState(() {
        _patients = patientsData
            .map<Patient>((p) => Patient.fromMap(p, p['id'] as String))
            .toList();

        _status = user?['status'] ?? "unavailable";
        _dutyStart = user?['dutyStart'] ?? "";
        _dutyEnd = user?['dutyEnd'] ?? "";
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error loading data: $e")),
        );
      }
    }
  }

  Future<void> _updateStatus(String newStatus) async {
    await _dbService.updateAshaStatus(widget.userId, newStatus);
    setState(() => _status = newStatus);
  }

  Future<void> _setDutyTiming() async {
    TimeOfDay? startTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (startTime == null) return;

    TimeOfDay? endTime = await showTimePicker(
      context: context,
      initialTime: startTime.replacing(hour: (startTime.hour + 8) % 24),
    );
    if (endTime == null) return;

    final startStr = startTime.format(context);
    final endStr = endTime.format(context);

    await _dbService.updateAshaDuty(widget.userId, startStr, endStr);

    setState(() {
      _dutyStart = startStr;
      _dutyEnd = endStr;
    });
  }

  void _showPatientForm({Patient? patient}) {
    final nameCtrl = TextEditingController(text: patient?.name ?? "");
    final ageCtrl =
        TextEditingController(text: patient?.age?.toString() ?? "");
    final weightCtrl =
        TextEditingController(text: patient?.weight?.toString() ?? "");
    final heightCtrl =
        TextEditingController(text: patient?.height?.toString() ?? "");
    final addressCtrl = TextEditingController(text: patient?.address ?? "");
    final phoneCtrl = TextEditingController(text: patient?.phone ?? "");

    String gender = patient?.gender ?? "Male";
    DateTime? lastAppointment = patient?.lastAppointmentDate;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(patient == null ? "Add Patient" : "Edit Patient"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: "Name"),
              ),
              TextField(
                controller: ageCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Age"),
              ),
              DropdownButtonFormField<String>(
                value: gender,
                items: ["Male", "Female", "Other"]
                    .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                    .toList(),
                onChanged: (val) => gender = val ?? "Male",
                decoration: const InputDecoration(labelText: "Gender"),
              ),
              TextField(
                controller: weightCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Weight (kg)"),
              ),
              TextField(
                controller: heightCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Height (cm)"),
              ),
              TextField(
                controller: addressCtrl,
                decoration: const InputDecoration(labelText: "Address"),
              ),
              TextField(
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: "Phone"),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      lastAppointment == null
                          ? "Last Appointment: Not set"
                          : "Last Appointment: ${lastAppointment?.toLocal().toString().split(' ')[0]}",
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: lastAppointment ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() => lastAppointment = picked);
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              final newPatient = Patient(
                id: patient?.id ?? "",
                name: nameCtrl.text.trim(),
                age: int.tryParse(ageCtrl.text.trim()) ?? 0,
                gender: gender,
                weight: double.tryParse(weightCtrl.text.trim()) ?? 0,
                height: double.tryParse(heightCtrl.text.trim()) ?? 0,
                address: addressCtrl.text.trim(),
                phone: phoneCtrl.text.trim(),
                lastAppointmentDate: lastAppointment,
              );

              if (patient == null) {
                await _dbService.addPatient(newPatient, widget.userId);
              } else {
                await _dbService.updatePatient(patient.id, newPatient);
              }

              if (mounted) {
                _loadData();
                Navigator.pop(context);
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ASHA Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: "Logout",
            onPressed: () async {
              await FirebaseAuth.instance.signOut(); // ✅ logout
            },
          ),
          PopupMenuButton<String>(
            onSelected: (val) {
              if (val == "available" || val == "unavailable") {
                _updateStatus(val);
              } else if (val == "timing") {
                _setDutyTiming();
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: "available", child: Text("Set Available")),
              PopupMenuItem(value: "unavailable", child: Text("Set Unavailable")),
              PopupMenuItem(value: "timing", child: Text("Set Duty Timings")),
            ],
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                padding: const EdgeInsets.all(12),
                children: [
                  Card(
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
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const SymptomCheckerScreen()),
                      );
                    },
                    icon: const Icon(Icons.medical_information),
                    label: const Text("Symptom Checker"),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      textStyle: const TextStyle(fontSize: 18),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text("Assigned Patients",
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 10),
                  ..._patients.map(
                    (p) => PatientCard(
                      patient: p,
                      onEdit: () => _showPatientForm(patient: p),
                    ),
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showPatientForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
