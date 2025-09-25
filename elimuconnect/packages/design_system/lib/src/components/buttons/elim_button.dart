import 'package:flutter/material.dart';
import '../../tokens/colors.dart';

class ElimuButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isDisabled;
  final Widget? icon;
  final ButtonVariant variant;
  final ButtonSize size;

  const ElimuButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.icon,
    this.variant = ButtonVariant.primary,
    this.size = ButtonSize.medium,
  });

  const ElimuButton.primary({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.icon,
    this.size = ButtonSize.medium,
  }) : variant = ButtonVariant.primary;

  const ElimuButton.secondary({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.icon,
    this.size = ButtonSize.medium,
  }) : variant = ButtonVariant.secondary;

  const ElimuButton.outline({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.icon,
    this.size = ButtonSize.medium,
  }) : variant = ButtonVariant.outline;

  const ElimuButton.text({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.icon,
    this.size = ButtonSize.medium,
  }) : variant = ButtonVariant.text;

  @override
  Widget build(BuildContext context) {
    final isEffectivelyDisabled = isDisabled || isLoading || onPressed == null;

    Widget child = isLoading
        ? SizedBox(
            height: _getIconSize(),
            width: _getIconSize(),
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                _getForegroundColor(context, isEffectivelyDisabled),
              ),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                icon!,
                const SizedBox(width: 8),
              ],
              Text(
                text,
                style: _getTextStyle(context),
              ),
            ],
          );

    return SizedBox(
      height: _getHeight(),
      child: _buildButton(context, child, isEffectivelyDisabled),
    );
  }

  Widget _buildButton(BuildContext context, Widget child, bool isEffectivelyDisabled) {
    switch (variant) {
      case ButtonVariant.primary:
        return ElevatedButton(
          onPressed: isEffectivelyDisabled ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: _getBackgroundColor(context, isEffectivelyDisabled),
            foregroundColor: _getForegroundColor(context, isEffectivelyDisabled),
            elevation: isEffectivelyDisabled ? 0 : 2,
            shadowColor: ElimuColors.shadow,
            padding: _getPadding(),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: child,
        );

      case ButtonVariant.secondary:
        return ElevatedButton(
          onPressed: isEffectivelyDisabled ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: _getBackgroundColor(context, isEffectivelyDisabled),
            foregroundColor: _getForegroundColor(context, isEffectivelyDisabled),
            elevation: 0,
            padding: _getPadding(),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: child,
        );

      case ButtonVariant.outline:
        return OutlinedButton(
          onPressed: isEffectivelyDisabled ? null : onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: _getForegroundColor(context, isEffectivelyDisabled),
            side: BorderSide(
              color: _getBorderColor(context, isEffectivelyDisabled),
              width: 1.5,
            ),
            padding: _getPadding(),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: child,
        );

      case ButtonVariant.text:
        return TextButton(
          onPressed: isEffectivelyDisabled ? null : onPressed,
          style: TextButton.styleFrom(
            foregroundColor: _getForegroundColor(context, isEffectivelyDisabled),
            padding: _getPadding(),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: child,
        );
    }
  }

  Color _getBackgroundColor(BuildContext context, bool isDisabled) {
    if (isDisabled) return ElimuColors.disabled;

    switch (variant) {
      case ButtonVariant.primary:
        return ElimuColors.primary;
      case ButtonVariant.secondary:
        return ElimuColors.secondaryContainer;
      case ButtonVariant.outline:
      case ButtonVariant.text:
        return Colors.transparent;
    }
  }

  Color _getForegroundColor(BuildContext context, bool isDisabled) {
    if (isDisabled) return ElimuColors.textTertiary;

    switch (variant) {
      case ButtonVariant.primary:
        return ElimuColors.onPrimary;
      case ButtonVariant.secondary:
        return ElimuColors.onSecondaryContainer;
      case ButtonVariant.outline:
      case ButtonVariant.text:
        return ElimuColors.primary;
    }
  }

  Color _getBorderColor(BuildContext context, bool isDisabled) {
    if (isDisabled) return ElimuColors.disabled;
    return ElimuColors.primary;
  }

  TextStyle _getTextStyle(BuildContext context) {
    final baseStyle = Theme.of(context).textTheme.labelLarge!;
    
    switch (size) {
      case ButtonSize.small:
        return baseStyle.copyWith(fontSize: 12, fontWeight: FontWeight.w600);
      case ButtonSize.medium:
        return baseStyle.copyWith(fontSize: 14, fontWeight: FontWeight.w600);
      case ButtonSize.large:
        return baseStyle.copyWith(fontSize: 16, fontWeight: FontWeight.w600);
    }
  }

  EdgeInsets _getPadding() {
    switch (size) {
      case ButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
      case ButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 12);
      case ButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 32, vertical: 16);
    }
  }

  double _getHeight() {
    switch (size) {
      case ButtonSize.small:
        return 32;
      case ButtonSize.medium:
        return 44;
      case ButtonSize.large:
        return 56;
    }
  }

  double _getIconSize() {
    switch (size) {
      case ButtonSize.small:
        return 16;
      case ButtonSize.medium:
        return 20;
      case ButtonSize.large:
        return 24;
    }
  }
}

enum ButtonVariant { primary, secondary, outline, text }
enum ButtonSize { small, medium, large }
