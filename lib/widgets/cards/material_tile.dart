import 'package:flutter/material.dart';

class MaterialTile extends StatelessWidget {
  final String title;
  final String description;
  final VoidCallback onTap;

  const MaterialTile({
    super.key,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.picture_as_pdf, color: Colors.deepPurple),
      title: Text(title, style: Theme.of(context).textTheme.titleSmall),
      subtitle: Text(description),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
