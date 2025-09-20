// lib/services/teleconsultation_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/session.dart';

class TeleconsultationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> createSession(
    String patientId,
    String doctorId, {
    required String channelName,
  }) async {
    final doc = await _firestore.collection("sessions").add({
      "patientId": patientId,
      "doctorId": doctorId,
      "channelName": channelName,
      "status": "pending",
      "createdAt": FieldValue.serverTimestamp(),
    });
    return doc.id;
  }

  Stream<Session> listenToSession(String sessionId) {
    return _firestore
        .collection("sessions")
        .doc(sessionId)
        .snapshots()
        .map((snap) => Session.fromMap(snap.id, snap.data() ?? {}));
  }

  Future<void> acceptSession(String sessionId, String token) async {
    await _firestore.collection("sessions").doc(sessionId).update({
      "status": "active",
      "token": token,
      "updatedAt": FieldValue.serverTimestamp(),
    });
  }
}
