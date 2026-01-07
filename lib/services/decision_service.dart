import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:echotwin/models/decision.dart';
import 'package:flutter/foundation.dart';

class DecisionService {
  static const _storageKey = 'decisions';

  Future<List<Decision>> getDecisions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final decisionsJson = prefs.getString(_storageKey);

      if (decisionsJson == null) return [];

      final List<dynamic> decoded = jsonDecode(decisionsJson);
      return decoded.map((json) {
        try {
          return Decision.fromJson(json as Map<String, dynamic>);
        } catch (e) {
          debugPrint('Skipping corrupted decision entry: $e');
          return null;
        }
      }).whereType<Decision>().toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      debugPrint('Error loading decisions: $e');
      return [];
    }
  }

  Future<void> saveDecision(Decision decision) async {
    try {
      final decisions = await getDecisions();
      decisions.insert(0, decision);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_storageKey, jsonEncode(decisions.map((d) => d.toJson()).toList()));
    } catch (e) {
      debugPrint('Error saving decision: $e');
      rethrow;
    }
  }

  Future<void> deleteDecision(String id) async {
    try {
      final decisions = await getDecisions();
      decisions.removeWhere((d) => d.id == id);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_storageKey, jsonEncode(decisions.map((d) => d.toJson()).toList()));
    } catch (e) {
      debugPrint('Error deleting decision: $e');
      rethrow;
    }
  }
}
