import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../tokens/colors.dart';

class ElimuTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final String? helperText;
  final String? errorText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final bool enabled;
  final bool readOnly;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function()? onTap;
  final void Function(String)? onSubmitted;
  final FocusNode? focusNode;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;
  final bool autofocus;

  const ElimuTextField({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.helperText,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.done,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.enabled = true,
    this.readOnly = false,
    this.validator,
    this.onChanged,
    this.onTap,
    this.onSubmitted,
    this.focusNode,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
    this.autofocus = false,
  });

  @override
  State<ElimuTextField> createState() => _ElimuTextFieldState();
}

class _ElimuTextFieldState extends State<ElimuTextField> {
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: widget.controller,
          focusNode: _focusNode,
          obscureText: widget.obscureText,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          maxLines: widget.maxLines,
          minLines: widget.minLines,
          maxLength: widget.maxLength,
          enabled: widget.enabled,
          readOnly: widget.readOnly,
          validator: widget.validator,
          onChanged: widget.onChanged,
          onTap: widget.onTap,
          onFieldSubmitted: widget.onSubmitted,
          inputFormatters: widget.inputFormatters,
          textCapitalization: widget.textCapitalization,
          autofocus: widget.autofocus,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: widget.enabled ? ElimuColors.textPrimary : ElimuColors.textTertiary,
          ),
          decoration: InputDecoration(
            labelText: widget.labelText,
            hintText: widget.hintText,
            helperText: widget.helperText,
            errorText: widget.errorText,
            prefixIcon: widget.prefixIcon != null
                ? Icon(
                    widget.prefixIcon,
                    color: _getPrefixIconColor(hasError),
                  )
                : null,
            suffixIcon: widget.suffixIcon,
            labelStyle: TextStyle(
              color: _getLabelColor(hasError),
              fontWeight: FontWeight.w500,
            ),
            hintStyle: TextStyle(
              color: ElimuColors.textTertiary,
            ),
            helperStyle: TextStyle(
              color: ElimuColors.textSecondary,
              fontSize: 12,
            ),
            errorStyle: TextStyle(
              color: ElimuColors.error,
              fontSize: 12,
            ),
            filled: true,
            fillColor: _getFillColor(hasError),
            border: _getBorder(false, hasError),
            enabledBorder: _getBorder(false, hasError),
            focusedBorder: _getBorder(true, hasError),
            errorBorder: _getBorder(false, true),
            focusedErrorBorder: _getBorder(true, true),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
        if (widget.helperText != null && widget.errorText == null) ...[
          const SizedBox(height: 4),
          Text(
            widget.helperText!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: ElimuColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }

  Color _getFillColor(bool hasError) {
    if (!widget.enabled) return ElimuColors.disabled.withOpacity(0.1);
    if (hasError) return ElimuColors.error.withOpacity(0.05);
    if (_isFocused) return ElimuColors.primary.withOpacity(0.05);
    return ElimuColors.surfaceVariant;
  }

  Color _getLabelColor(bool hasError) {
    if (!widget.enabled) return ElimuColors.textTertiary;
    if (hasError) return ElimuColors.error;
    if (_isFocused) return ElimuColors.primary;
    return ElimuColors.textSecondary;
  }

  Color _getPrefixIconColor(bool hasError) {
    if (!widget.enabled) return ElimuColors.textTertiary;
    if (hasError) return ElimuColors.error;
    if (_isFocused) return ElimuColors.primary;
    return ElimuColors.textSecondary;
  }

  OutlineInputBorder _getBorder(bool isFocused, bool hasError) {
    Color borderColor;
    double borderWidth;

    if (!widget.enabled) {
      borderColor = ElimuColors.disabled;
      borderWidth = 1;
    } else if (hasError) {
      borderColor = ElimuColors.error;
      borderWidth = isFocused ? 2 : 1;
    } else if (isFocused) {
      borderColor = ElimuColors.primary;
      borderWidth = 2;
    } else {
      borderColor = ElimuColors.border;
      borderWidth = 1;
    }

    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: borderColor,
        width: borderWidth,
      ),
    );
  }
}
