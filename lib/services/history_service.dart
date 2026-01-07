import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/decision.dart';
import 'package:uuid/uuid.dart';

class HistoryService {
  static const _key = 'decision_history';
  static const _uuid = Uuid();

  Future<void> saveDecision({
    required String userDilemma,
    required String echoTwinResponse,
    String? audioUrl,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final history = await getHistory();

    final decision = Decision(
      id: _uuid.v4(),
      userDilemma: userDilemma,
      echoTwinResponse: echoTwinResponse,
      createdAt: DateTime.now(),
      audioUrl: audioUrl,
    );

    history.insert(0, decision);

    final encoded =
    history.map((d) => jsonEncode(d.toJson())).toList();

    await prefs.setStringList(_key, encoded);
  }

  Future<List<Decision>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];

    return raw
        .map((e) => Decision.fromJson(jsonDecode(e)))
        .toList();
  }

  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
