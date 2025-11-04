import 'package:flutter/material.dart';

class SearchBarWidget extends StatelessWidget {
  final ValueChanged<String> onChanged;
  final String hintText;

  const SearchBarWidget({
    super.key,
    required this.onChanged,
    this.hintText = "Search...",
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
        
      ),
    );
  }
}