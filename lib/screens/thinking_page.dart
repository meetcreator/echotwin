import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../nav.dart';

class ThinkingPage extends StatefulWidget {
  final String userText;

  const ThinkingPage({super.key, required this.userText});

  @override
  State<ThinkingPage> createState() => _ThinkingPageState();
}

class _ThinkingPageState extends State<ThinkingPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;

      context.push(
        AppRoutes.response,
        extra: widget.userText,
      );
    });
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RotationTransition(
              turns: _controller,
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF6F7BF7),
                    width: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              "EchoTwin is reasoning…",
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}
