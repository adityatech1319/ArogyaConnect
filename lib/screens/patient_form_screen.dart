import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/patient.dart';
import '../providers/patient_provider.dart';

class PatientFormScreen extends StatefulWidget {
  final Patient? editPatient;
  PatientFormScreen({this.editPatient});

  @override
  _PatientFormScreenState createState() => _PatientFormScreenState();
}

class _PatientFormScreenState extends State<PatientFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late String name;
  late int age;
  late String gender;
  late String village;

  @override
  void initState() {
    super.initState();
    if (widget.editPatient != null) {
      name = widget.editPatient!.name;
      age = widget.editPatient!.age;
      gender = widget.editPatient!.gender;
      village = widget.editPatient!.village;
    } else {
      name = '';
      age = 0;
      gender = 'Male';
      village = '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: Text(widget.editPatient == null ? "Add Patient" : "Edit Patient")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: name,
                decoration: InputDecoration(labelText: "Name"),
                onSaved: (val) => name = val!,
                validator: (val) => val!.isEmpty ? "Enter name" : null,
              ),
              TextFormField(
                initialValue: age == 0 ? '' : age.toString(),
                decoration: InputDecoration(labelText: "Age"),
                keyboardType: TextInputType.number,
                onSaved: (val) => age = int.parse(val!),
                validator: (val) => val!.isEmpty ? "Enter age" : null,
              ),
              DropdownButtonFormField<String>(
                value: gender,
                items: ['Male', 'Female', 'Other']
                    .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                    .toList(),
                onChanged: (val) => setState(() => gender = val!),
              ),
              TextFormField(
                initialValue: village,
                decoration: InputDecoration(labelText: "Village"),
                onSaved: (val) => village = val!,
                validator: (val) => val!.isEmpty ? "Enter village" : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                child: Text(widget.editPatient == null ? "Save" : "Update"),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    final patient = Patient(
                      id: widget.editPatient?.id,
                      name: name,
                      age: age,
                      gender: gender,
                      village: village,
                    );
                    if (widget.editPatient == null) {
                      Provider.of<PatientProvider>(context, listen: false)
                          .addPatient(patient);
                    } else {
                      Provider.of<PatientProvider>(context, listen: false)
                          .updatePatient(patient);
                    }
                    Navigator.pop(context);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
