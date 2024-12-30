import 'package:flutter/material.dart';
import 'package:gbsw_capstone_appsters/screens/eyedid/eyedid.dart';
import 'package:gbsw_capstone_appsters/screens/profile/profile_edit.dart';
import 'package:gbsw_capstone_appsters/screens/setting/setting_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gbsw_capstone_appsters/const/color.dart';
import 'package:gbsw_capstone_appsters/screens/auth/sign_in_screen.dart';

class EndDrawer extends StatelessWidget {
  const EndDrawer({super.key});

  Future<void> _logout(BuildContext context) async {
    // SharedPreferences에서 accessToken 삭제
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('accessToken');

    // 로그인 화면으로 이동
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const SignInScreen()),
      (route) => false, // 이전 모든 화면 제거
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.basicColor,
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(
              color: AppColors.primaryColor,
            ),
            child: Text(
              '메뉴',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.account_circle),
            title: const Text('프로필 수정'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfileEdit(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('설정'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingScreen()),
              );
            },
          ),
          const Divider(
            thickness: 0.5,
            color: Colors.grey,
          ),
          ListTile(
            leading: const Icon(Icons.exit_to_app),
            title: const Text('로그아웃'),
            onTap: () {
              _logout(context); // 로그아웃 함수 호출
            },
          ),
        ],
      ),
    );
  }
}
