import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:arogyaconnect/services/database_service.dart';
import 'package:arogyaconnect/screens/login_screen.dart'; // ✅ make sure you have this

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final DatabaseService _dbService = DatabaseService();

  int doctorCount = 0;
  int ashaCount = 0;
  int patientCount = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadCounts();
  }

  Future<void> _loadCounts() async {
    setState(() => _loading = true);

    final dCount = await _dbService.getCollectionCount(
      'users',
      filterField: 'role',
      filterValue: 'doctor',
    );

    final aCount = await _dbService.getCollectionCount(
      'users',
      filterField: 'role',
      filterValue: 'asha',
    );

    final pCount = await _dbService.getCollectionCount('patients');

    setState(() {
      doctorCount = dCount;
      ashaCount = aCount;
      patientCount = pCount;
      _loading = false;
    });
  }

  void _addUserDialog(String role) {
    final TextEditingController usernameCtrl = TextEditingController();
    final TextEditingController passwordCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text("Create ${role.toUpperCase()}"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: usernameCtrl,
              decoration: const InputDecoration(
                labelText: "Username",
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: passwordCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Password",
                prefixIcon: Icon(Icons.lock),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (usernameCtrl.text.isNotEmpty &&
                  passwordCtrl.text.isNotEmpty) {
                await _dbService.createUser(
                  usernameCtrl.text.trim(),
                  passwordCtrl.text.trim(),
                  role,
                );
                Navigator.pop(context);
                _loadCounts();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content:
                          Text("${role.toUpperCase()} created successfully")),
                );
              }
            },
            child: const Text("Create"),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String title, int count, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: color,
          child: Icon(icon, color: Colors.white),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: Text(
          "$count",
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  /// 🔹 Show list of users (doctor/asha)
  void _showUserList(String role) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UserListScreen(role: role),
      ),
    );
  }

  /// 🔹 Logout with redirection
  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false, // remove all routes
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: "Logout",
            onPressed: _logout,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadCounts,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Text("Overview",
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 10),

                  _buildStatCard("Doctors", doctorCount, Icons.medical_services,
                      Colors.blue, () => _showUserList("doctor")),
                  _buildStatCard("ASHA Workers", ashaCount, Icons.people,
                      Colors.orange, () => _showUserList("asha")),
                  _buildStatCard("Patients", patientCount, Icons.person,
                      Colors.red, () {}), // Patients list later

                  const SizedBox(height: 20),
                  Text("Manage Users",
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 10),

                  ElevatedButton.icon(
                    onPressed: () => _addUserDialog("doctor"),
                    icon: const Icon(Icons.person_add),
                    label: const Text("Add Doctor"),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: () => _addUserDialog("asha"),
                    icon: const Icon(Icons.person_add_alt),
                    label: const Text("Add ASHA Worker"),
                  ),
                ],
              ),
            ),
    );
  }
}

/// 🔹 User List Screen for Doctors / ASHA
class UserListScreen extends StatelessWidget {
  final String role;
  const UserListScreen({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("${role.toUpperCase()} List")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("users")
            .where("role", isEqualTo: role)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return Center(child: Text("No ${role.toUpperCase()} found."));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(data['username'] ?? "Unknown"),
                  subtitle:
                      Text("Password: ${data['password'] ?? 'Not Available'}"),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
