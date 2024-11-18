import 'package:flutter/material.dart';
import 'package:gbsw_capstone_appsters/style/colors.dart';

class CustomTextFormField extends StatelessWidget {
  final String hintText;
  final bool obscureText;
  final TextEditingController controller;
  final Icon? icon; // 아이콘 추가

  const CustomTextFormField({
    required this.hintText,
    required this.controller,
    this.obscureText = false,
    this.icon, // 아이콘 추가
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        fillColor: Colors.white,
        filled: true,
        hintText: hintText,
        prefixIcon: icon, // 아이콘을 label 텍스트 왼쪽에 추가
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: const BorderSide(
            color: AppColors.secondary2,
          ),
        ),
      ),
      cursorColor: Colors.black,
    );
  }
}
