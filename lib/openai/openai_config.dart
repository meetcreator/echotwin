import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:echotwin/models/decision.dart';

class OpenAIConfig {
  static const apiKey = String.fromEnvironment('OPENAI_PROXY_API_KEY');
  static const endpoint = String.fromEnvironment('OPENAI_PROXY_ENDPOINT');

  static Future<String> getEchoTwinResponse(
      String userDilemma, {
        List<Decision>? pastDecisions,
        String reasoningStyle = 'analytical',
      }) async {
    final styleContext = reasoningStyle == 'analytical'
        ? 'Focus on logic, data, concrete tradeoffs, and measurable outcomes.'
        : 'Focus on emotions, values, deeper meaning, and personal alignment.';

    String contextAddition = '';
    if (pastDecisions != null && pastDecisions.isNotEmpty) {
      final recentDecisions = pastDecisions.take(3).toList();
      final summaries = recentDecisions
          .map((d) => '- ${d.userDilemma.substring(0, d.userDilemma.length > 100 ? 100 : d.userDilemma.length)}...')
          .join('\n');

      contextAddition = '''

DECISION RECALL CONTEXT:
The user has made these past decisions:
$summaries

If the current dilemma relates to any past decision, briefly reference it in your reflection (1 sentence max). For example: "Last time you faced something similar, you prioritized X."
Only reference if genuinely relevant. Do not force connections.''';
    }

    final systemPrompt = '''You are EchoTwin — a decision analysis tool.

Your job: reflect thinking, surface tradeoffs, identify blind spots.

$styleContext

Rules:
1. Reflect the dilemma in 2-3 sentences. Be specific about what you observe.
2. List key options with their concrete tradeoffs. What improves, what worsens.
3. Keep it to 3-4 bullet points maximum.
4. Speak in probabilities, not certainties.
5. End with ONE clarifying question.
6. No emojis. No hype. No motivational language. No "as an AI" phrasing.
7. Challenge inconsistent thinking directly but without judgment.

You reflect, not advise.$contextAddition

RESPONSE FORMAT (use exactly):

WHAT I HEAR
<2-3 sentence reflection>

TRADEOFFS TO CONSIDER
• Option A: benefit vs cost
• Option B: benefit vs cost
• (Optional) Hidden tradeoff

SUGGESTED DIRECTION
<A framing, not a command>

ONE QUESTION FOR YOU
<Single clarifying question>''';

    try {
      final response = await http.post(
        Uri.parse(endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer \$apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-4o',
          'messages': [
            {'role': 'system', 'content': systemPrompt},
            {'role': 'user', 'content': userDilemma},
          ],
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return data['choices'][0]['message']['content'];
      } else {
        throw Exception('Failed to get response: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error communicating with EchoTwin: $e');
    }
  }
}
