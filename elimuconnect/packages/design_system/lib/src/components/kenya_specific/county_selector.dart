import 'package:flutter/material.dart';
import 'package:elimuconnect_shared/shared.dart';
import '../inputs/elim_text_field.dart';
import '../../tokens/colors.dart';

class CountySelector extends StatefulWidget {
  final County? selectedCounty;
  final ValueChanged<County?> onChanged;
  final String? labelText;
  final String? hintText;
  final bool enabled;
  final String? errorText;

  const CountySelector({
    super.key,
    this.selectedCounty,
    required this.onChanged,
    this.labelText,
    this.hintText,
    this.enabled = true,
    this.errorText,
  });

  @override
  State<CountySelector> createState() => _CountySelectorState();
}

class _CountySelectorState extends State<CountySelector> {
  final TextEditingController _controller = TextEditingController();
  List<County> _filteredCounties = County.values;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    if (widget.selectedCounty != null) {
      _controller.text = _getCountyDisplayName(widget.selectedCounty!);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _getCountyDisplayName(County county) {
    return county.toString().split('.').last
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }

  void _filterCounties(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredCounties = County.values;
      } else {
        _filteredCounties = County.values.where((county) {
          final countyName = _getCountyDisplayName(county).toLowerCase();
          return countyName.contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  void _selectCounty(County county) {
    setState(() {
      _controller.text = _getCountyDisplayName(county);
      _isExpanded = false;
      _filteredCounties = County.values;
    });
    widget.onChanged(county);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ElimuTextField(
          controller: _controller,
          labelText: widget.labelText ?? 'County',
          hintText: widget.hintText ?? 'Select your county',
          enabled: widget.enabled,
          errorText: widget.errorText,
          readOnly: true,
          suffixIcon: Icon(
            _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
            color: widget.enabled ? ElimuColors.textSecondary : ElimuColors.disabled,
          ),
          onTap: widget.enabled ? () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          } : null,
        ),
        if (_isExpanded) ...[
          const SizedBox(height: 4),
          Container(
            height: 200,
            decoration: BoxDecoration(
              border: Border.all(color: ElimuColors.border),
              borderRadius: BorderRadius.circular(8),
              color: ElimuColors.surface,
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search counties...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: ElimuColors.border),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    onChanged: _filterCounties,
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _filteredCounties.length,
                    itemBuilder: (context, index) {
                      final county = _filteredCounties[index];
                      final displayName = _getCountyDisplayName(county);
                      
                      return ListTile(
                        title: Text(displayName),
                        onTap: () => _selectCounty(county),
                        selected: widget.selectedCounty == county,
                        selectedTileColor: ElimuColors.primary.withOpacity(0.1),
                        dense: true,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
