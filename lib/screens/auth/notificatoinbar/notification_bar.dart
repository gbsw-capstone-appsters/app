import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';

class NotificationBar extends StatelessWidget {
  final String message; // 사용자 정의 텍스트
  final Color backgroundColor; // 배경 색상
  final double borderRadius; // 모서리 둥글기
  final IconData icon; // 좌측 아이콘

  const NotificationBar({
    required this.message,
    this.backgroundColor = Colors.black, // 기본값: 파란색
    this.borderRadius = 12.0, // 기본값: 12
    this.icon = Icons.notification_important, // 기본값: 알림 아이콘
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius), // 모서리 둥글게 설정
      child: Container(
        height: 50,
        color: backgroundColor,
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Icon(
                icon,
                color: Colors.red,
                size: 24,
              ),
            ),
            Expanded(
              child: Marquee(
                text: message,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                scrollAxis: Axis.horizontal, // 가로 스크롤
                crossAxisAlignment: CrossAxisAlignment.center, // 세로 중앙 정렬
                blankSpace: MediaQuery.of(context).size.width, // 텍스트 사이 간격
                velocity: 50.0, // 스크롤 속도
                startPadding: 10.0, // 시작 패딩
              ),
            ),
          ],
        ),
      ),
    );
  }
}
