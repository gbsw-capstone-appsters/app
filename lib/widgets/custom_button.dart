import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;
  final Color? color; // 색상 추가

  const CustomButton({
    required this.onPressed,
    required this.child,
    this.color, // 색상 추가
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color, // 색상 적용
      ),
      child: child,
    );
  }
}
