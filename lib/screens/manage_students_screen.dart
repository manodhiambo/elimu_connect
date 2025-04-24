import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:elimu_connect/screens/chat_screen.dart';

class ManageStudentsScreen extends StatefulWidget {
  const ManageStudentsScreen({super.key});

  @override
  State<ManageStudentsScreen> createState() => _ManageStudentsScreenState();
}

class _ManageStudentsScreenState extends State<ManageStudentsScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  String _filter = '';

  // 🔧 Add current admin/teacher user ID (replace with actual auth logic)
  final String currentUserId = 'admin_001'; // TODO: Replace with actual user ID

  String generateThreadId(String userA, String userB) {
    final sorted = [userA, userB]..sort();
    return '${sorted[0]}_${sorted[1]}';
  }

  Future<void> _addStudent() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();

    if (name.isEmpty || email.isEmpty) return;

    await FirebaseFirestore.instance.collection('students').add({
      'name': name,
      'email': email,
      'createdAt': Timestamp.now(),
    });

    _nameController.clear();
    _emailController.clear();
  }

  Future<void> _removeStudent(String id) async {
    await FirebaseFirestore.instance.collection('students').doc(id).delete();
  }

  Future<void> _bulkUpload() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );
    if (result != null) {
      final file = File(result.files.single.path!);
      final content = await file.readAsString();
      final rows = LineSplitter.split(content);
      for (final row in rows.skip(1)) {
        final columns = row.split(',');
        if (columns.length >= 2) {
          await FirebaseFirestore.instance.collection('students').add({
            'name': columns[0].trim(),
            'email': columns[1].trim(),
            'createdAt': Timestamp.now(),
          });
        }
      }
    }
  }

  // ✅  FIXED student stream logic
  Stream<QuerySnapshot> _studentStream() {
    final collection = FirebaseFirestore.instance.collection('students');

    // If no filter, fetch all students sorted by creation date
    if (_filter.isEmpty) {
      return collection.orderBy('createdAt', descending: true).snapshots();
    } else {
      // Filtering logic for search functionality
      return collection
          .orderBy('name')
          .startAt([_filter])
          .endAt(['$_filter\uf8ff']) // allows partial matches for filtering
          .snapshots();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Students'),
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_file),
            onPressed: _bulkUpload,
            tooltip: 'Bulk Upload CSV',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Name'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addStudent,
                  child: const Text('Add'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search student by name',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  _filter = value.trim();
                });
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _studentStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                        child: Text('Error: ${snapshot.error}',
                            style: const TextStyle(color: Colors.red)));
                  }

                  final students = snapshot.data?.docs ?? [];

                  if (students.isEmpty) {
                    return const Center(child: Text('No students found.'));
                  }

                  return ListView.builder(
                    itemCount: students.length,
                    itemBuilder: (context, index) {
                      final doc = students[index];
                      final data = doc.data() as Map<String, dynamic>;
                      final id = doc.id;
                      final name = data['name'] ?? '';
                      final email = data['email'] ?? '';
                      final threadId = generateThreadId(currentUserId, id);

                      return ListTile(
                        title: Text(name),
                        subtitle: Text(email),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.chat),
                              tooltip: 'Message',
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ChatScreen(
                                    userId: id,
                                    userName: name,
                                    threadId: threadId,
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              tooltip: 'Remove',
                              onPressed: () => _removeStudent(id),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
