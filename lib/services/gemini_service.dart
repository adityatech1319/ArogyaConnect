// lib/services/gemini_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiService {
  final String apiKey;
  GeminiService(this.apiKey);

  /// Ask Gemini for diagnosis based on symptoms + patient info
  Future<String> getDiagnosis(String patientInfo, List<String> symptoms) async {
    final url = Uri.parse(
        "https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=$apiKey");

    final body = {
      "contents": [
        {
          "parts": [
            {
              "text":
                  "The patient details are: $patientInfo. The patient reports the following symptoms: ${symptoms.join(", ")}. "
                      "Please explain possible conditions in very simple language for non-medical people."
            }
          ]
        }
      ]
    };

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["candidates"]?[0]?["content"]?["parts"]?[0]?["text"] ??
          "⚠️ No diagnosis received.";
    } else {
      throw Exception("Gemini API error: ${response.body}");
    }
  }
}
