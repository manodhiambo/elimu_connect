import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:elimu_connect/services/firestore_service.dart';

class BooksScreen extends StatelessWidget {
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Books'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestoreService.getBooks(), // Now returns Stream<QuerySnapshot>
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No books available'));
          }

          final books = snapshot.data!.docs.map((doc) {
            return doc.data() as Map<String, dynamic>;
          }).toList();

          return ListView.builder(
            itemCount: books.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(books[index]['title'] ?? 'No title'),
                subtitle: Text('Author: ${books[index]['author'] ?? 'Unknown author'}'),
                onTap: () {
                  // Optional: handle tap (e.g., open PDF or show details)
                },
              );
            },
          );
        },
      ),
    );
  }
}
