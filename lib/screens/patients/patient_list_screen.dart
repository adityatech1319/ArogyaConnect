import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // ✅ for formatting dates
import '../../providers/patient_provider.dart';
import '../../models/patient.dart';
import 'patient_form_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';


class PatientListScreen extends StatefulWidget {
  const PatientListScreen({super.key});

  @override
  State<PatientListScreen> createState() => _PatientListScreenState();
}

class _PatientListScreenState extends State<PatientListScreen> {
  @override
  void initState() {
    super.initState();
    // Load patients from DB when screen opens
    Provider.of<PatientProvider>(context, listen: false).loadPatients();
  }

void _navigateToForm({Patient? patient}) {
  final userId = FirebaseAuth.instance.currentUser?.uid ?? "asha123"; // fallback for testing
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => PatientFormScreen(
        patient: patient,   // ✅ correct param name
        createdBy: userId,  // ✅ required param
      ),
    ),
  );
}



  /// ✅ Helper: format date
  String _formatDate(DateTime? date) {
    if (date == null) return "Not set";
    return DateFormat('yyyy-MM-dd').format(date.toLocal());
  }

  @override
  Widget build(BuildContext context) {
    final patientProvider = Provider.of<PatientProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Patient List"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: patientProvider.patients.isEmpty
          ? const Center(child: Text("No patients added yet"))
          : ListView.builder(
              itemCount: patientProvider.patients.length,
              itemBuilder: (context, index) {
                final patient = patientProvider.patients[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    title: Text(
                      patient.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    subtitle: Text(
                      "Age: ${patient.age}, Gender: ${patient.gender}\n"
                      "Phone: ${patient.phone}, Village: ${patient.address}\n"
                      "Weight: ${patient.weight}kg, Height: ${patient.height}cm\n"
                      "Last Appointment: ${_formatDate(patient.lastAppointmentDate)}",
                    ),
                    isThreeLine: true,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _navigateToForm(patient: patient),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () =>
                              patientProvider.deletePatient(patient.id),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
        onPressed: () => _navigateToForm(),
      ),
    );
  }
}
