import 'package:blush_hush_admin/constants/styles.dart';
import 'package:flutter/material.dart';

class InputContainer extends StatelessWidget {
  final String hintText;
  final TextEditingController textEditingController;
  const InputContainer({super.key,required this.hintText,required this.textEditingController});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Styles.inputFieldColor
      ),
      child: TextField(
        controller: textEditingController,
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 10),
          hintText: hintText,
        ),
      ),
    );
  }
}