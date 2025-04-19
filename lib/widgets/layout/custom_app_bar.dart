import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showLogout;
  final VoidCallback? onLogout;

  const CustomAppBar({
    super.key,
    required this.title,
    this.showLogout = false,
    this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      actions: showLogout
          ? [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: onLogout ?? () {
                  Navigator.pushReplacementNamed(context, '/login');
                },
              )
            ]
          : null,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
