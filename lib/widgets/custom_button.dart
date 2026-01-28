import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final IconData? icon;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final child = loading
        ? const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : Text(label);

    if (icon == null) {
      return FilledButton(
        onPressed: loading ? null : onPressed,
        child: child,
      );
    }

    return FilledButton.icon(
      onPressed: loading ? null : onPressed,
      icon: Icon(icon, size: 20),
      label: child,
    );
  }
}
