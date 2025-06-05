import 'package:flutter/material.dart';

class ExpandedTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String? errorText;
  final String? Function(String? value)? validator;
  final Function(String)? onChanged;
  final bool enabled;

  const ExpandedTextFormField({
    super.key,
    required this.controller,
    required this.labelText,
    this.errorText,
    this.validator,
    this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: labelText,
        border: const OutlineInputBorder(),
        errorText: errorText,
        errorBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red),
        ),
      ),
      keyboardType: TextInputType.emailAddress,
      textCapitalization: TextCapitalization.sentences,
      minLines: 1,
      maxLines: 5,
      onChanged: onChanged,
      onTapOutside: (event) {
        FocusScope.of(context).unfocus();
      },
    );
  }
}
