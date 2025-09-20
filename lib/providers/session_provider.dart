import 'package:flutter/material.dart';
import '../models/session.dart';
import '../services/teleconsultation_service.dart';

class SessionProvider with ChangeNotifier {
  final TeleconsultationService _service = TeleconsultationService();
  Session? _currentSession;

  Session? get currentSession => _currentSession;

  // Patient creates session
  Future<String> createSession(
    String patientId,
    String doctorId, {
    required String channelName, // ✅ add channelName
  }) async {
    String sessionId =
        await _service.createSession(patientId, doctorId, channelName: channelName);
    listenToSession(sessionId);
    return sessionId;
  }

  // Listen for session updates
  void listenToSession(String sessionId) {
    _service.listenToSession(sessionId).listen((session) {
      _currentSession = session;
      notifyListeners();
    });
  }

  // Doctor accepts session
  Future<void> acceptSession(String sessionId, String token) async {
    await _service.acceptSession(sessionId, token);
  }
}
