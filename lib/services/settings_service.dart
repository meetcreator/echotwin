import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const _voiceToneKey = 'voice_tone';
  static const _reasoningStyleKey = 'reasoning_style';

  Future<String> getVoiceTone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_voiceToneKey) ?? 'calm';
  }

  Future<void> setVoiceTone(String tone) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_voiceToneKey, tone);
  }

  Future<String> getReasoningStyle() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_reasoningStyleKey) ?? 'analytical';
  }

  Future<void> setReasoningStyle(String style) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_reasoningStyleKey, style);
  }
}
