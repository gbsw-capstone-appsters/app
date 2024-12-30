import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gbsw_capstone_appsters/const/color.dart';
import 'package:gbsw_capstone_appsters/screens/auth/sign_up_screen.dart';
import 'package:gbsw_capstone_appsters/screens/navigator.dart';
import 'package:gbsw_capstone_appsters/widget/custom_button.dart';
import 'package:gbsw_capstone_appsters/widget/custom_text_form_field.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _sign() async {
    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();

    // 입력 유효성 검사
    if (email.length < 6 || email.length > 60) {
      _showSnackBar('이메일은 6자 이상 60자 이하로 입력해주세요.');
      return;
    }

    final emailRegExp = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!emailRegExp.hasMatch(email)) {
      _showSnackBar('이메일 형식이 올바르지 않습니다.');
      return;
    }

    if (password.length < 8 || password.length > 20) {
      _showSnackBar('비밀번호는 8~20자여야 합니다.');
      return;
    }
    if (password.contains(' ')) {
      _showSnackBar('비밀번호에 공백이 포함될 수 없습니다.');
      return;
    }

    setState(() => _isLoading = true);

    // dotenv에서 서버 URL 불러오기
    final String? baseUrl = dotenv.env['SERVER_URL'];
    const String endpoint = '/auth/signin';
    final String url = '$baseUrl$endpoint';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);

        if (responseData['accessToken'] != null) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('accessToken', responseData['accessToken']);
        }

        _showSnackBar('로그인 성공');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainNavigator()),
        );
      } else {
        final errorData = jsonDecode(response.body);
        _showSnackBar('Error: ${errorData['message'] ?? '로그인 실패'}');
      }
    } catch (e) {
      _showSnackBar('네트워크 오류가 발생했습니다: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message) {
    // 현재 표시 중인 SnackBar 닫기
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 1),
          backgroundColor: AppColors.primaryColor,
          content: Text(message),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      builder: (context, child) {
        return Scaffold(
          body: SingleChildScrollView(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 90.h),
                    Image.asset(
                      "assets/images/logo.png",
                      width: 180.w,
                      height: 180.h,
                    ),
                    Text(
                      '문해달',
                      style: TextStyle(
                        color: AppColors.primaryColor,
                        fontSize: 50.sp,
                      ),
                    ),
                    SizedBox(height: 20.h),
                    CustomTextFormField(
                      controller: _emailController,
                      labelText: '이메일',
                    ),
                    SizedBox(height: 20.h),
                    CustomTextFormField(
                      controller: _passwordController,
                      obscuureText: true,
                      labelText: '비밀번호',
                    ),
                    SizedBox(height: 20.h),
                    _isLoading
                        ? const CircularProgressIndicator()
                        : CustomButton(
                            text: '로그인',
                            onPressed: _sign,
                          ),
                    SizedBox(height: 10.h),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SignUpScreen(),
                          ),
                        );
                      },
                      child: Text(
                        '계정이 없나요?',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 18.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
