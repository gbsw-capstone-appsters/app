import 'package:flutter/material.dart';

class CustomTextButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed; // 클릭 이벤트 콜백 (nullable)

  const CustomTextButton({
    required this.text,
    this.onPressed, // 기본값은 null로 설정
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: ButtonStyle(
        splashFactory: NoSplash.splashFactory, // 클릭 애니메이션 제거
      ),
      onPressed: onPressed, // 클릭 이벤트
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.grey, // 텍스트 색상
          fontSize: 16, // 텍스트 크기
          decoration: TextDecoration.underline, // 밑줄 추가
          decorationColor: Colors.grey, // 밑줄 색상
          decorationThickness: 1.0, // 밑줄 굵기
        ),
      ),
    );
  }
}
