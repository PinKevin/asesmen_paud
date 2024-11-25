import 'package:flutter/material.dart';

class SearchField extends StatefulWidget {
  final TextEditingController controller;

  const SearchField({super.key, required this.controller});

  @override
  SearchFieldState createState() => SearchFieldState();
}

class SearchFieldState extends State<SearchField> {
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(() {
      setState(() {
        _hasText = widget.controller.text.isNotEmpty;
      });
    });
  }

  void _clearSearch() {
    widget.controller.clear();
    setState(() {
      _hasText = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      decoration: InputDecoration(
          labelText: 'Cari',
          border: const OutlineInputBorder(),
          suffixIcon: IconButton(
              onPressed: _hasText ? _clearSearch : null,
              icon: Icon(_hasText ? Icons.clear : Icons.search))),
      onTapOutside: (event) {
        FocusScope.of(context).unfocus();
      },
    );
  }

  @override
  void dispose() {
    widget.controller.dispose();
    super.dispose();
  }
}
