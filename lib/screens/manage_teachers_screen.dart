import 'package:flutter/material.dart';

class ManageTeachersScreen extends StatelessWidget {
  const ManageTeachersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Teachers'),
      ),
      body: Center(
        child: const Text(
          'This is where you can add, view, and remove teachers.',
          style: TextStyle(fontSize: 18),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add logic to add a teacher
        },
        child: const Icon(Icons.add),
        tooltip: 'Add Teacher',
      ),
    );
  }
}
