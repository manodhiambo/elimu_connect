import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chat_screen.dart';

class StudentInboxScreen extends StatefulWidget {
  const StudentInboxScreen({super.key});

  @override
  State<StudentInboxScreen> createState() => _StudentInboxScreenState();
}

class _StudentInboxScreenState extends State<StudentInboxScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late User? currentUser;
  String userName = 'Student'; // default placeholder

  @override
  void initState() {
    super.initState();
    currentUser = _auth.currentUser;
    _loadCurrentUserName();
  }

  Future<void> _loadCurrentUserName() async {
    if (currentUser != null) {
      final userDoc = await _firestore.collection('users').doc(currentUser!.uid).get();
      setState(() {
        userName = userDoc.data()?['name'] ?? 'Student';
      });
    }
  }

  Stream<QuerySnapshot> getThreads() {
    if (currentUser == null) {
      return const Stream.empty();
    }
    return _firestore
        .collection('chats')
        .where('receiverId', isEqualTo: currentUser!.uid)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<int> getUnreadCount(String threadId) async {
    try {
      final querySnapshot = await _firestore
          .collection('chats')
          .where('threadId', isEqualTo: threadId)
          .where('receiverId', isEqualTo: currentUser!.uid)
          .where('seen', isEqualTo: false)
          .get();
      return querySnapshot.docs.length;
    } catch (e) {
      debugPrint("Error getting unread count: $e");
      return 0;
    }
  }

  Widget buildThread(DocumentSnapshot thread) {
    final data = thread.data() as Map<String, dynamic>;
    final threadId = data['threadId'] ?? '';
    final senderName = data['senderName'] ?? 'Unknown';
    final lastMessage = data['text'] ?? '';
    final timestamp = data['timestamp'] as Timestamp?;

    return FutureBuilder<int>(
      future: getUnreadCount(threadId),
      builder: (context, snapshot) {
        final unreadCount = snapshot.data ?? 0;

        return ListTile(
          title: Text(senderName),
          subtitle: Text(lastMessage),
          trailing: unreadCount > 0
              ? CircleAvatar(
                  backgroundColor: Colors.red,
                  radius: 10,
                  child: Text(
                    '$unreadCount',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                )
              : null,
          onTap: () => _openChat(threadId),
        );
      },
    );
  }

  void _openChat(String threadId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          threadId: threadId,
          userId: currentUser!.uid,
          userName: userName, // ✅ FIXED: pass userName
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: Text("User not logged in")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Student Inbox"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: getThreads(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No threads available."));
          }

          final threads = snapshot.data!.docs;

          return ListView.builder(
            itemCount: threads.length,
            itemBuilder: (context, index) {
              return buildThread(threads[index]);
            },
          );
        },
      ),
    );
  }
}
