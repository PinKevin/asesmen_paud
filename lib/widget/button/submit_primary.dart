import 'package:flutter/material.dart';

class SubmitPrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;
  // final double? width;

  const SubmitPrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    required this.isLoading,
    this.backgroundColor = Colors.deepPurple,
    this.textColor = Colors.white,
    this.icon,
    // this.width,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        minimumSize: const Size(200, 40),
      ),
      child: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              ),
            )
          : Text(
              text,
              style: TextStyle(
                fontSize: 16,
                color: textColor,
              ),
            ),
    );
  }
}
