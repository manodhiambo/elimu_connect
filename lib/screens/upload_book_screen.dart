import 'package:flutter/material.dart';
import '../services/firestore_service.dart';

class UploadBookScreen extends StatefulWidget {
  const UploadBookScreen({super.key});

  @override
  State<UploadBookScreen> createState() => _UploadBookScreenState();
}

class _UploadBookScreenState extends State<UploadBookScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _linkController = TextEditingController();

  bool _isUploading = false;

  Future<void> _uploadBook() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isUploading = true;
    });

    try {
      await FirestoreService().addBook({
        'title': _titleController.text.trim(),
        'subject': _subjectController.text.trim(),
        'link': _linkController.text.trim(),
        'timestamp': DateTime.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Book uploaded successfully')),
      );

      _titleController.clear();
      _subjectController.clear();
      _linkController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload: $e')),
      );
    }

    setState(() {
      _isUploading = false;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subjectController.dispose();
    _linkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload Book')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Book Title'),
                validator: (value) => value == null || value.isEmpty ? 'Enter title' : null,
              ),
              TextFormField(
                controller: _subjectController,
                decoration: const InputDecoration(labelText: 'Subject'),
                validator: (value) => value == null || value.isEmpty ? 'Enter subject' : null,
              ),
              TextFormField(
                controller: _linkController,
                decoration: const InputDecoration(labelText: 'Download Link (PDF, etc)'),
                validator: (value) => value == null || value.isEmpty ? 'Enter link' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isUploading ? null : _uploadBook,
                child: _isUploading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Upload Book'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
