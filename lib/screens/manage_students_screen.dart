import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageStudentsScreen extends StatelessWidget {
  const ManageStudentsScreen({super.key});

  void _showAddStudentDialog(BuildContext context) {
    final _nameController = TextEditingController();
    final _emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Student'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Student Name'),
            ),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Student Email'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = _nameController.text.trim();
              final email = _emailController.text.trim();

              if (name.isNotEmpty && email.isNotEmpty) {
                await FirebaseFirestore.instance.collection('users').add({
                  'name': name,
                  'email': email,
                  'role': 'student',
                  'createdAt': Timestamp.now(),
                });

                Navigator.of(ctx).pop();
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Students'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddStudentDialog(context),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('role', isEqualTo: 'student')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No students found.'));
          }

          final students = snapshot.data!.docs;

          return ListView.builder(
            itemCount: students.length,
            itemBuilder: (ctx, index) {
              final student = students[index];
              final name = student['name'] ?? 'No Name';
              final email = student['email'] ?? 'No Email';

              return ListTile(
                leading: CircleAvatar(
                  child: Text(name[0].toUpperCase()),
                ),
                title: Text(name),
                subtitle: Text(email),
              );
            },
          );
        },
      ),
    );
  }
}
