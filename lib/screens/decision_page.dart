import 'package:flutter/material.dart';
import 'package:echotwin/openai/openai_config.dart';
import 'package:echotwin/models/decision.dart';
import 'package:echotwin/services/decision_service.dart';
import 'package:echotwin/services/speech_service.dart';
import 'package:echotwin/services/elevenlabs_service.dart';
import 'package:echotwin/services/settings_service.dart';
import 'package:go_router/go_router.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:just_audio/just_audio.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart';

enum DecisionState { listening, thinking, response }

class DecisionPage extends StatefulWidget {
  const DecisionPage({super.key});

  @override
  State<DecisionPage> createState() => _DecisionPageState();
}

class _DecisionPageState extends State<DecisionPage> with SingleTickerProviderStateMixin {
  final _speechService = SpeechService();
  final _decisionService = DecisionService();
  final _settingsService = SettingsService();
  final _audioPlayer = AudioPlayer();

  DecisionState _state = DecisionState.listening;
  String _transcribedText = '';
  String? _response;
  String? _audioUrl;
  String? _error;
  bool _isListening = false;
  bool _isPlayingAudio = false;

  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _initializeSpeech();

    _audioPlayer.playerStateStream.listen((playerState) {
      if (mounted) {
        setState(() {
          _isPlayingAudio = playerState.playing;
        });
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _speechService.stopListening();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _initializeSpeech() async {
    await _speechService.initialize();
  }

  Future<void> _startListening() async {
    setState(() {
      _isListening = true;
      _error = null;
      _transcribedText = '';
    });

    await _speechService.startListening(
      onResult: (text) {
        setState(() => _transcribedText = text);
      },
      onDone: () {
        if (_transcribedText.isNotEmpty) {
          _processDecision();
        }
      },
    );
  }

  Future<void> _stopListening() async {
    await _speechService.stopListening();
    setState(() => _isListening = false);
    if (_transcribedText.isNotEmpty) {
      _processDecision();
    }
  }

  Future<void> _processDecision() async {
    if (_transcribedText.trim().isEmpty) {
      setState(() {
        _error = 'No speech detected. Please try again.';
        _state = DecisionState.listening;
      });
      return;
    }

    setState(() {
      _state = DecisionState.thinking;
      _error = null;
    });

    try {
      final pastDecisions = await _decisionService.getDecisions();
      final voiceTone = await _settingsService.getVoiceTone();
      final reasoningStyle = await _settingsService.getReasoningStyle();

      final response = await OpenAIConfig.getEchoTwinResponse(
        _transcribedText.trim(),
        pastDecisions: pastDecisions,
        reasoningStyle: reasoningStyle,
      );

      String? audioUrl;
      try {
        audioUrl = await ElevenLabsService.textToSpeech(response, voiceTone: voiceTone);
      } catch (e) {
        debugPrint('Voice generation failed: $e');
      }

      final decision = Decision(
        id: const Uuid().v4(),
        userDilemma: _transcribedText.trim(),
        echoTwinResponse: response,
        createdAt: DateTime.now(),
        audioUrl: audioUrl,
      );

      await _decisionService.saveDecision(decision);

      if (mounted) {
        setState(() {
          _response = response;
          _audioUrl = audioUrl;
          _state = DecisionState.response;
        });

        if (audioUrl != null) {
          _playAudio();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to process decision. Please try again.';
          _state = DecisionState.listening;
        });
      }
      debugPrint('Error processing decision: $e');
    }
  }

  Future<void> _playAudio() async {
    if (_audioUrl == null) return;

    try {
      await _audioPlayer.setUrl(_audioUrl!);
      await _audioPlayer.play();
    } catch (e) {
      debugPrint('Audio playback error: $e');
    }
  }

  Future<void> _toggleAudioPlayback() async {
    if (_isPlayingAudio) {
      await _audioPlayer.pause();
    } else {
      await _playAudio();
    }
  }

  void _reset() {
    setState(() {
      _state = DecisionState.listening;
      _transcribedText = '';
      _response = null;
      _audioUrl = null;
      _error = null;
    });
    _audioPlayer.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _buildStateContent(),
      ),
    );
  }

  Widget _buildStateContent() {
    switch (_state) {
      case DecisionState.listening:
        return _buildListeningUI();
      case DecisionState.thinking:
        return _buildThinkingUI();
      case DecisionState.response:
        return _buildResponseUI();
    }
  }

  Widget _buildListeningUI() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => context.pop(),
              ),
            ],
          ),
        ),
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  if (_transcribedText.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _transcribedText,
                        style: theme.textTheme.bodyLarge?.copyWith(height: 1.6),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 48),
                  ],
                  if (_transcribedText.isEmpty) ...[
                    Text(
                      _isListening ? 'Listening...' : 'Tap to speak',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 64),
                  ],
                  GestureDetector(
                    onTap: _isListening ? _stopListening : _startListening,
                    child: AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) => Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              _isListening ? colorScheme.secondary : colorScheme.primary,
                              (_isListening ? colorScheme.secondary : colorScheme.primary)
                                  .withValues(alpha: 0.8),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: (_isListening ? colorScheme.secondary : colorScheme.primary)
                                  .withValues(alpha: _isListening ? _pulseController.value * 0.5 : 0.3),
                              blurRadius: _isListening ? 24 + (_pulseController.value * 12) : 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Icon(
                          _isListening ? Icons.stop_rounded : Icons.mic_rounded,
                          size: 64,
                          color: _isListening ? colorScheme.onSecondary : colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ),
                  if (_transcribedText.isNotEmpty) ...[
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _processDecision,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      ),
                      child: const Text('Continue'),
                    ),
                  ],
                  const Spacer(),
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: Text(
                        _error!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.error,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildThinkingUI() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 48.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) => Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colorScheme.primary.withValues(alpha: 0.1 + (_pulseController.value * 0.2)),
                ),
                child: Center(
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colorScheme.primary.withValues(alpha: 0.3 + (_pulseController.value * 0.3)),
                    ),
                    child: Center(
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 48),
            DefaultTextStyle(
              style: theme.textTheme.titleLarge!.copyWith(
                fontWeight: FontWeight.w500,
              ),
              child: AnimatedTextKit(
                animatedTexts: [
                  TypewriterAnimatedText(
                    'EchoTwin is reasoning...',
                    speed: const Duration(milliseconds: 80),
                  ),
                ],
                isRepeatingAnimation: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResponseUI() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => context.pop(),
              ),
              if (_audioUrl != null)
                IconButton(
                  icon: Icon(_isPlayingAudio ? Icons.pause_circle : Icons.play_circle),
                  iconSize: 32,
                  color: colorScheme.primary,
                  onPressed: _toggleAudioPlayback,
                ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.person, size: 20, color: colorScheme.primary),
                          const SizedBox(width: 8),
                          Text(
                            'Your Dilemma',
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _transcribedText,
                        style: theme.textTheme.bodyMedium?.copyWith(height: 1.6),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                ResponseCard(response: _response!),
                const SizedBox(height: 32),
                OutlinedButton.icon(
                  onPressed: _reset,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Start Another Decision'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class ResponseCard extends StatelessWidget {
  final String response;

  const ResponseCard({super.key, required this.response});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final sections = _parseResponse(response);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: sections.map((section) => Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (section['title'] != null)
                Text(
                  section['title']!,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.primary,
                  ),
                ),
              if (section['title'] != null) const SizedBox(height: 12),
              Text(
                section['content']!,
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.7),
              ),
            ],
          ),
        )).toList(),
      ),
    );
  }

  List<Map<String, String?>> _parseResponse(String response) {
    final sections = <Map<String, String?>>[];
    final lines = response.split('\n');
    String? currentTitle;
    final currentContent = StringBuffer();

    for (final line in lines) {
      if (line.trim().isEmpty) continue;

      if (line.toUpperCase() == line && line.trim().isNotEmpty && !line.startsWith('•')) {
        if (currentTitle != null) {
          sections.add({
            'title': currentTitle,
            'content': currentContent.toString().trim(),
          });
          currentContent.clear();
        }
        currentTitle = line.trim();
      } else {
        if (currentContent.isNotEmpty) {
          currentContent.write('\n');
        }
        currentContent.write(line);
      }
    }

    if (currentTitle != null) {
      sections.add({
        'title': currentTitle,
        'content': currentContent.toString().trim(),
      });
    }

    return sections;
  }
}
