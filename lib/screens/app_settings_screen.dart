import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AppSettingsScreen extends StatefulWidget {
  const AppSettingsScreen({super.key});

  @override
  State<AppSettingsScreen> createState() => _AppSettingsScreenState();
}

class _AppSettingsScreenState extends State<AppSettingsScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _announcementController = TextEditingController();
  bool _isDarkMode = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final doc = await FirebaseFirestore.instance.collection('settings').doc('app').get();
      if (doc.exists) {
        final data = doc.data()!;
        _titleController.text = data['appTitle'] ?? '';
        _announcementController.text = data['announcement'] ?? '';
        _isDarkMode = data['darkMode'] ?? false;
      }
    } catch (e) {
      debugPrint('Error loading settings: $e');
    }

    setState(() => _isLoading = false);
  }

  Future<void> _saveSettings() async {
    try {
      await FirebaseFirestore.instance.collection('settings').doc('app').set({
        'appTitle': _titleController.text.trim(),
        'announcement': _announcementController.text.trim(),
        'darkMode': _isDarkMode,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Settings updated')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update: $e')),
      );
    }
  }

  Future<void> _resetContent() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirm Reset'),
        content: const Text('This will delete all app data (books, papers, forum). Proceed?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Reset')),
        ],
      ),
    );

    if (confirm == true) {
      // Optional: Add actual reset logic here
      // e.g., delete collections
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('App reset logic triggered.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: AppBar(title: const Text('App Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Text(
              'Update App Configuration',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'App Title'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _announcementController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Global Announcement'),
            ),
            const SizedBox(height: 10),
            SwitchListTile(
              value: _isDarkMode,
              onChanged: (val) => setState(() => _isDarkMode = val),
              title: const Text('Enable Dark Mode'),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _saveSettings,
              icon: const Icon(Icons.save),
              label: const Text('Save Settings'),
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: _resetContent,
              icon: const Icon(Icons.warning, color: Colors.red),
              label: const Text('Reset App Content'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
