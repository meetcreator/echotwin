import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';

import '../services/voice_input_service.dart';
import '../services/history_service.dart';
import '../services/elevenlabs_service.dart';
import '../nav.dart';

class ResponsePage extends StatefulWidget {
  final String text;

  const ResponsePage({super.key, required this.text});

  @override
  State<ResponsePage> createState() => _ResponsePageState();
}

class _ResponsePageState extends State<ResponsePage> {
  final AudioPlayer _player = AudioPlayer();

  bool _loadingAudio = false;
  String? _audioBase64;
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    _initResponse();
  }

  Future<void> _initResponse() async {
    // ✅ Save history ONCE
    if (!_saved) {
      _saved = true;
      await HistoryService().saveDecision(
        userDilemma: widget.text,
        echoTwinResponse: widget.text, // replace later with AI output
      );
    }

    // ✅ Generate ElevenLabs audio
    setState(() => _loadingAudio = true);

    final audio = await ElevenLabsService.textToSpeech(
      widget.text,
      voiceTone: 'calm',
    );

    if (!mounted) return;

    _audioBase64 = audio;
    setState(() => _loadingAudio = false);

    if (_audioBase64 != null) {
      final bytes = base64Decode(_audioBase64!.split(',').last);
      await _player.play(BytesSource(bytes));
    }
  }

  void _playAudio() async {
    if (_audioBase64 == null) return;
    final bytes = base64Decode(_audioBase64!.split(',').last);
    await _player.play(BytesSource(bytes));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F14),

      // ✅ BACK + REPLAY
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B0F14),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.go(AppRoutes.home),
        ),
        title: const Text("EchoTwin Response"),
        actions: [
          IconButton(
            icon: _loadingAudio
                ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
                : const Icon(Icons.volume_up, color: Colors.white),
            onPressed: _loadingAudio ? null : _playAudio,
          ),
        ],
      ),

      // ✅ MIC FOR NEXT DECISION
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF6F7BF7),
        child: const Icon(Icons.mic, color: Colors.white),
        onPressed: () async {
          final voice = VoiceInputService();
          final ready = await voice.init();
          if (!ready) return;

          voice.startListening(
            onResult: (spokenText) {
              if (spokenText.isEmpty) return;

              context.pushReplacement(
                AppRoutes.thinking,
                extra: spokenText,
              );
            },
          );
        },
      ),

      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Text(
            widget.text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              height: 1.4,
            ),
          ),
        ),
      ),
    );
  }
}
