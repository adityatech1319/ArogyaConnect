import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';

import 'screens/login_screen.dart';
import 'firebase_options.dart';
import 'providers/session_provider.dart';
import 'services/gemini_service.dart';   // ✅ Gemini Service
import 'core/constants.dart';           // ✅ For API key

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
    debugPrint("❌ Firebase initialization error: $e");
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SessionProvider()),

        // ✅ GeminiService available globally
        Provider<GeminiService>(
          create: (_) => GeminiService(AppConstants.geminiApiKey),
        ),
      ],
      child: const ArogyaConnectApp(),
    ),
  );
}

class ArogyaConnectApp extends StatelessWidget {
  const ArogyaConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Arogya Connect",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}
