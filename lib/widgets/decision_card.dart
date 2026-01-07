import 'package:flutter/material.dart';

enum DecisionStatus { open, decided }

class DecisionCard extends StatelessWidget {
  final String title;
  final String date;
  final DecisionStatus status;

  const DecisionCard({
    super.key,
    required this.title,
    required this.date,
    required this.status,
  });

  static const Color accent = Color(0xFF6F7BF7);

  @override
  Widget build(BuildContext context) {
    final isDecided = status == DecisionStatus.decided;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDecided
              ? accent.withOpacity(0.35)
              : Colors.white.withOpacity(0.1),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Timeline indicator
          Column(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDecided ? accent : Colors.white.withOpacity(0.4),
                ),
              ),
              Container(
                width: 2,
                height: 48,
                color: Colors.white.withOpacity(0.15),
              ),
            ],
          ),

          const SizedBox(width: 14),

          /// Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      date,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white.withOpacity(0.5),
                      ),
                    ),
                    const SizedBox(width: 12),
                    _StatusChip(isDecided: isDecided),
                  ],
                ),
              ],
            ),
          ),

          /// Replay icon (UI only)
          Icon(
            Icons.volume_up_rounded,
            color: Colors.white.withOpacity(0.5),
            size: 20,
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final bool isDecided;

  const _StatusChip({required this.isDecided});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isDecided
            ? DecisionCard.accent.withOpacity(0.15)
            : Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isDecided ? "Decided" : "Open",
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: isDecided
              ? DecisionCard.accent
              : Colors.white.withOpacity(0.6),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
