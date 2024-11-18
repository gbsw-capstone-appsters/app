import 'package:flutter/material.dart';

class Levelbar extends StatelessWidget {
  final double progress;

  const Levelbar({
    required this.progress,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    double displayedProgress = progress % 1.1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "레벨 진행도",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: LinearProgressIndicator(
            value: displayedProgress, // 변환된 진행도 사용
            backgroundColor: Colors.grey[300],
            color: Colors.lightGreenAccent.shade700,
            borderRadius: BorderRadius.circular(100),
            minHeight: 10,
          ),
        ),
        const SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              "${(displayedProgress * 100).toInt()}%", // 변환된 진행도 표시
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
