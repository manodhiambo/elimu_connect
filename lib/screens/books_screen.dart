import 'package:flutter/material.dart';
import '../services/firestore_service.dart';

class BooksScreen extends StatelessWidget {
  const BooksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Books')),
      body: StreamBuilder(
        stream: FirestoreService().getBooks(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading books'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final books = snapshot.data!.docs;
          if (books.isEmpty) {
            return const Center(child: Text('No books available'));
          }

          return ListView.builder(
            itemCount: books.length,
            itemBuilder: (context, index) {
              final bookData = books[index].data() as Map<String, dynamic>;
              return ListTile(
                title: Text(bookData['title'] ?? 'No Title'),
                subtitle: Text(bookData['subject'] ?? 'No Subject'),
                onTap: () {
                  // Optional: Open download/view dialog
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/uploadBook');
        },
        child: const Icon(Icons.upload_file),
      ),
    );
  }
}
