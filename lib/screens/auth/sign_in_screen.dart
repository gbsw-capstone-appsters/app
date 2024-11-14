import 'package:flutter/material.dart';
import 'package:gbsw_capstone_appsters/widgets/custom_form_feild.dart';
import 'package:gbsw_capstone_appsters/widgets/custom_button.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  bool _isLogoAnimated = false;
  bool _isContentVisible = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        _isLogoAnimated = true;
      });
    });

    Future.delayed(const Duration(seconds: 4), () {
      setState(() {
        _isContentVisible = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          AnimatedPositioned(
              duration: const Duration(seconds: 2),
              curve: Curves.easeInOut,
              top: _isLogoAnimated
                  ? 150
                  : MediaQuery.of(context).size.height / 2 - 60,
              left: MediaQuery.of(context).size.width / 2 - 60,
              child: const Center(
                child: Text("문해달"),
              )),
          Center(
            child: AnimatedOpacity(
              duration: const Duration(seconds: 2),
              opacity: _isContentVisible ? 1.0 : 0.0,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomTextFormField(
                      labelText: '아이디',
                      controller: TextEditingController(),
                    ),
                    const SizedBox(height: 20),
                    CustomTextFormField(
                      labelText: '비밀번호',
                      controller: TextEditingController(),
                      obscureText: true,
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: CustomButton(
                        onPressed: () {},
                        child: const Text('로그인'),
                      ),
                    ),
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
