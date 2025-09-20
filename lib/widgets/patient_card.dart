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
  final VoidCallback? onEdit;          // optional edit
  final VoidCallback? onAssignDoctor;  // ✅ new callback

  const PatientCard({
    super.key,
    required this.patient,
    this.onEdit,
    this.onAssignDoctor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Patient basic info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  patient.name,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18),
                ),
                if (onEdit != null)
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: onEdit,
                  ),
              ],
            ),
            Text("Age: ${patient.age}, Gender: ${patient.gender}"),
            Text("Phone: ${patient.phone}"),
            Text("Address: ${patient.address}"),
            Text("Weight: ${patient.weight} kg, Height: ${patient.height} cm"),
            Text(
                "Last Appointment: ${_formatDate(patient.lastAppointmentDate)}"),

            // ✅ Show doctor info if assigned
            const SizedBox(height: 6),
            Text(
              patient.doctorName != null && patient.doctorName!.isNotEmpty
                  ? "Assigned Doctor: ${patient.doctorName}"
                  : "Assigned Doctor: Not assigned",
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: patient.doctorName != null &&
                        patient.doctorName!.isNotEmpty
                    ? Colors.green[700]
                    : Colors.red[700],
              ),
            ),

            const SizedBox(height: 8),

            // ✅ Doctor assign button
            if (onAssignDoctor != null)
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: onAssignDoctor,
                  icon: const Icon(Icons.person_add_alt_1),
                  label: Text(
                    patient.doctorName != null &&
                            patient.doctorName!.isNotEmpty
                        ? "Reassign Doctor"
                        : "Assign Doctor",
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
