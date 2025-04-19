import 'package:flutter/material.dart';

class RoleBadge extends StatelessWidget {
  final String role;

  const RoleBadge({super.key, required this.role});

  Color _getColor() {
    switch (role.toLowerCase()) {
      case 'admin':
        return Colors.redAccent;
      case 'teacher':
        return Colors.blueAccent;
      case 'student':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getIcon() {
    switch (role.toLowerCase()) {
      case 'admin':
        return Icons.shield;
      case 'teacher':
        return Icons.school;
      case 'student':
        return Icons.person;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(
        _getIcon(),
        color: Colors.white,
        size: 18,
      ),
      label: Text(
        role.toUpperCase(),
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      backgroundColor: _getColor(),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    );
  }
}
