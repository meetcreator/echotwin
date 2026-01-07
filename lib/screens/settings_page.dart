import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F14),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B0F14),
        title: const Text("Settings"),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text("Use Indian Accent",
                style: TextStyle(color: Colors.white)),
            value: true,
            onChanged: (_) {},
          ),
          ListTile(
            title: const Text("Clear History",
                style: TextStyle(color: Colors.redAccent)),
            onTap: () {},
          ),
          const ListTile(
            title: Text("EchoTwin v1.0",
                style: TextStyle(color: Colors.white54)),
          ),
        ],
      ),
    );
  }
}
