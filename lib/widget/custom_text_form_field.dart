import 'package:flutter/material.dart';

class CustomTextFormField extends StatelessWidget {
  final String labelText;
  final TextEditingController controller;
  final bool obscuureText;
  final TextInputType keyboardType;

  const CustomTextFormField({
    super.key,
    required this.labelText,
    required this.controller,
    this.obscuureText = false,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscuureText,
      keyboardType: keyboardType, // 전달받은 keyboardType 사용
      decoration: InputDecoration(
        floatingLabelStyle: const TextStyle(color: Color(0xff648DFC)),
        labelText: labelText,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: Color(0xff648DFC),
          ),
        ),
      ),
    );
  }
}
