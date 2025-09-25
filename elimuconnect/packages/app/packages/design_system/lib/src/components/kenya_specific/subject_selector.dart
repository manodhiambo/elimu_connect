import 'package:flutter/material.dart';

class SubjectSelector extends StatelessWidget {
  final List<String> selectedSubjects;
  final ValueChanged<List<String>> onChanged;
  final String? selectedClass;

  const SubjectSelector({
    super.key,
    required this.selectedSubjects,
    required this.onChanged,
    this.selectedClass,
  });

  @override
  Widget build(BuildContext context) {
    const subjects = ['Mathematics', 'English', 'Science', 'Kiswahili', 'Social Studies'];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Subjects Taught', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: subjects.map((subject) {
            final isSelected = selectedSubjects.contains(subject);
            return FilterChip(
              label: Text(subject),
              selected: isSelected,
              onSelected: (selected) {
                final updatedSubjects = List<String>.from(selectedSubjects);
                if (selected) {
                  updatedSubjects.add(subject);
                } else {
                  updatedSubjects.remove(subject);
                }
                onChanged(updatedSubjects);
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}
