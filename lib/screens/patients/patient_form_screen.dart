import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:arogyaconnect/models/patient.dart';
import 'package:arogyaconnect/services/database_service.dart';


class PatientFormScreen extends StatefulWidget {
  final Patient? patient; // null = new, not null = edit
  final String createdBy;

  const PatientFormScreen({super.key, this.patient, required this.createdBy});

  @override
  State<PatientFormScreen> createState() => _PatientFormScreenState();
}

class _PatientFormScreenState extends State<PatientFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final DatabaseService _dbService = DatabaseService();

  // form controllers
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _ageCtrl = TextEditingController();
  final TextEditingController _weightCtrl = TextEditingController();
  final TextEditingController _heightCtrl = TextEditingController();
  final TextEditingController _phoneCtrl = TextEditingController();
  final TextEditingController _addressCtrl = TextEditingController();

  String _gender = "Male"; // dropdown
  DateTime? _lastAppointment;

 @override
void initState() {
  super.initState();
  if (widget.patient != null) {
    final p = widget.patient!;
    _nameCtrl.text = p.name;
    _ageCtrl.text = p.age.toString();
    _weightCtrl.text = p.weight.toString();
    _heightCtrl.text = p.height.toString();
    _phoneCtrl.text = p.phone;
    _addressCtrl.text = p.address;
    _gender = p.gender;

    if (p.lastAppointmentDate != null) {
      if (p.lastAppointmentDate is Timestamp) {
        _lastAppointment = (p.lastAppointmentDate as Timestamp).toDate();
      } else if (p.lastAppointmentDate is DateTime) {
        _lastAppointment = p.lastAppointmentDate;
      }
    }
  }
}


  Future<void> _savePatient() async {
    if (_formKey.currentState!.validate()) {
      final patient = Patient(
  id: widget.patient?.id ?? '',
  name: _nameCtrl.text.trim(),
  age: int.tryParse(_ageCtrl.text.trim()) ?? 0,
  weight: double.tryParse(_weightCtrl.text.trim()) ?? 0,
  height: double.tryParse(_heightCtrl.text.trim()) ?? 0,
  phone: _phoneCtrl.text.trim(),
  address: _addressCtrl.text.trim(),
  gender: _gender,
  lastAppointmentDate: _lastAppointment, // ✅ Always DateTime
);


      if (widget.patient == null) {
        // add new
        await _dbService.addPatient(patient, widget.createdBy);
      } else {
        // update
        await _dbService.updatePatient(patient.id, patient);
      }

      if (mounted) Navigator.pop(context, true);
    }
  }

  Future<void> _pickAppointmentDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _lastAppointment ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _lastAppointment = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.patient == null ? "Add Patient" : "Edit Patient"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: "Name"),
                validator: (val) =>
                    val == null || val.isEmpty ? "Enter name" : null,
              ),
              TextFormField(
                controller: _ageCtrl,
                decoration: const InputDecoration(labelText: "Age"),
                keyboardType: TextInputType.number,
              ),
              DropdownButtonFormField<String>(
                value: _gender,
                decoration: const InputDecoration(labelText: "Gender"),
                items: ["Male", "Female", "Other"]
                    .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                    .toList(),
                onChanged: (val) => setState(() => _gender = val!),
              ),
              TextFormField(
                controller: _weightCtrl,
                decoration: const InputDecoration(labelText: "Weight (kg)"),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: _heightCtrl,
                decoration: const InputDecoration(labelText: "Height (cm)"),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: _phoneCtrl,
                decoration: const InputDecoration(labelText: "Phone"),
                keyboardType: TextInputType.phone,
              ),
              TextFormField(
                controller: _addressCtrl,
                decoration: const InputDecoration(labelText: "Address"),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _lastAppointment == null
                          ? "Last Appointment: Not set"
                          : "Last Appointment: ${_lastAppointment!.toLocal().toString().split(' ')[0]}",
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: _pickAppointmentDate,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _savePatient,
                child: Text(widget.patient == null ? "Add Patient" : "Save"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
