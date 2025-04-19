import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class QuestionForumScreen extends StatefulWidget {
  const QuestionForumScreen({Key? key}) : super(key: key);

  @override
  _QuestionForumScreenState createState() => _QuestionForumScreenState();
}

class _QuestionForumScreenState extends State<QuestionForumScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final _questionController = TextEditingController();
  bool _isLoading = false;
  String? _userName;

  @override
  void initState() {
    super.initState();
    _getUserName();
  }

  Future<void> _getUserName() async {
    final user = _auth.currentUser;
    if (user != null) {
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      setState(() {
        _userName = userDoc['name'];
      });
    }
  }

  void _submitQuestion() async {
    if (_questionController.text.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('questions').add({
        'question': _questionController.text.trim(),
        'user_id': user.uid,
        'user_name': _userName,
        'timestamp': FieldValue.serverTimestamp(),
      });

      _questionController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Question submitted successfully')),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Question Forum')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _questionController,
                    decoration: const InputDecoration(
                      labelText: 'Ask a question',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _submitQuestion,
                    child: const Text('Submit Question'),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Questions from other users:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: _firestore
                          .collection('questions')
                          .orderBy('timestamp', descending: true)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Center(child: Text('No questions asked yet.'));
                        }

                        final questions = snapshot.data!.docs;
                        return ListView.builder(
                          itemCount: questions.length,
                          itemBuilder: (ctx, index) {
                            final questionData = questions[index];
                            final question = questionData['question'];
                            final userName = questionData['user_name'];
                            final timestamp = questionData['timestamp'] as Timestamp;

                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: ListTile(
                                title: Text(question),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Asked by: $userName'),
                                    Text('Posted on: ${timestamp.toDate()}'),
                                  ],
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.comment),
                                  onPressed: () => _showAnswerDialog(questionData.id),
                                ),
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

  void _showAnswerDialog(String questionId) {
    final TextEditingController _answerController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Submit Your Answer'),
          content: TextFormField(
            controller: _answerController,
            decoration: const InputDecoration(labelText: 'Your answer'),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final answer = _answerController.text.trim();
                if (answer.isNotEmpty) {
                  await _firestore.collection('questions').doc(questionId).update({
                    'answers': FieldValue.arrayUnion([answer]),
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Answer submitted successfully')),
                  );
                  Navigator.of(ctx).pop();
                }
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }
}
