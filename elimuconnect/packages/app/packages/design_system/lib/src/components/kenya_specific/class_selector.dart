import 'package:flutter/material.dart';

class ClassSelector extends StatelessWidget {
  final String? selectedClass;
  final ValueChanged<String?> onChanged;

  const ClassSelector({
    super.key,
    this.selectedClass,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    const grades = ['Grade 1', 'Grade 2', 'Grade 3', 'Grade 4', 'Grade 5', 'Grade 6', 'Grade 7', 'Grade 8'];
    
    return DropdownButtonFormField<String>(
      value: selectedClass,
      decoration: const InputDecoration(
        labelText: 'Class/Grade',
        prefixIcon: Icon(Icons.school),
      ),
      items: grades.map((grade) {
        return DropdownMenuItem(value: grade, child: Text(grade));
      }).toList(),
      onChanged: onChanged,
      validator: (value) {
        if (value == null) return 'Please select a class';
        return null;
      },
    );
  }
}
