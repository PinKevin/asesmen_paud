import 'package:flutter/material.dart';

class SubmitSecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;
  final Color? iconColor;
  // final double? width;

  const SubmitSecondaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor,
    this.textColor = Colors.deepPurple,
    this.icon,
    this.iconColor,
    // this.width,
  });

  @override
  Widget build(BuildContext context) {
    if (icon == null) {
      return ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          minimumSize: const Size(100, 40),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 16,
            color: textColor,
          ),
        ),
      );
    }

    return ElevatedButton.icon(
      label: Text(
        text,
        style: TextStyle(color: textColor),
      ),
      onPressed: onPressed,
      icon: Icon(
        icon,
        color: iconColor,
      ),
      style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
    );
  }
}
