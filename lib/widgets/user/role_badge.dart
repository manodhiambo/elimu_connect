import 'package:flutter/material.dart';

class RoleBadge extends StatelessWidget {
  final String role;
  const RoleBadge({Key? key, required this.role}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color badgeColor;
    String roleText = role.toUpperCase();

    switch (role.toLowerCase()) {
      case 'admin':
        badgeColor = Colors.red;
        break;
      case 'teacher':
        badgeColor = Colors.blue;
        break;
      case 'student':
        badgeColor = Colors.green;
        break;
      default:
        badgeColor = Colors.grey;
    }

    return Chip(
      label: Text(roleText),
      backgroundColor: badgeColor,
      labelStyle: TextStyle(color: Colors.white),
    );
  }
}
