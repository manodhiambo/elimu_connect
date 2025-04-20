import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ChatScreen extends StatefulWidget {
  final String userId;
  final String userName;
  final String threadId;

  const ChatScreen({
    Key? key,
    required this.userId,
    required this.userName,
    required this.threadId,
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ScrollController _scrollController = ScrollController();

  bool _showEmojiPicker = false;
  bool _isUploadingImage = false;

  void _sendMessage({String? imageUrl}) async {
    final currentUser = _auth.currentUser;
    if ((imageUrl == null && _messageController.text.trim().isEmpty) || currentUser == null) return;

    await _firestore.collection('chats').add({
      'threadId': widget.threadId,
      'text': imageUrl == null ? _messageController.text.trim() : '',
      'imageUrl': imageUrl ?? '',
      'timestamp': FieldValue.serverTimestamp(),
      'senderId': currentUser.uid,
      'receiverId': widget.userId,
      'senderName': currentUser.displayName ?? 'Anonymous',
      'receiverName': widget.userName,
      'seen': false,
    });

    _messageController.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(Duration(milliseconds: 200), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0.0,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() => _isUploadingImage = true);
      final ref = FirebaseStorage.instance
          .ref()
          .child('chat_images')
          .child('${DateTime.now().millisecondsSinceEpoch}.jpg');

      await ref.putFile(File(pickedFile.path));
      final imageUrl = await ref.getDownloadURL();

      setState(() => _isUploadingImage = false);
      _sendMessage(imageUrl: imageUrl);
    }
  }

  void _markMessagesAsSeen(QuerySnapshot snapshot) async {
    final currentUser = _auth.currentUser;
    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      if (data['receiverId'] == currentUser?.uid && data['seen'] == false) {
        await _firestore.collection('chats').doc(doc.id).update({'seen': true});
      }
    }
  }

  Widget _buildMessageBubble(Map<String, dynamic> message, bool isMe) {
    final avatar = CircleAvatar(
      backgroundColor: Colors.grey[300],
      child: Text(
        message['senderName'] != null ? message['senderName'][0].toUpperCase() : '?',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    );

    final statusText = isMe ? (message['seen'] == true ? 'Seen' : 'Delivered') : '';

    final content = message['imageUrl'] != null && message['imageUrl'] != ''
        ? Image.network(message['imageUrl'], width: 180)
        : Text(message['text'] ?? '');

    return Row(
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (!isMe) avatar,
        const SizedBox(width: 8),
        Flexible(
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 5),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isMe ? Colors.blue[100] : Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                content,
                if (statusText.isNotEmpty)
                  Text(
                    statusText,
                    style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                  ),
              ],
            ),
          ),
        ),
        if (isMe) const SizedBox(width: 8),
        if (isMe) avatar,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with ${widget.userName}'),
        actions: [
          IconButton(
            icon: Icon(Icons.attach_file),
            onPressed: _pickImage,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('chats')
                  .where('threadId', isEqualTo: widget.threadId)
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!.docs;

                _markMessagesAsSeen(snapshot.data!);

                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index].data() as Map<String, dynamic>;
                    final isMe = message['senderId'] == currentUser?.uid;

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: _buildMessageBubble(message, isMe),
                    );
                  },
                );
              },
            ),
          ),
          if (_isUploadingImage)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: LinearProgressIndicator(),
            ),
          const Divider(height: 1),
          Row(
            children: [
              IconButton(
                icon: Icon(_showEmojiPicker ? Icons.close : Icons.emoji_emotions),
                onPressed: () {
                  setState(() {
                    _showEmojiPicker = !_showEmojiPicker;
                  });
                },
              ),
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: const InputDecoration(
                    hintText: 'Type your message...',
                  ),
                  onTap: () {
                    if (_showEmojiPicker) {
                      setState(() => _showEmojiPicker = false);
                    }
                  },
                ),
              ),
              IconButton(
                onPressed: () => _sendMessage(),
                icon: const Icon(Icons.send),
              ),
            ],
          ),
          if (_showEmojiPicker)
            SizedBox(
              height: 250,
              child: EmojiPicker(
                onEmojiSelected: (category, emoji) {
                  _messageController.text += emoji.emoji;
                },
                config: const Config(
                  columns: 7,
                  emojiSizeMax: 32,
                  verticalSpacing: 0,
                  horizontalSpacing: 0,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
