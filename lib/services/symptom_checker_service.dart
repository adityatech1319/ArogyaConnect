import 'dart:convert';
import 'package:http/http.dart' as http;

class SymptomCheckerService {
  final String apiKey = "AIzaSyA_0h7Xe1BCRdPRhiEsRCO2-on0KfTcHAw"; // 🔑 replace with your Gemini key
  final String baseUrl = "https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent";

  Future<String> checkSymptoms(List<String> symptoms) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl?key=$apiKey"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {
                  "text":
                      "The patient reports these symptoms: ${symptoms.join(", ")}. "
                          "Please give a simple and easy-to-understand explanation of possible health issues "
                          "and when they should see a doctor. Keep the language very simple."
                }
              ]
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data["candidates"][0]["content"]["parts"][0]["text"] ??
            "I couldn't generate a response.";
      } else {
        return "Error: ${response.statusCode} - ${response.body}";
      }
    } catch (e) {
      return "Error: $e";
    }
  }
}
