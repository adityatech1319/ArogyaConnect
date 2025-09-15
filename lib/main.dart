import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/patient_provider.dart';
import 'models/patient.dart';

// Import screens
import 'screens/patient_form_screen.dart';

void main() {
  runApp(const ArogyaConnectApp());
}

class ArogyaConnectApp extends StatelessWidget {
  const ArogyaConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PatientProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "ArogyaConnect",
        theme: ThemeData(primarySwatch: Colors.green),
        home: LoginScreen(),
      ),
    );
  }
}

//////////////////////////
// LOGIN SCREEN
//////////////////////////
class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String username = '';
  String password = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("ArogyaConnect Login")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: "Username"),
                onSaved: (val) => username = val!,
                validator: (val) =>
                    val!.isEmpty ? "Enter username" : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: "Password"),
                obscureText: true,
                onSaved: (val) => password = val!,
                validator: (val) =>
                    val!.isEmpty ? "Enter password" : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                child: Text("Login"),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();

                    // Simple hardcoded login
                    if (username == "admin" && password == "1234") {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (_) => PatientListScreen()),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Invalid credentials")),
                      );
                    }
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

//////////////////////////
// PATIENT LIST SCREEN
//////////////////////////
class PatientListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PatientProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Patient Records"),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => LoginScreen()),
              );
            },
          )
        ],
      ),
      body: provider.patients.isEmpty
          ? Center(child: Text("No patients yet"))
          : ListView.builder(
              itemCount: provider.patients.length,
              itemBuilder: (context, index) {
                final patient = provider.patients[index];
                return ListTile(
                  title: Text(patient.name),
                  subtitle: Text(
                      "Age: ${patient.age}, Gender: ${patient.gender}, Village: ${patient.village}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  PatientFormScreen(editPatient: patient),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          provider.deletePatient(patient.id!);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => PatientFormScreen()),
          );
        },
      ),
    );
  }
}
