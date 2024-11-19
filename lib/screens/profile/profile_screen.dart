import 'package:flutter/material.dart';
import 'package:gbsw_capstone_appsters/screens/profile/drawer/end_drawer.dart';
import 'package:gbsw_capstone_appsters/screens/profile/levelbar/levelbar.dart';
import 'package:gbsw_capstone_appsters/screens/profile/radar_chart/custom_radar_chart.dart';
import 'package:gbsw_capstone_appsters/screens/profile/user/user_profile.dart';
import 'package:gbsw_capstone_appsters/widgets/custom_appbar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final String userName = "김진현";
  final String userContext = "반갑습니다. 오늘도 활기차게 풀어봐요!";
  final double _progress = 1.9; // 진행도 1.0 당 레벨1 증가

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "문해달", // 앱바 제목
        actions: [
          // action 위치
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            height: 30,
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min, // 자식 크기에 맞게 조정
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    "학생",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Builder(
            builder: (context) => IconButton(
              onPressed: () {
                Scaffold.of(context).openEndDrawer(); // endDrawer 열기
              },
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              icon: const Icon(Icons.menu),
            ),
          ),
        ],
        bottomColor: Colors.grey.shade300, // 밑줄 색상
      ),
      endDrawer: EndDrawer(
        userName: userName,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              UserProfile(userName: userName, greetingMessage: userContext),
              const SizedBox(height: 20),
              Levelbar(progress: _progress),

              // 11/19 status 스탯 수정
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Divider(
                  thickness: 0.1,
                  color: Colors.grey.shade800,
                ),
              ),
              Container(
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(width: 5.0, color: Colors.green.shade300),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(width: 5.0, color: Colors.green.shade300),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(width: 5.0, color: Colors.green.shade300),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Divider(
                  thickness: 0.1,
                  color: Colors.grey.shade800,
                ),
              ),
              // status 스탯

              const CustomRadarChart(),
            ],
          ),
        ),
      ),
    );
  }
}
