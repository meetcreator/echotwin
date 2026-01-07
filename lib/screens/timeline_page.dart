import 'package:flutter/material.dart';
import '../widgets/decision_card.dart';

class TimelinePage extends StatelessWidget {
  const TimelinePage({super.key});

  static const Color bgColor = Color(0xFF0B0F14);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        title: const Text(
          "Decision Timeline",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
          ),
        ),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ListView(
          children: const [
            SizedBox(height: 12),

            /// Example cards (static for now)
            DecisionCard(
              title: "Career focus for next 6 months",
              date: "Dec 18",
              status: DecisionStatus.decided,
            ),

            DecisionCard(
              title: "Whether to quit a side project",
              date: "Dec 14",
              status: DecisionStatus.open,
            ),

            DecisionCard(
              title: "Move cities or stay remote",
              date: "Dec 10",
              status: DecisionStatus.decided,
            ),

            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
