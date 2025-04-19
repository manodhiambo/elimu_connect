import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageStudentsScreen extends StatefulWidget {
  const ManageStudentsScreen({super.key});

  @override
  State<ManageStudentsScreen> createState() => _ManageStudentsScreenState();
}

class _ManageStudentsScreenState extends State<ManageStudentsScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _classController = TextEditingController();

  String? _editingStudentId;

  void _clearForm() {
    _nameController.clear();
    _emailController.clear();
    _classController.clear();
    _editingStudentId = null;
  }

  void _showStudentForm({Map<String, dynamic>? student, String? id}) {
    if (student != null) {
      _nameController.text = student['name'] ?? '';
      _emailController.text = student['email'] ?? '';
      _classController.text = student['class'] ?? '';
      _editingStudentId = id;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Wrap(
              runSpacing: 10,
              children: [
                Text(
                  _editingStudentId == null ? 'Add Student' : 'Edit Student',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Full Name'),
                  validator: (value) => value!.isEmpty ? 'Enter name' : null,
                ),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: (value) => value!.isEmpty ? 'Enter email' : null,
                ),
                TextFormField(
                  controller: _classController,
                  decoration: const InputDecoration(labelText: 'Class'),
                  validator: (value) => value!.isEmpty ? 'Enter class' : null,
                ),
                ElevatedButton(
                  onPressed: _submitStudent,
                  child: Text(_editingStudentId == null ? 'Add' : 'Update'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submitStudent() async {
    if (!_formKey.currentState!.validate()) return;

    final studentData = {
      'name': _nameController.text.trim(),
      'email': _emailController.text.trim(),
      'class': _classController.text.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    try {
      if (_editingStudentId == null) {
        await FirebaseFirestore.instance.collection('students').add({
          ...studentData,
          'createdAt': FieldValue.serverTimestamp(),
        });
      } else {
        await FirebaseFirestore.instance
            .collection('students')
            .doc(_editingStudentId)
            .update(studentData);
      }

      Navigator.pop(context);
      _clearForm();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Operation failed: $e')),
      );
    }
  }

  Future<void> _deleteStudent(String docId) async {
    try {
      await FirebaseFirestore.instance.collection('students').doc(docId).delete();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Delete failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Students')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('students').orderBy('name').snapshots(),
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
            itemBuilder: (context, index) {
              final doc = students[index];
              final student = doc.data() as Map<String, dynamic>;

              return ListTile(
                title: Text(student['name']),
                subtitle: Text('${student['email']} • Class: ${student['class']}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _showStudentForm(student: student, id: doc.id),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteStudent(doc.id),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showStudentForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
