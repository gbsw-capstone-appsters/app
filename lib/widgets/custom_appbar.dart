import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title; // 앱바 제목
  final Color bottomColor; // 밑줄 색상
  final List<Widget>? actions;

  const CustomAppBar({
    required this.title,
    this.bottomColor = const Color(0xFFBDBDBD), // 기본 회색 색상
    this.actions,
    super.key,
  });

  @override
  Size get preferredSize => const Size.fromHeight(56 + 1); // AppBar 높이 + 밑줄 두께

  @override
  Widget build(BuildContext context) {
    return AppBar(
      scrolledUnderElevation: 0,
      backgroundColor: Colors.white,
      centerTitle: false,
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
      actions: actions,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1.0), // 밑줄 높이
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Container(
            color: bottomColor, // 전달받은 밑줄 색상
            height: 1.0, // 밑줄 두께
          ),
        ),
      ),
    );
  }
}
