import 'package:flutter/material.dart';
import '../models/patient.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ✅ Helper function for Firestore Timestamp or DateTime
String _formatDate(dynamic timestamp) {
  if (timestamp == null) return "Not set";
  if (timestamp is DateTime) {
    return DateFormat('yyyy-MM-dd').format(timestamp.toLocal());
  }
  if (timestamp is Timestamp) {
    return DateFormat('yyyy-MM-dd').format(timestamp.toDate().toLocal());
  }
  return "Invalid date";
}

class PatientCard extends StatelessWidget {
  final Patient patient;
  final VoidCallback? onEdit; // optional edit

  const PatientCard({super.key, required this.patient, this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        title: Text(
          patient.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Age: ${patient.age}, Gender: ${patient.gender}"),
            Text("Phone: ${patient.phone}"),
            Text("Address: ${patient.address}"),
            Text("Weight: ${patient.weight} kg, Height: ${patient.height} cm"),
            Text("Last Appointment: ${_formatDate(patient.lastAppointmentDate)}"), // ✅ fixed
          ],
        ),
        trailing: onEdit != null
            ? IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                onPressed: onEdit,
              )
            : null,
      ),
    );
  }
}
