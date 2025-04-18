import 'package:flutter/material.dart';
import '../services/firestore_service.dart';

class PastPapersScreen extends StatelessWidget {
  const PastPapersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Past Papers')),
      body: StreamBuilder(
        stream: FirestoreService().getPastPapers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No past papers available.'));
          }

          final papers = snapshot.data!.docs;
          return ListView.builder(
            itemCount: papers.length,
            itemBuilder: (context, index) {
              final paperData = papers[index].data() as Map<String, dynamic>;
              return ListTile(
                title: Text(paperData['title'] ?? 'No Title'),
                subtitle: Text('Subject: ${paperData['subject'] ?? 'N/A'}'),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Download link: ${paperData['link'] ?? 'N/A'}')),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/uploadPaper');
        },
        child: const Icon(Icons.upload_file),
      ),
    );
  }
}
