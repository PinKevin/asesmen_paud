import 'package:flutter/material.dart';

class SeriesPhotoField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String? errorText;

  const SeriesPhotoField(
      {super.key,
      required this.controller,
      required this.labelText,
      required this.errorText});

  @override
  Widget build(BuildContext context) {
    return TextField(
      onTapOutside: (event) {
        FocusScope.of(context).unfocus();
      },
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        border: const OutlineInputBorder(),
        errorText: errorText,
        errorBorder:
            const OutlineInputBorder(borderSide: BorderSide(color: Colors.red)),
      ),
      keyboardType: TextInputType.multiline,
      minLines: 1,
      maxLines: 5,
    );
  }
}
