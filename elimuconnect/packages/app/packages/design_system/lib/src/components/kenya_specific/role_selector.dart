import 'package:flutter/material.dart';
import 'package:elimuconnect_shared/shared.dart';

class RoleSelector extends StatelessWidget {
  final UserRole selectedRole;
  final ValueChanged<UserRole> onRoleChanged;

  const RoleSelector({
    super.key,
    required this.selectedRole,
    required this.onRoleChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'I am a...',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: UserRole.values.map((role) {
            final isSelected = selectedRole == role;
            return FilterChip(
              selected: isSelected,
              label: Text(_getRoleDisplayName(role)),
              onSelected: (selected) => onRoleChanged(role),
              avatar: Icon(_getRoleIcon(role)),
            );
          }).toList(),
        ),
      ],
    );
  }

  String _getRoleDisplayName(UserRole role) {
    switch (role) {
      case UserRole.student:
        return 'Student';
      case UserRole.teacher:
        return 'Teacher';
      case UserRole.parent:
        return 'Parent';
      case UserRole.admin:
        return 'Administrator';
    }
  }

  IconData _getRoleIcon(UserRole role) {
    switch (role) {
      case UserRole.student:
        return Icons.school;
      case UserRole.teacher:
        return Icons.person;
      case UserRole.parent:
        return Icons.family_restroom;
      case UserRole.admin:
        return Icons.admin_panel_settings;
    }
  }
}
