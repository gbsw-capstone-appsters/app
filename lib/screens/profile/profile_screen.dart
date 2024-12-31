import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gbsw_capstone_appsters/const/color.dart';
import 'package:gbsw_capstone_appsters/screens/profile/radar_chart.dart';
import 'package:gbsw_capstone_appsters/services/auth_service.dart';
import 'package:http/http.dart' as http;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  Map<String, dynamic>? profileData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    try {
      String? accessToken = await _authService.getValidAccessToken();

      if (accessToken == null) {
        showErrorSnackBar("Access Token이 없습니다.");
        return;
      }

      final String? baseUrl = dotenv.env['SERVER_URL'];
      const String endpoint = '/auth/me';
      final String url = '$baseUrl$endpoint';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          profileData = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        showErrorSnackBar("프로필 데이터를 불러오지 못했습니다.");
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      showErrorSnackBar("네트워크 오류가 발생했습니다: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  void showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: isLoading
          ? Center(
              child: Image.asset(
                'assets/images/logo.png',
                scale: 1.8,
              ),
            )
          : profileData != null
              ? SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildProfileHeader(),
                      _buildQuizStats(),
                      _buildRadarChartSection(),
                      _buildRecentActivity(),
                      _buildAchievements(),
                    ],
                  ),
                )
              : const Center(child: Text("프로필 정보를 가져오지 못했습니다.")),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.basicColor,
                width: 3,
              ),
            ),
            child: CircleAvatar(
              radius: 40,
              backgroundImage: profileData!['imageUri'] != null
                  ? NetworkImage(profileData!['imageUri']) as ImageProvider
                  : const AssetImage('assets/images/default.png'),
              backgroundColor: AppColors.basicColor,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profileData!['nickName'],
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: IntrinsicWidth(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 2),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: AppColors.basicColor,
                              borderRadius: BorderRadius.circular(100),
                            ),
                          ),
                          const SizedBox(width: 8), // 점과 텍스트 간의 간격
                          Text(
                            _getRoleDisplayName(profileData!['role']),
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.basicColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  profileData!['email'],
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizStats() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '퀴즈 통계',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('총 퀴즈 수', '128', Icons.quiz_outlined),
              _buildStatItem('정답률', '75%', Icons.check_circle_outline),
              _buildStatItem('획득 포인트', '2,450', Icons.stars_outlined),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.basicColor,
            border: Border.all(width: 1, color: AppColors.primaryColor),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: AppColors.primaryColor,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildRadarChartSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '역량 분석',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20),
          CustomRadarChart(),
        ],
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '최근 활동',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
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
    );
  }

  Widget _buildAchievements() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '획득한 뱃지',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildBadge('퀴즈 마스터', Icons.emoji_events_outlined),
              _buildBadge('연속 학습 7일', Icons.calendar_today_outlined),
              _buildBadge('빠른 손', Icons.speed_outlined),
              _buildBadge('완벽주의자', Icons.workspace_premium_outlined),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String label, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.basicColor,
            shape: BoxShape.circle,
            border: Border.all(width: 1, color: AppColors.primaryColor),
          ),
          child: Icon(
            icon,
            color: AppColors.primaryColor,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 20),
      ],
    );
  }

  String _getRoleDisplayName(String role) {
    switch (role) {
      case "student":
        return "학생";
      case "parent":
        return "부모님";
      default:
        return "알 수 없음";
    }
  }
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
