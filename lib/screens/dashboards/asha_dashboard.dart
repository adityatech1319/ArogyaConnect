import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:arogyaconnect/services/database_service.dart';
import 'package:arogyaconnect/models/patient.dart';
import 'package:arogyaconnect/widgets/patient_card.dart';
import 'package:arogyaconnect/screens/symptom_checker_screen.dart';
import 'package:arogyaconnect/screens/login_screen.dart';

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
  int _doctorAvailable = 0;
  int _doctorUnavailable = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final patientsData = await _dbService.getAshaPatients(widget.userId);
      final user = await _dbService.getUserById(widget.userId);
      final doctorCounts = await _dbService.getDoctorAvailabilityCounts();

      setState(() {
        _patients = patientsData
            .map<Patient>((p) => Patient.fromMap(p, p['id'] as String))
            .toList();

        _status = user?['status'] ?? "unavailable";
        _dutyStart = user?['dutyStart'] ?? "";
        _dutyEnd = user?['dutyEnd'] ?? "";
        _doctorAvailable = doctorCounts['available'] ?? 0;
        _doctorUnavailable = doctorCounts['unavailable'] ?? 0;

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

  /// ✅ Assign Doctor Function (centralized in DatabaseService)
  Future<void> _assignDoctor(String patientId) async {
    final doctorsSnapshot = await FirebaseFirestore.instance
        .collection("users")
        .where("role", isEqualTo: "doctor")
        .get();

    if (doctorsSnapshot.docs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No doctors available")),
      );
      return;
    }

    final selectedDoctor = await showDialog<DocumentSnapshot>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text("Select Doctor"),
        children: doctorsSnapshot.docs.map((doc) {
          final doctor = doc.data() as Map<String, dynamic>;
          return SimpleDialogOption(
            child: Text(doctor['username'] ?? "Unknown"),
            onPressed: () => Navigator.pop(context, doc),
          );
        }).toList(),
      ),
    );

    if (selectedDoctor != null) {
      final doctorData = selectedDoctor.data() as Map<String, dynamic>;
      final doctorName = doctorData['username'] ?? "Unknown";

      await _dbService.assignDoctorToPatient(
        patientId,
        selectedDoctor.id,
        doctorName,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Doctor assigned successfully")),
      );
      _loadData();
    }
  }

  void _showPatientForm({Patient? patient}) {
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController(text: patient?.name ?? "");
    final ageCtrl = TextEditingController(text: patient?.age.toString() ?? "");
    final weightCtrl =
        TextEditingController(text: patient?.weight.toString() ?? "");
    final heightCtrl =
        TextEditingController(text: patient?.height.toString() ?? "");
    final addressCtrl = TextEditingController(text: patient?.address ?? "");
    final phoneCtrl = TextEditingController(text: patient?.phone ?? "");

    String gender = patient?.gender ?? "Male";
    DateTime? lastAppointment = patient?.lastAppointmentDate;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(patient == null ? "Add Patient" : "Edit Patient"),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: "Name"),
                ),
                TextFormField(
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
                TextFormField(
                  controller: weightCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Weight (kg)"),
                ),
                TextFormField(
                  controller: heightCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Height (cm)"),
                ),
                TextFormField(
                  controller: addressCtrl,
                  decoration: const InputDecoration(labelText: "Address"),
                ),
                TextFormField(
                  controller: phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: "Phone"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Phone number is required";
                    }
                    if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
                      return "Enter a valid 10-digit phone number";
                    }
                    return null;
                  },
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
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;

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
              await FirebaseAuth.instance.signOut();
              if (mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
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
                    child: ListTile(
                      leading: const Icon(Icons.medical_services,
                          color: Colors.blue),
                      title: const Text("Doctors Availability"),
                      subtitle: Text(
                          "Available: $_doctorAvailable | Unavailable: $_doctorUnavailable"),
                    ),
                  ),
                  const SizedBox(height: 10),
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
                      onAssignDoctor: () => _assignDoctor(p.id),
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
