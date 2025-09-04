import 'package:flutter/material.dart';

class ColorSnackbar {
  static SnackBar build({
    required String message,
    required bool success,
    SnackBarAction? action,
  }) {
    return SnackBar(
      content: Text(
        message,
        style:
            const TextStyle(color: Colors.white, fontWeight: FontWeight.w400),
      ),
      backgroundColor: success ? Colors.green[600] : Colors.red[600],
      action: action,
    );
  }
}
