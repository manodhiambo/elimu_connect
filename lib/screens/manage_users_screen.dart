import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ManageUsersScreen extends StatefulWidget {
  const ManageUsersScreen({super.key});

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.trim().toLowerCase();
    });
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _confirmDeleteUser(
      BuildContext context, String id, String name, String role) async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete $role'),
        content: Text('Are you sure you want to delete "$name"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              try {
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(id)
                    .delete();
                if (context.mounted) Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$role deleted successfully')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to delete $role')),
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _buildUserSection(
    String title,
    List<QueryDocumentSnapshot> users,
    BuildContext context,
  ) {
    if (users.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        ...users.map((user) {
          final data = user.data() as Map<String, dynamic>;
          final name = data['name'] ?? 'No Name';
          final email = data['email'] ?? 'No Email';
          final role = data['role'] ?? 'unknown';

          return ListTile(
            leading: CircleAvatar(
              child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?'),
            ),
            title: Text(name),
            subtitle: Text('$email • ${role.toUpperCase()}'),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () =>
                  _confirmDeleteUser(context, user.id, name, role),
            ),
          );
        }).toList(),
        const Divider(thickness: 2),
      ],
    );
  }

  List<QueryDocumentSnapshot> _filterUsers(
    List<QueryDocumentSnapshot> users,
    String role,
  ) {
    return users.where((user) {
      final data = user.data() as Map<String, dynamic>;
      final userRole = data['role'] ?? '';
      final name = data['name']?.toLowerCase() ?? '';
      final email = data['email']?.toLowerCase() ?? '';
      return userRole == role &&
          (_searchQuery.isEmpty ||
              name.contains(_searchQuery) ||
              email.contains(_searchQuery));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Users'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name or email...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Failed to load users.'));
          }

          final users = snapshot.data?.docs ?? [];

          final teachers = _filterUsers(users, 'teacher');
          final students = _filterUsers(users, 'student');

          if (teachers.isEmpty && students.isEmpty) {
            return const Center(child: Text('No matching users found.'));
          }

          return ListView(
            children: [
              _buildUserSection('Teachers', teachers, context),
              _buildUserSection('Students', students, context),
            ],
          );
        },
      ),
    );
  }
}
