// File: packages/design_system/lib/src/components/kenya_specific/class_selector.dart
import 'package:flutter/material.dart';
import 'package:elimuconnect_shared/shared.dart';

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
    return DropdownButtonFormField<String>(
      value: selectedClass,
      decoration: const InputDecoration(
        labelText: 'Class/Grade',
        prefixIcon: Icon(Icons.school),
      ),
      items: KenyaCurriculum.gradeNames.map((grade) {
        return DropdownMenuItem(
          value: grade,
          child: Text(grade),
        );
      }).toList(),
      onChanged: onChanged,
      validator: (value) => KenyaSpecificValidators.validateClassName(value),
    );
  }
}
