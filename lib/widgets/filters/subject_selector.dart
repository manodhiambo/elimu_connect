import 'package:flutter/material.dart';

class SubjectSelector extends StatelessWidget {
  final List<String> subjects;
  final String selectedSubject;
  final ValueChanged<String> onSubjectSelected;

  const SubjectSelector({
    super.key,
    required this.subjects,
    required this.selectedSubject,
    required this.onSubjectSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      children: subjects.map((subject) {
        final isSelected = subject == selectedSubject;
        return ChoiceChip(
          label: Text(subject),
          selected: isSelected,
          onSelected: (_) => onSubjectSelected(subject),
        );
      }).toList(),
    );
  }
}
