import 'package:flutter/material.dart';
import 'package:gbsw_capstone_appsters/screens/profile/levelbar/levelbar.dart';
import 'package:gbsw_capstone_appsters/screens/profile/user/user_profile.dart';
import 'package:gbsw_capstone_appsters/widgets/custom_appbar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final String userName = "김진현";
  final String userContext = "반갑습니다.";
  final double _progress = 0.8;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "문해달", // 앱바 제목
        actions: [
          IconButton(
            onPressed: () {
              print("click");
            },
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            icon: const Icon(Icons.menu),
          ),
        ],
        bottomColor: Colors.grey.shade300, // 밑줄 색상
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            children: [
              UserProfile(userName: userName, greetingMessage: userContext),
              const SizedBox(height: 20),
              Levelbar(progress: _progress),
              Container(
                height: MediaQuery.of(context).size.height,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
