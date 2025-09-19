import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'screens/login_screen.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // ✅ Enable Firestore offline persistence (not supported on web)
    if (!kIsWeb) {
      FirebaseFirestore.instance.settings = const Settings(
        persistenceEnabled: true,
      );
    }
  } catch (e) {
    print("Firebase initialization error: $e");
    // Handle error appropriately (e.g., show error UI)
  }

  runApp(const ArogyaConnectApp());
}

class ArogyaConnectApp extends StatelessWidget {
  const ArogyaConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Arogya Connect",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}