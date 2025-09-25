// File: packages/design_system/lib/src/components/kenya_specific/subject_selector.dart
import 'package:flutter/material.dart';
import 'package:elimuconnect_shared/shared.dart';

class SubjectSelector extends StatefulWidget {
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
  State<SubjectSelector> createState() => _SubjectSelectorState();
}

class _SubjectSelectorState extends State<SubjectSelector> {
  @override
  Widget build(BuildContext context) {
    final availableSubjects = widget.selectedClass != null
        ? KenyaCurriculum.getSubjectsForGrade(widget.selectedClass!)
        : <String>[];

    if (availableSubjects.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('Please select a class first to see available subjects'),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Subjects Taught',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: availableSubjects.map((subject) {
            final isSelected = widget.selectedSubjects.contains(subject);
            return FilterChip(
              label: Text(subject),
              selected: isSelected,
              onSelected: (selected) {
                final updatedSubjects = List<String>.from(widget.selectedSubjects);
                if (selected) {
                  updatedSubjects.add(subject);
                } else {
                  updatedSubjects.remove(subject);
                }
                widget.onChanged(updatedSubjects);
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}
