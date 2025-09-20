// lib/models/session.dart
class Session {
  final String id;
  final String patientId;
  final String doctorId;
  final String channelName;
  final String status;
  final String? token;

  Session({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.channelName,
    required this.status,
    this.token,
  });

  factory Session.fromMap(String id, Map<String, dynamic> data) {
    return Session(
      id: id,
      patientId: data['patientId'] ?? '',
      doctorId: data['doctorId'] ?? '',
      channelName: data['channelName'] ?? '',
      status: data['status'] ?? 'pending',
      token: data['token'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "patientId": patientId,
      "doctorId": doctorId,
      "channelName": channelName,
      "status": status,
      "token": token,
      "createdAt": DateTime.now(),
    };
  }
}
