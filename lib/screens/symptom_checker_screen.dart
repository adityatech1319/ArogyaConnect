import 'package:flutter/material.dart';
import 'package:arogyaconnect/models/patient.dart';
import 'package:arogyaconnect/services/gemini_service.dart';
import 'package:arogyaconnect/core/constants.dart';

class SymptomCheckerScreen extends StatefulWidget {
  final Patient? patient;

  const SymptomCheckerScreen({super.key, this.patient});

  @override
  State<SymptomCheckerScreen> createState() => _SymptomCheckerScreenState();
}

class _SymptomCheckerScreenState extends State<SymptomCheckerScreen> {
  final List<Map<String, dynamic>> _symptoms = [
    {"name": "Fever", "icon": Icons.thermostat, "emoji": "🔥"},
    {"name": "Cough", "icon": Icons.sick, "emoji": "🤧"},
    {"name": "Headache", "icon": Icons.psychology, "emoji": "🤕"},
    {"name": "Fatigue", "icon": Icons.battery_alert, "emoji": "😴"},
    {"name": "Chest Pain", "icon": Icons.favorite, "emoji": "❤️‍🔥"},
    {"name": "Breathing Problem", "icon": Icons.air, "emoji": "😮‍💨"},
    {"name": "Sore Throat", "icon": Icons.record_voice_over, "emoji": "😷"},
    {"name": "Nausea", "icon": Icons.local_hospital, "emoji": "🤢"},
    {"name": "Diarrhea", "icon": Icons.wc, "emoji": "🚽"},
    {"name": "Back Pain", "icon": Icons.accessibility_new, "emoji": "🦴"},
  ];

  final Set<String> _selectedSymptoms = {};
  String? _diagnosis;
  bool _loading = false;

  late final GeminiService _gemini;

  @override
  void initState() {
    super.initState();
    _gemini = GeminiService(AppConstants.geminiApiKey);
  }

  Future<void> _checkSymptoms() async {
    if (_selectedSymptoms.isEmpty) {
      setState(() {
        _diagnosis = "⚠️ Please tap on the symptoms you feel.";
      });
      return;
    }

    setState(() {
      _loading = true;
      _diagnosis = null;
    });

    final patientInfo = widget.patient == null
        ? "No extra patient info."
        : "Name: ${widget.patient!.name}, Age: ${widget.patient!.age}, Gender: ${widget.patient!.gender}";

    try {
      final response =
          await _gemini.getDiagnosis(patientInfo, _selectedSymptoms.toList());

      setState(() {
        _diagnosis = response;
      });
    } catch (e) {
      setState(() {
        _diagnosis =
            "⚠️ Error connecting to AI service. Please try again.\n${e.toString()}";
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Symptom Checker"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (widget.patient != null) ...[
              Text(
                "👤 Patient: ${widget.patient!.name} (Age: ${widget.patient!.age}, Gender: ${widget.patient!.gender})",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
            ],

            const Text(
              "👉 Tap the symptoms you feel",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Symptoms Grid
            Expanded(
              child: GridView.builder(
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                ),
                itemCount: _symptoms.length,
                itemBuilder: (context, index) {
                  final symptom = _symptoms[index];
                  final selected =
                      _selectedSymptoms.contains(symptom["name"]);

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (selected) {
                          _selectedSymptoms.remove(symptom["name"]);
                        } else {
                          _selectedSymptoms.add(symptom["name"]);
                        }
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: selected ? Colors.blue.shade100 : Colors.white,
                        border: Border.all(
                          color: selected ? Colors.blue : Colors.grey,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 5,
                            offset: Offset(2, 2),
                          )
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(symptom["emoji"],
                              style: const TextStyle(fontSize: 40)),
                          const SizedBox(height: 8),
                          Icon(symptom["icon"],
                              size: 30, color: Colors.black87),
                          const SizedBox(height: 6),
                          Text(
                            symptom["name"],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            ElevatedButton(
              onPressed: _checkSymptoms,
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                "Check Condition",
                style: TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 16),

            if (_loading) const CircularProgressIndicator(),

            if (_diagnosis != null && !_loading)
              Card(
                color: Colors.yellow.shade100,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    _diagnosis!,
                    style: const TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
