import 'package:flutter/material.dart';

class ManageStudentsScreen extends StatelessWidget {
  const ManageStudentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Students'),
      ),
      body: Center(
        child: const Text(
          'This is where you can add, view, and remove students.',
          style: TextStyle(fontSize: 18),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add logic to add a student
        },
        child: const Icon(Icons.person_add),
        tooltip: 'Add Student',
      ),
    );
  }
}
