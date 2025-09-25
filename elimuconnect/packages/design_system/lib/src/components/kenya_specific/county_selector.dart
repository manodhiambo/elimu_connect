import 'package:flutter/material.dart';
import 'package:elimuconnect_shared/shared.dart';

class CountySelector extends StatelessWidget {
  final KenyaCounty? selectedCounty;
  final ValueChanged<KenyaCounty?> onChanged;
  final String labelText;

  const CountySelector({
    super.key,
    this.selectedCounty,
    required this.onChanged,
    this.labelText = 'Select County',
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<KenyaCounty>(
      value: selectedCounty,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: const Icon(Icons.location_on),
      ),
      items: KenyaCounty.values.map((county) {
        return DropdownMenuItem(
          value: county,
          child: Text(_formatCountyName(county)),
        );
      }).toList(),
      onChanged: onChanged,
      validator: (value) {
        if (value == null) return 'Please select your county';
        return null;
      },
    );
  }

  String _formatCountyName(KenyaCounty county) {
    return county.name
        .replaceAllMapped(RegExp(r'([A-Z])'), (match) => ' ${match.group(0)}')
        .trim()
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }
}
