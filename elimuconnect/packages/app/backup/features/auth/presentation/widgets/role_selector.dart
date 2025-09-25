import 'package:flutter/material.dart';
import 'package:elimuconnect_shared/shared.dart';
import 'package:elimuconnect_design_system/design_system.dart';

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
      children: [
        Row(
          children: [
            Expanded(
              child: _RoleCard(
                role: UserRole.student,
                title: 'Student',
                description: 'Access learning materials and take assessments',
                icon: Icons.school,
                isSelected: selectedRole == UserRole.student,
                onTap: () => onRoleChanged(UserRole.student),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _RoleCard(
                role: UserRole.teacher,
                title: 'Teacher',
                description: 'Create content and manage classes',
                icon: Icons.person_outline,
                isSelected: selectedRole == UserRole.teacher,
                onTap: () => onRoleChanged(UserRole.teacher),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _RoleCard(
                role: UserRole.parent,
                title: 'Parent',
                description: 'Monitor your child\'s progress',
                icon: Icons.family_restroom,
                isSelected: selectedRole == UserRole.parent,
                onTap: () => onRoleChanged(UserRole.parent),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _RoleCard(
                role: UserRole.admin,
                title: 'Admin',
                description: 'Manage school systems',
                icon: Icons.admin_panel_settings,
                isSelected: selectedRole == UserRole.admin,
                onTap: () => onRoleChanged(UserRole.admin),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _RoleCard extends StatelessWidget {
  final UserRole role;
  final String title;
  final String description;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.role,
    required this.title,
    required this.description,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? ElimuColors.primary : ElimuColors.border,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected ? ElimuColors.primary.withOpacity(0.05) : null,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected ? ElimuColors.primary : ElimuColors.textSecondary,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: isSelected ? ElimuColors.primary : null,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: ElimuColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
