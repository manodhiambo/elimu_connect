import 'package:flutter/material.dart';

class AppSettingsScreen extends StatelessWidget {
  const AppSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('App Settings')),
      body: ListView(
        children: const [
          ListTile(
            leading: Icon(Icons.dark_mode),
            title: Text('Dark Mode'),
            trailing: Switch(value: false, onChanged: null), // Add logic
          ),
          ListTile(
            leading: Icon(Icons.security),
            title: Text('Enable 2FA'),
            trailing: Switch(value: false, onChanged: null), // Add logic
          ),
          ListTile(
            leading: Icon(Icons.update),
            title: Text('Check for Updates'),
            onTap: null, // Add update logic
          ),
        ],
      ),
    );
  }
}
