// lib/services/gemini_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiService {
  final String apiKey;
  GeminiService(this.apiKey);

  /// 🔹 Get AI-based diagnosis for a patient
  Future<String> getDiagnosis({
    required String patientInfo,
    required List<String> symptoms,
  }) async {
   final url = Uri.parse(
  "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent?key=$apiKey",
);


    final requestBody = {
      "contents": [
        {
          "parts": [
            {
              "text": 
                  "Patient details: $patientInfo\n"
                  "Reported symptoms: ${symptoms.join(", ")}\n\n"
                  "👉 Give possible health conditions in very simple, everyday language "
                  "(avoid medical jargon).\n"
                  "👉 Clearly mention: When should the patient see a doctor immediately?"
            }
          ]
        }
      ]
    };

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // ✅ Safe parsing with null checks
        final text = data["candidates"]?[0]?["content"]?["parts"]?[0]?["text"];

        return text?.trim() ?? "⚠️ No diagnosis received. Try again.";
      } else {
        return "❌ Gemini API error (${response.statusCode}):\n${response.body}";
      }
    } catch (e) {
      return "⚠️ Error connecting to Gemini API: $e";
    }
  }
}
