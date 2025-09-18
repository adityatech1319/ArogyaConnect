// lib/screens/doctors/doctor_list_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:arogyaconnect/providers/doctor_provider.dart';

class DoctorListScreen extends StatefulWidget {
  const DoctorListScreen({super.key});

  @override
  State<DoctorListScreen> createState() => _DoctorListScreenState();
}

class _DoctorListScreenState extends State<DoctorListScreen> {
  @override
  void initState() {
    super.initState();
    // fetch doctors once provider is available in tree
    Future.microtask(() =>
        Provider.of<DoctorProvider>(context, listen: false).fetchDoctors());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Doctors")),
      body: Consumer<DoctorProvider>(builder: (context, doctorProvider, _) {
        if (doctorProvider.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (doctorProvider.doctors.isEmpty) {
          return const Center(child: Text("No doctors found."));
        }

        return RefreshIndicator(
          // Use the exact method name: fetchDoctors (not FetchDoctors)
          onRefresh: doctorProvider.fetchDoctors,
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: doctorProvider.doctors.length,
            itemBuilder: (context, index) {
              final doctor = doctorProvider.doctors[index];
              return Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text(doctor.name),
                  subtitle: Text("Specialization: ${doctor.specialization}"),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}
