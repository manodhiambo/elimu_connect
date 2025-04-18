import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/reply_modal.dart';

class QuestionForumScreen extends StatefulWidget {
  const QuestionForumScreen({super.key});

  @override
  State<QuestionForumScreen> createState() => _QuestionForumScreenState();
}

class _QuestionForumScreenState extends State<QuestionForumScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  void _submitQuestion() async {
    if (_formKey.currentState!.validate()) {
      final user = FirebaseAuth.instance.currentUser;
      await _firestoreService.postQuestion(
        title: _titleController.text,
        description: _descController.text,
        postedBy: user?.email ?? 'Anonymous',
      );
      _titleController.clear();
      _descController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Question posted!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Question Forum')),
      body: Column(
        children: [
          // Question Form
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: 'Question Title'),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Enter a title' : null,
                  ),
                  TextFormField(
                    controller: _descController,
                    decoration: const InputDecoration(labelText: 'Description'),
                    maxLines: 2,
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Enter a description' : null,
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: _submitQuestion,
                    icon: const Icon(Icons.send),
                    label: const Text('Post Question'),
                  ),
                ],
              ),
            ),
          ),

          const Divider(),

          // Questions list
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestoreService.getQuestions(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Something went wrong'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final questions = snapshot.data!.docs;
                if (questions.isEmpty) {
                  return const Center(child: Text('No questions posted yet.'));
                }

                return ListView.builder(
                  itemCount: questions.length,
                  itemBuilder: (context, index) {
                    final data = questions[index].data() as Map<String, dynamic>;
                    return InkWell(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                          ),
                          builder: (_) => ReplyModal(questionId: questions[index].id),
                        );
                      },
                      child: ListTile(
                        title: Text(data['title'] ?? ''),
                        subtitle: Text(data['description'] ?? ''),
                        trailing: Text(data['postedBy'] ?? ''),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
