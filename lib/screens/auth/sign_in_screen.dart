import 'package:flutter/material.dart';
import 'package:gbsw_capstone_appsters/screens/auth/notificatoinbar/notification_bar.dart';
import 'package:gbsw_capstone_appsters/screens/navigator.dart';
import 'package:gbsw_capstone_appsters/widgets/custom_button.dart';
import 'package:gbsw_capstone_appsters/widgets/custom_form_feild.dart';
import 'package:gbsw_capstone_appsters/widgets/custom_text_button.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final String message = '개발 단계입니다.';

  // 애니메이션 상태
  bool _logoAnimation = false;
  bool _formAnimation = false;

  @override
  void initState() {
    super.initState();

    // 로고 애니메이션 시작
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _logoAnimation = true;
        });

        // 로고 애니메이션 완료 후 로그인 폼 애니메이션 시작
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            setState(() {
              _formAnimation = true;
            });
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          // 로고 애니메이션
          AnimatedPositioned(
            duration: const Duration(seconds: 1),
            curve: Curves.easeInOut,
            top: _logoAnimation ? 150 : screenHeight / 2 - 100, // 위로 이동
            left: 0,
            right: 0,
            child: AnimatedScale(
              scale: _logoAnimation ? 1.5 : 1.0, // 크기 변경
              duration: const Duration(seconds: 1),
              curve: Curves.easeInOut,
              child: Image.asset(
                'assets/images/logo_black.png',
                width: 200,
                height: 200,
              ),
            ),
          ),

          // 로그인 폼 애니메이션
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 100),
            child: AnimatedOpacity(
              duration: const Duration(seconds: 1),
              opacity: _formAnimation ? 1.0 : 0.0, // 투명도 변경
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: NotificationBar(
                        message: message,
                      ),
                    ),
                    CustomTextFormField(
                      hintText: '아이디',
                      controller: _idController,
                    ),
                    const SizedBox(height: 10),
                    CustomTextFormField(
                      hintText: '비밀번호',
                      controller: _passwordController,
                      obscureText: true,
                    ),
                    const SizedBox(height: 15),
                    SizedBox(
                      width: double.infinity,
                      child: CustomButton(
                        color: Colors.black,
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => MainNaviator()),
                          );
                        },
                        child: const Text(
                          "로그인",
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    CustomTextButton(text: '회원가입하기'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
