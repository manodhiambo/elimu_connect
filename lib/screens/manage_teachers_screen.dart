import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ManageTeachersScreen extends StatefulWidget {
  const ManageTeachersScreen({super.key}); // ✅ const constructor

  @override
  State<ManageTeachersScreen> createState() => _ManageTeachersScreenState();
}

class _ManageTeachersScreenState extends State<ManageTeachersScreen> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _email = '';
  String _password = '';

  Future<void> _addTeacher() async {
    final isValid = _formKey.currentState?.validate();
    if (isValid ?? false) {
      _formKey.currentState?.save();

      try {
        await FirebaseFirestore.instance.collection('users').add({
          'name': _name,
          'email': _email,
          'password': _password,
          'role': 'teacher',
          'createdAt': FieldValue.serverTimestamp(),
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Teacher added successfully!')),
          );
          Navigator.of(context).pop(); // Close dialog after success
        }
      } catch (e) {
        debugPrint('Error adding teacher: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to add teacher')),
          );
        }
      }
    }
  }

  void _showAddTeacherDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add New Teacher'),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Full Name'),
                  validator: (val) =>
                      val == null || val.isEmpty ? 'Enter name' : null,
                  onSaved: (val) => _name = val ?? '',
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: (val) => val == null || !val.contains('@')
                      ? 'Enter valid email'
                      : null,
                  onSaved: (val) => _email = val ?? '',
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  validator: (val) => val == null || val.length < 6
                      ? 'Min 6 characters'
                      : null,
                  onSaved: (val) => _password = val ?? '',
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _addTeacher,
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteTeacher(String id, String name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Teacher'),
        content: Text('Are you sure you want to delete "$name"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await FirebaseFirestore.instance.collection('users').doc(id).delete();
              if (mounted) Navigator.of(ctx).pop();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Teachers'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddTeacherDialog,
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('role', isEqualTo: 'teacher')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final teachers = snapshot.data?.docs ?? [];

          if (teachers.isEmpty) {
            return const Center(child: Text('No teachers added yet.'));
          }

          return ListView.builder(
            itemCount: teachers.length,
            itemBuilder: (ctx, i) {
              final teacher = teachers[i];
              return ListTile(
                leading: CircleAvatar(
                  child: Text(
                    teacher['name'][0].toUpperCase(),
                  ),
                ),
                title: Text(teacher['name']),
                subtitle: Text(teacher['email']),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () =>
                      _confirmDeleteTeacher(teacher.id, teacher['name']),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
