import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/voice_input_service.dart';
import '../nav.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  bool _hasNavigated = false;

  static const Color micColor = Color(0xFF6F7BF7);

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _scale = Tween(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F14),

      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF0B0F14),
        selectedItemColor: const Color(0xFF6F7BF7),
        unselectedItemColor: Colors.white54,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.mic),
            label: 'Speak',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        onTap: (index) {
          if (index == 1) {
            context.push('/history');
          } else if (index == 2) {
            context.push('/settings');
          }
        },
      ),

      body: Center(
        child: GestureDetector(
          onTap: () async {
            if (_hasNavigated) return;

            final voice = VoiceInputService();

            // ✅ init() is called HERE
            final ready = await voice.init();
            if (!ready) {
              print("❌ Speech engine not available");
              return;
            }

            voice.startListening(
              onResult: (spokenText) {
                if (_hasNavigated) return;
                if (spokenText.isEmpty) return;

                _hasNavigated = true;

                context.push(
                  AppRoutes.thinking,
                  extra: spokenText,
                );
              },
            );



          },

          child: AnimatedBuilder(
            animation: _controller,
            builder: (_, __) {
              return Transform.scale(
                scale: _scale.value,
                child: Container(
                  width: 96,
                  height: 96,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: micColor,
                  ),
                  child: const Icon(
                    Icons.mic_rounded,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
