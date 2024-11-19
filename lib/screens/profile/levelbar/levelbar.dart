import 'package:flutter/material.dart';

class Levelbar extends StatefulWidget {
  final double progress;

  const Levelbar({
    required this.progress,
    super.key,
  });

  @override
  State<Levelbar> createState() => _LevelbarState();
}

class _LevelbarState extends State<Levelbar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  int _calculateLevel(double progress) {
    return (progress / 1.0).floor() + 1;
  }

  double _calculateProgressForCurrentLevel(double progress) {
    return progress % 1.0;
  }

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _animation = Tween<double>(
      begin: 0.0,
      end: _calculateProgressForCurrentLevel(widget.progress),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int level = _calculateLevel(widget.progress);
    double currentLevelProgress =
        _calculateProgressForCurrentLevel(widget.progress);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "진행도",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Level : $level',
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ],
        ),
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: LinearProgressIndicator(
                value: _animation.value,
                backgroundColor: Colors.grey[300],
                color: Colors.lightGreenAccent.shade700,
                minHeight: 10,
                borderRadius: BorderRadius.circular(100),
              ),
            );
          },
        ),
        const SizedBox(height: 5),
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  "${(currentLevelProgress * 100).toInt()}%",
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
