import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gbsw_capstone_appsters/const/color.dart';
import 'package:gbsw_capstone_appsters/screens/home/home_screen.dart';
import 'package:gbsw_capstone_appsters/screens/profile/profile_screen.dart';
import 'package:gbsw_capstone_appsters/screens/rank/rank_screen.dart';
import 'package:gbsw_capstone_appsters/screens/parent/parent_home.dart.dart'; // 부모 화면
import 'package:gbsw_capstone_appsters/widget/custom_appbar.dart';
import 'package:gbsw_capstone_appsters/widget/end_drawer.dart';
import 'package:motion_tab_bar_v2/motion-tab-bar.dart';
import 'package:motion_tab_bar_v2/motion-tab-controller.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

final GlobalKey<_MainNavigatorState> mainNavigatorKey =
    GlobalKey<_MainNavigatorState>();

class MainNavigator extends StatefulWidget {
  const MainNavigator({super.key});

  @override
  State<MainNavigator> createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator>
    with TickerProviderStateMixin {
  late MotionTabBarController _motionTabBarController;
  bool isLoading = true;
  String userRole = 'student'; // 기본값 설정

  @override
  void initState() {
    super.initState();
    _motionTabBarController = MotionTabBarController(
      initialIndex: 1, // 기본적으로 홈 화면이 선택됨
      length: 3,
      vsync: this,
    );
    fetchUserRole();
  }

  @override
  void dispose() {
    _motionTabBarController.dispose();
    super.dispose();
  }

  Future<void> fetchUserRole() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString('accessToken');

      if (accessToken == null) {
        throw Exception("Access Token이 없습니다.");
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
        final userData = jsonDecode(response.body);
        setState(() {
          userRole = userData['role'] ?? 'student'; // 기본값 student
          isLoading = false;
        });
      } else {
        throw Exception('사용자 데이터를 불러오지 못했습니다.');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: CustomAppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        title: '문해달',
        titleStyle: const TextStyle(
          color: AppColors.basicColor,
        ),
        actions: [
          Builder(
            builder: (context) => IconButton(
              color: AppColors.basicColor,
              onPressed: () {
                Scaffold.of(context).openEndDrawer();
              },
              icon: Icon(Icons.menu),
            ),
          ),
        ],
      ),
      endDrawer: EndDrawer(),
      bottomNavigationBar: MotionTabBar(
        controller: _motionTabBarController,
        initialSelectedTab: "홈", // 초기 선택 탭을 "홈"으로 설정
        useSafeArea: true,
        labels: const ["랭킹", "홈", "프로필"],
        icons: const [
          Icons.emoji_events_outlined,
          Icons.home,
          Icons.person,
        ],
        tabSize: 50,
        tabBarHeight: 55,
        textStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        tabIconColor: Colors.grey,
        tabIconSelectedColor: AppColors.basicColor,
        tabSelectedColor: AppColors.primaryColor,
        tabBarColor: AppColors.basicColor,
        onTabItemSelected: (int index) {
          setState(() {
            _motionTabBarController.index = index;
          });
        },
      ),
      body: TabBarView(
        physics: const NeverScrollableScrollPhysics(),
        controller: _motionTabBarController,
        children: [
          RankScreen(
            onNavigateToHome: () => setState(() {
              _motionTabBarController.index = 1; // 홈 탭으로 전환
            }),
          ),
          userRole == 'parent' ? ParentHome() : HomeScreen(), // 역할에 따른 화면
          userRole == 'parent' ? ParentHome() : ProfileScreen(),
        ],
      ),
    );
  }
}
