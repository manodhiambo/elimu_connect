import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageTeachersScreen extends StatefulWidget {
  const ManageTeachersScreen({super.key});

  @override
  State<ManageTeachersScreen> createState() => _ManageTeachersScreenState();
}

class _ManageTeachersScreenState extends State<ManageTeachersScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();

  String? _editingTeacherId;

  Future<void> _submitTeacher() async {
    if (!_formKey.currentState!.validate()) return;

    final teacherData = {
      'name': _nameController.text.trim(),
      'email': _emailController.text.trim(),
      'subject': _subjectController.text.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    try {
      if (_editingTeacherId == null) {
        // Add new teacher
        await FirebaseFirestore.instance.collection('teachers').add({
          ...teacherData,
          'createdAt': FieldValue.serverTimestamp(),
        });
      } else {
        // Update existing teacher
        await FirebaseFirestore.instance
            .collection('teachers')
            .doc(_editingTeacherId)
            .update(teacherData);
      }

      Navigator.pop(context); // Close modal
      _clearForm();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Operation failed: $e')),
      );
    }
  }

  void _clearForm() {
    _nameController.clear();
    _emailController.clear();
    _subjectController.clear();
    _editingTeacherId = null;
  }

  void _showTeacherForm({Map<String, dynamic>? teacher, String? id}) {
    if (teacher != null) {
      _nameController.text = teacher['name'];
      _emailController.text = teacher['email'];
      _subjectController.text = teacher['subject'];
      _editingTeacherId = id;
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _editingTeacherId == null ? 'Add Teacher' : 'Edit Teacher',
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
                  controller: _subjectController,
                  decoration: const InputDecoration(labelText: 'Subject'),
                  validator: (value) => value!.isEmpty ? 'Enter subject' : null,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _submitTeacher,
                  child: const Text('Save'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _deleteTeacher(String docId) async {
    try {
      await FirebaseFirestore.instance.collection('teachers').doc(docId).delete();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Delete failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Teachers')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('teachers').orderBy('name').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No teachers found.'));
          }

          final teachers = snapshot.data!.docs;

          return ListView.builder(
            itemCount: teachers.length,
            itemBuilder: (context, index) {
              final doc = teachers[index];
              final teacher = doc.data() as Map<String, dynamic>;

              return ListTile(
                title: Text(teacher['name']),
                subtitle: Text('${teacher['email']} • ${teacher['subject']}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _showTeacherForm(teacher: teacher, id: doc.id),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteTeacher(doc.id),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTeacherForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
