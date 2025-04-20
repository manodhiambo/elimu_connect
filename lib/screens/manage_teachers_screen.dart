import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ManageTeachersScreen extends StatefulWidget {
  const ManageTeachersScreen({super.key});

  @override
  State<ManageTeachersScreen> createState() => _ManageTeachersScreenState();
}

class _ManageTeachersScreenState extends State<ManageTeachersScreen> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _email = '';
  String _password = '';
  bool _isLoading = false;

  Future<void> _addTeacher() async {
    final isValid = _formKey.currentState?.validate();
    if (isValid ?? false) {
      _formKey.currentState?.save();

      setState(() => _isLoading = true);

      try {
        // Register user using Firebase Auth
        final authResult = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: _email, password: _password);

        // Save additional data in Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(authResult.user!.uid)
            .set({
          'name': _name,
          'email': _email,
          'role': 'teacher',
          'createdAt': FieldValue.serverTimestamp(),
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Teacher added successfully!')),
          );
          _formKey.currentState?.reset();
          Navigator.of(context).pop();
        }
      } on FirebaseAuthException catch (e) {
        debugPrint('Auth error: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.message ?? 'Auth error occurred')),
          );
        }
      } catch (e) {
        debugPrint('General error: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to add teacher')),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  void _showAddTeacherDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add New Teacher'),
        content: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        decoration:
                            const InputDecoration(labelText: 'Full Name'),
                        validator: (val) =>
                            val == null || val.isEmpty ? 'Enter name' : null,
                        onSaved: (val) => _name = val ?? '',
                      ),
                      TextFormField(
                        decoration: const InputDecoration(labelText: 'Email'),
                        validator: (val) {
                          final emailRegex =
                              RegExp(r'^[^@]+@[^@]+\.[^@]+');
                          if (val == null || !emailRegex.hasMatch(val)) {
                            return 'Enter valid email';
                          }
                          return null;
                        },
                        onSaved: (val) => _email = val ?? '',
                      ),
                      TextFormField(
                        decoration:
                            const InputDecoration(labelText: 'Password'),
                        obscureText: true,
                        validator: (val) =>
                            val == null || val.length < 6
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
          if (!_isLoading)
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
              try {
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(id)
                    .delete();
                if (mounted) Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Teacher deleted successfully')),
                );
              } catch (e) {
                debugPrint('Error deleting teacher: $e');
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to delete teacher')),
                  );
                }
              }
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

          if (snapshot.hasError) {
            debugPrint('Error loading teachers: ${snapshot.error}');
            return const Center(child: Text('Error loading teachers.'));
          }

          final teachers = snapshot.data?.docs ?? [];

          if (teachers.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.person_off, size: 80, color: Colors.grey),
                  SizedBox(height: 10),
                  Text('No teachers found.', style: TextStyle(fontSize: 16)),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: teachers.length,
            itemBuilder: (ctx, i) {
              final teacher = teachers[i];
              final name = teacher['name'] ?? 'Unknown';
              final email = teacher['email'] ?? 'Unknown';

              return ListTile(
                leading: CircleAvatar(
                  child: Text(name.isNotEmpty
                      ? name[0].toUpperCase()
                      : '?'),
                ),
                title: Text(name),
                subtitle: Text(email),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () =>
                      _confirmDeleteTeacher(teacher.id, name),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
