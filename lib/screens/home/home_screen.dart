import 'package:flutter/material.dart';
import 'package:gbsw_capstone_appsters/screens/eyedid/eyedid.dart';
import 'package:gbsw_capstone_appsters/screens/quiz/quiz_screen.dart';
import 'package:gbsw_capstone_appsters/screens/quiz/reading_comprehension.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _gradientStartColor;
  late Animation<Color?> _gradientEndColor;

  bool isPressed = false;

  @override
  void initState() {
    super.initState();

    // 애니메이션 컨트롤러 초기화
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _gradientStartColor = ColorTween(
      begin: const Color(0xFF7C4DFF),
      end: const Color(0xFF512DA8),
    ).animate(_controller);

    _gradientEndColor = ColorTween(
      begin: const Color.fromARGB(255, 67, 159, 230),
      end: const Color.fromARGB(255, 0, 120, 249),
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                // 헤더 섹션
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "안녕하세요 👋",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "오늘의 문해력 퀴즈",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    CircleAvatar(
                      backgroundColor: Colors.grey[200],
                      child: const Icon(Icons.person, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                // 메인 퀴즈 카드
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return GestureDetector(
                      onTapDown: (_) {
                        setState(() {
                          isPressed = true;
                        });
                      },
                      onTapUp: (_) {
                        setState(() {
                          isPressed = false;
                        });
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const QuizScreen()),
                        );
                      },
                      child: Center(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 100),
                          curve: Curves.easeInOut,
                          width: isPressed ? 340 : 350, // 클릭 시 크기 변화
                          height: isPressed ? 150 : 180,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                _gradientStartColor.value!,
                                _gradientEndColor.value!,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: child,
                        ),
                      ),
                    );
                  },
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.quiz,
                          size: 50,
                          color: Colors.white,
                        ),
                        SizedBox(height: 15),
                        Text(
                          "오늘의 퀴즈 풀기",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "새로운 퀴즈가 준비되어 있어요!",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // 통계 섹션
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        "맞힌 문제",
                        "32",
                        Icons.check_circle_outline,
                        Colors.green,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: _buildStatCard(
                        "퀴즈를 풀었어요!",
                        "5개",
                        Icons.local_fire_department_outlined,
                        Colors.orange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                // 최근 활동 섹션
                const Text(
                  "최근 활동",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 15),
                _buildActivityCard(
                  "일상생활 독해력 테스트",
                  "완료",
                  "2024.03.15",
                  Icons.article_outlined,
                ),
                _buildActivityCard(
                  "뉴스 기사 읽기 테스트",
                  "진행중",
                  "2024.03.14",
                  Icons.newspaper_outlined,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard(
      String title, String status, String date, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.grey[700]),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: status == "완료" ? Colors.green[50] : Colors.orange[50],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: status == "완료" ? Colors.green : Colors.orange,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
