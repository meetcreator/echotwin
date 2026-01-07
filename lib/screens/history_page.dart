import 'package:flutter/material.dart';
import '../models/decision.dart';
import '../services/history_service.dart';
import 'package:go_router/go_router.dart';


class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F14),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B0F14),
        title: const Text("Decision History"),
      ),
      body: FutureBuilder<List<Decision>>(
        future: HistoryService().getHistory(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                "No decisions yet",
                style: TextStyle(color: Colors.white54),
              ),
            );
          }

          final history = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: history.length,
            itemBuilder: (context, index) {
              return _HistoryCard(decision: history[index]);
            },
          );
        },
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final Decision decision;

  const _HistoryCard({required this.decision});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white10,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: () {
          context.push(
            '/response',
            extra: decision.echoTwinResponse,
          );
        },
        title: Text(
          decision.userDilemma,
          style: const TextStyle(color: Colors.white),
        ),
        subtitle: Text(
          decision.echoTwinResponse,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Colors.white54),
        ),
        trailing: Text(
          decision.status,
          style: TextStyle(
            color: decision.status == 'open'
                ? Colors.orangeAccent
                : Colors.greenAccent,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

