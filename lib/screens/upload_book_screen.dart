import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class UploadBookScreen extends StatefulWidget {
  const UploadBookScreen({super.key});

  @override
  State<UploadBookScreen> createState() => _UploadBookScreenState();
}

class _UploadBookScreenState extends State<UploadBookScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  File? _pdfFile;
  String? _fileName;
  bool _isLoading = false;

  Future<void> _pickPDF() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
    if (result != null && result.files.single.path != null) {
      setState(() {
        _pdfFile = File(result.files.single.path!);
        _fileName = result.files.single.name;
      });
    }
  }

  Future<void> _uploadBook() async {
    if (!_formKey.currentState!.validate()) return;
    if (_pdfFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a PDF file to upload.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final storageRef = FirebaseStorage.instance.ref().child('books/$_fileName');
      final uploadTask = await storageRef.putFile(_pdfFile!);
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      await FirebaseFirestore.instance.collection('books').add({
        'title': _titleController.text.trim(),
        'subject': _subjectController.text.trim(),
        'description': _descriptionController.text.trim(),
        'downloadUrl': downloadUrl,
        'uploadedAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Book uploaded successfully!')),
      );

      _formKey.currentState!.reset();
      setState(() {
        _pdfFile = null;
        _fileName = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload failed: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload Book')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Book Title'),
                validator: (value) => value!.isEmpty ? 'Enter title' : null,
              ),
              TextFormField(
                controller: _subjectController,
                decoration: const InputDecoration(labelText: 'Subject'),
                validator: (value) => value!.isEmpty ? 'Enter subject' : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
                validator: (value) => value!.isEmpty ? 'Enter description' : null,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _pickPDF,
                icon: const Icon(Icons.attach_file),
                label: const Text('Choose PDF File'),
              ),
              if (_fileName != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text('Selected File: $_fileName'),
                ),
              const SizedBox(height: 20),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                      onPressed: _uploadBook,
                      icon: const Icon(Icons.upload_file),
                      label: const Text('Upload Book'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
