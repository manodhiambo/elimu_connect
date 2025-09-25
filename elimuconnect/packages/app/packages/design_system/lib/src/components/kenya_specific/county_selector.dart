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
          child: Text(county.name.toUpperCase()),
        );
      }).toList(),
      onChanged: onChanged,
      validator: (value) {
        if (value == null) return 'Please select your county';
        return null;
      },
    );
  }
}
