import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:elimu_connect/services/firestore_service.dart';
import 'package:url_launcher/url_launcher.dart';

class PastPapersScreen extends StatelessWidget {
  final FirestoreService _firestoreService = FirestoreService();

  Future<void> _launchPdf(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open PDF')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Past Papers'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestoreService.getPastPapers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No past papers available'));
          }

          final papers = snapshot.data!.docs.map((doc) {
            return doc.data() as Map<String, dynamic>;
          }).toList();

          return ListView.builder(
            itemCount: papers.length,
            itemBuilder: (context, index) {
              final paper = papers[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: ListTile(
                  title: Text(paper['title'] ?? 'No title'),
                  subtitle: Text('Subject: ${paper['subject'] ?? 'N/A'} | Year: ${paper['year'] ?? 'N/A'}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.picture_as_pdf, color: Colors.red),
                    onPressed: () => _launchPdf(context, paper['fileUrl'] ?? ''),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
