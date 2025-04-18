import 'package:flutter/material.dart';
import 'books_screen.dart';
import 'past_papers_screen.dart';
import 'revision_screen.dart';
import 'question_forum_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tiles = [
      {'title': 'Books', 'icon': Icons.menu_book, 'screen': const BooksScreen()},
      {'title': 'Past Papers', 'icon': Icons.assignment, 'screen': const PastPapersScreen()},
      {'title': 'Revision', 'icon': Icons.edit_note, 'screen': const RevisionScreen()},
      {'title': 'Question Forum', 'icon': Icons.forum, 'screen': const QuestionForumScreen()},
      {'title': 'Profile', 'icon': Icons.person, 'screen': const ProfileScreen()},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('ElimuConnect Home'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: tiles.map((tile) {
            return GestureDetector(
              onTap: () => _navigateTo(context, tile['screen'] as Widget),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(tile['icon'] as IconData, size: 48, color: Colors.blueAccent),
                    const SizedBox(height: 10),
                    Text(
                      tile['title'] as String,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
