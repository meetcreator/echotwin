import 'package:speech_to_text/speech_to_text.dart';

class VoiceInputService {
  final SpeechToText _speech = SpeechToText();
  bool _isListening = false;

  Future<bool> init() async {
    return await _speech.initialize(
      onStatus: (status) => print("🎙 STATUS: $status"),
      onError: (error) => print("❌ ERROR: $error"),
    );
  }

  void startListening({
    required Function(String text) onResult,
  }) {
    if (_isListening) return;
    _isListening = true;

    print("🎤 Listening started");

    _speech.listen(
      localeId: 'en_IN', // use en_US if needed
      listenFor: const Duration(seconds: 12), // 🔴 IMPORTANT
      pauseFor: const Duration(seconds: 3),   // 🔴 IMPORTANT
      partialResults: true,                   // 🔴 MUST BE TRUE
      cancelOnError: true,
      onResult: (result) {
        print("📝 Words: ${result.recognizedWords}");
        print("✅ Final: ${result.finalResult}");

        // Accept ONLY when final result arrives
        if (result.finalResult &&
            result.recognizedWords.trim().isNotEmpty) {
          _isListening = false;

          final cleaned = result.recognizedWords
              .trim()
              .replaceAll(RegExp(r'\s+'), ' ')
              .replaceAll(RegExp(r'[^\w\s]'), '');

          _speech.stop();
          onResult(cleaned);
        }
      },
    );
  }

  void stopListening() {
    if (_speech.isListening) {
      _speech.stop();
      _isListening = false;
      print("🛑 Listening stopped");
    }
  }
}
