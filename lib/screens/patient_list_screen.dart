import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/patient_provider.dart';
import '../models/patient.dart';

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

  void _showPatientForm(BuildContext context, {Patient? patient}) {
    final nameController = TextEditingController(text: patient?.name ?? "");
    final ageController =
        TextEditingController(text: patient?.age.toString() ?? "");
    final genderController =
        TextEditingController(text: patient?.gender ?? "");
    final villageController =
        TextEditingController(text: patient?.village ?? "");

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text(patient == null ? "Add Patient" : "Edit Patient"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: "Name"),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: ageController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Age"),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: genderController,
                  decoration: const InputDecoration(labelText: "Gender"),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: villageController,
                  decoration: const InputDecoration(labelText: "Village"),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = nameController.text.trim();
                final age = int.tryParse(ageController.text.trim()) ?? 0;
                final gender = genderController.text.trim();
                final village = villageController.text.trim();

                if (name.isEmpty || gender.isEmpty || village.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please fill all fields")),
                  );
                  return;
                }

                if (patient == null) {
                  // Add new patient
                  await Provider.of<PatientProvider>(context, listen: false)
                      .addPatient(
                    Patient(
                      name: name,
                      age: age,
                      gender: gender,
                      village: village,
                    ),
                  );
                } else {
                  // Update existing patient
                  await Provider.of<PatientProvider>(context, listen: false)
                      .updatePatient(
                    Patient(
                      id: patient.id,
                      name: name,
                      age: age,
                      gender: gender,
                      village: village,
                    ),
                  );
                }

                Navigator.pop(context);
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
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
                return ListTile(
                  title: Text(patient.name),
                  subtitle: Text(
                      "Age: ${patient.age}, Gender: ${patient.gender}, Village: ${patient.village}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () =>
                            _showPatientForm(context, patient: patient),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => patientProvider.deletePatient(patient.id!),
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
        onPressed: () => _showPatientForm(context),
      ),
    );
  }
}
