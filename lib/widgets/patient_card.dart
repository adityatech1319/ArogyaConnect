import 'package:flutter/material.dart';
import '../models/patient.dart';

class PatientCard extends StatelessWidget {
  final Patient patient;
  PatientCard({required this.patient});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8),
      child: ListTile(
        title: Text(patient.name),
        subtitle: Text("Age: ${patient.age}, Village: ${patient.village}"),
      ),
    );
  }
}
