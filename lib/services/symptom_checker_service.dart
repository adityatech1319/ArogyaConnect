// lib/screens/symptom_checker_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
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
    {"name": "Fever", "emoji": "🔥", "name_pa": "ਬੁਖਾਰ"},
    {"name": "Cough", "emoji": "🤧", "name_pa": "ਖੰਘ"},
    {"name": "Headache", "emoji": "🤕", "name_pa": "ਸਿਰਦਰਦ"},
    {"name": "Fatigue", "emoji": "😴", "name_pa": "ਥਕਾਵਟ"},
    {"name": "Chest Pain", "emoji": "❤️‍🔥", "name_pa": "ਛਾਤੀ ਦਰਦ"},
    {"name": "Breathing Problem", "emoji": "😮‍💨", "name_pa": "ਸਾਹ ਲੈਣ ਵਿੱਚ ਸਮੱਸਿਆ"},
    {"name": "Sore Throat", "emoji": "😷", "name_pa": "ਗਲੇ ਵਿੱਚ ਦਰਦ"},
    {"name": "Nausea", "emoji": "🤢", "name_pa": "ਮਤਲੀ"},
    {"name": "Diarrhea", "emoji": "🚽", "name_pa": "ਦਸਤ"},
    {"name": "Back Pain", "emoji": "🦴", "name_pa": "ਕਮਰ ਦਰਦ"},
  ];

  final Set<String> _selectedSymptoms = {};
  String? _diagnosis;
  bool _loading = false;

  late final GeminiService _gemini;
  final FlutterTts _tts = FlutterTts();
  final ScrollController _scrollController = ScrollController();

  bool _isPunjabi = false; // ✅ toggle state

  // ✅ UI translations
  final Map<String, Map<String, String>> _translations = {
    "en": {
      "title": "🩺 Symptom Checker",
      "selectSymptoms": "👉 Select Your Problems",
      "checkCondition": "Check Condition",
      "hearResult": "Hear Result",
      "clearSymptoms": "Clear Symptoms",
      "errorSelect": "⚠️ Please tap on the symptoms you feel."
    },
    "pa": {
      "title": "🩺 ਲੱਛਣ ਜਾਂਚਕਰਤਾ",
      "selectSymptoms": "👉 ਆਪਣੀਆਂ ਸਮੱਸਿਆਵਾਂ ਚੁਣੋ",
      "checkCondition": "ਬੀਮਾਰੀ ਜਾਂਚੋ",
      "hearResult": "ਨਤੀਜਾ ਸੁਣੋ",
      "clearSymptoms": "ਲੱਛਣ ਹਟਾਓ",
      "errorSelect": "⚠️ ਕਿਰਪਾ ਕਰਕੇ ਘੱਟੋ-ਘੱਟ ਇੱਕ ਲੱਛਣ ਚੁਣੋ।"
    },
  };

  @override
  void initState() {
    super.initState();
    _gemini = GeminiService(AppConstants.geminiApiKey);

    _tts.setSpeechRate(0.5);
    _tts.setPitch(1.0);
    _tts.setLanguage("en-IN");
  }

  @override
  void dispose() {
    _tts.stop();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _checkSymptoms() async {
    final lang = _isPunjabi ? "pa" : "en";

    if (_selectedSymptoms.isEmpty) {
      setState(() => _diagnosis = _translations[lang]!["errorSelect"]!);
      return;
    }

    setState(() {
      _loading = true;
      _diagnosis = null;
    });

    final patientInfo = widget.patient == null
        ? "No extra patient info."
        : "Age: ${widget.patient!.age}, Gender: ${widget.patient!.gender}";

    try {
      final response = await _gemini.getDiagnosis(
        patientInfo: patientInfo,
        symptoms: _selectedSymptoms.toList(),
      );

      setState(() => _diagnosis = response);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(0);
        }
      });

      await _tts.speak(response);
    } catch (e) {
      setState(() => _diagnosis = "⚠️ Error: $e");
    } finally {
      setState(() => _loading = false);
    }
  }

  void _resetSymptoms() {
    setState(() {
      _selectedSymptoms.clear();
      _diagnosis = null;
    });
  }

  void _toggleLanguage() {
    setState(() {
      _isPunjabi = !_isPunjabi;
      _tts.setLanguage(_isPunjabi ? "pa-IN" : "en-IN");
    });
  }

  @override
  Widget build(BuildContext context) {
    final lang = _isPunjabi ? "pa" : "en";

    return Scaffold(
      backgroundColor: Colors.teal.shade50,
      appBar: AppBar(
        title: Text(_translations[lang]!["title"]!),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(_isPunjabi ? Icons.language : Icons.translate),
            tooltip: "Switch Language",
            onPressed: _toggleLanguage,
          ),
          if (_selectedSymptoms.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: "Reset",
              onPressed: _resetSymptoms,
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (widget.patient != null)
              Card(
                color: Colors.white,
                child: ListTile(
                  leading: const Icon(Icons.person, color: Colors.teal),
                  title: Text(
                      "👤 Age: ${widget.patient!.age}, Gender: ${widget.patient!.gender}"),
                ),
              ),
            const SizedBox(height: 12),

            Text(
              _translations[lang]!["selectSymptoms"]!,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                ),
                itemCount: _symptoms.length,
                itemBuilder: (context, index) {
                  final symptom = _symptoms[index];
                  final selected = _selectedSymptoms.contains(symptom["name"]);

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selected
                            ? _selectedSymptoms.remove(symptom["name"])
                            : _selectedSymptoms.add(symptom["name"]);
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: selected ? Colors.teal.shade200 : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: selected ? Colors.teal : Colors.grey,
                          width: 2,
                        ),
                        boxShadow: const [
                          BoxShadow(
                              color: Colors.black12,
                              blurRadius: 5,
                              offset: Offset(2, 2))
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(symptom["emoji"],
                              style: const TextStyle(fontSize: 40)),
                          const SizedBox(height: 6),
                          Text(
                            _isPunjabi ? symptom["name_pa"] : symptom["name"],
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            if (_selectedSymptoms.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: ElevatedButton.icon(
                  onPressed: _resetSymptoms,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                  ),
                  icon: const Icon(Icons.delete),
                  label: Text(_translations[lang]!["clearSymptoms"]!),
                ),
              ),

            ElevatedButton.icon(
              onPressed: _checkSymptoms,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              icon: const Icon(Icons.health_and_safety, size: 24),
              label: Text(_translations[lang]!["checkCondition"]!,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 16),

            if (_loading) const CircularProgressIndicator(),

            if (_diagnosis != null && !_loading)
              Flexible(
                child: Card(
                  color: Colors.yellow.shade100,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            controller: _scrollController,
                            child: SelectableText(
                              _diagnosis!,
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.w500),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: () async {
                            if (_diagnosis != null) {
                              await _tts.speak(_diagnosis!);
                            }
                          },
                          icon: const Icon(Icons.volume_up),
                          label: Text(_translations[lang]!["hearResult"]!),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
