import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class ElevenLabsService {
  static const apiKey = String.fromEnvironment('ELEVENLABS_API_KEY');
  static const voiceId = '21m00Tcm4TlvDq8ikWAM'; // Rachel voice (calm, professional)

  static Future<String?> textToSpeech(String text, {String voiceTone = 'calm'}) async {
    if (apiKey.isEmpty) {
      debugPrint('ElevenLabs API key not configured');
      return null;
    }

    try {
      final response = await http.post(
        Uri.parse('https://api.elevenlabs.io/v1/text-to-speech/$voiceId'),
        headers: {
          'Content-Type': 'application/json',
          'xi-api-key': apiKey,
        },
        body: jsonEncode({
          'text': text,
          'model_id': 'eleven_monolingual_v1',
          'voice_settings': {
            'stability': voiceTone == 'calm' ? 0.75 : 0.5,
            'similarity_boost': 0.75,
            'style': voiceTone == 'calm' ? 0.0 : 0.5,
          },
        }),
      );

      if (response.statusCode == 200) {
        final audioBytes = response.bodyBytes;
        final base64Audio = base64Encode(audioBytes);
        return 'data:audio/mpeg;base64,$base64Audio';
      } else {
        debugPrint('ElevenLabs API error: ${response.statusCode} ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('Error generating speech: $e');
      return null;
    }
  }
}
