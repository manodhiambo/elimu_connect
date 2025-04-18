import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // for timestamp formatting

class ReplyModal extends StatefulWidget {
  final String questionId;

  const ReplyModal({super.key, required this.questionId});

  @override
  State<ReplyModal> createState() => _ReplyModalState();
}

class _ReplyModalState extends State<ReplyModal> {
  final TextEditingController _replyController = TextEditingController();
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final user = FirebaseAuth.instance.currentUser;

  Future<void> _submitReply() async {
    if (_replyController.text.trim().isEmpty) return;

    await _db
        .collection('questions')
        .doc(widget.questionId)
        .collection('replies')
        .add({
      'text': _replyController.text.trim(),
      'repliedBy': user?.email ?? 'Anonymous',
      'timestamp': FieldValue.serverTimestamp(),
    });

    _replyController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, -4),
              )
            ],
          ),
          child: Column(
            children: [
              Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Replies',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Divider(),

              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _db
                      .collection('questions')
                      .doc(widget.questionId)
                      .collection('replies')
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) return const Text('Error loading replies');
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final replies = snapshot.data!.docs;

                    if (replies.isEmpty) {
                      return const Center(child: Text('No replies yet.'));
                    }

                    return ListView.builder(
                      controller: scrollController,
                      itemCount: replies.length,
                      itemBuilder: (context, index) {
                        final data = replies[index].data() as Map<String, dynamic>;
                        final replyText = data['text'] ?? '';
                        final repliedBy = data['repliedBy'] ?? 'Unknown';
                        final timestamp = data['timestamp'] != null
                            ? DateFormat('dd MMM, hh:mm a').format((data['timestamp'] as Timestamp).toDate())
                            : 'Just now';

                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceVariant,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(replyText, style: const TextStyle(fontSize: 16)),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('By $repliedBy', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                  Text(timestamp, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: 10),

              // Reply input
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _replyController,
                      decoration: InputDecoration(
                        hintText: 'Write a reply...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surface,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: _submitReply,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
