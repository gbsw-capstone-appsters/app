import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gbsw_capstone_appsters/const/color.dart';
import 'package:gbsw_capstone_appsters/widget/custom_button.dart';
import 'package:gbsw_capstone_appsters/widget/custom_text_form_field.dart';
import 'package:http/http.dart' as http;

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _nickNameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  String _selectedRole = "student"; // Default role

  bool _isLoading = false;

  Future<void> _signup() async {
    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();
    final String confirmPassword = _confirmPasswordController.text.trim();
    final String nickName = _nickNameController.text.trim();
    final String ageText = _ageController.text.trim();

    // 입력값 유효성 검사
    if (email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty ||
        nickName.isEmpty ||
        ageText.isEmpty) {
      _showSnackBar("모든 필드를 입력해주세요.");
      return;
    }

    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)) {
      _showSnackBar("유효한 이메일 형식이 아닙니다.");
      return;
    }

    if (password != confirmPassword) {
      _showSnackBar("비밀번호와 비밀번호 확인이 일치하지 않습니다.");
      return;
    }

    if (password.length < 8 || password.length > 20) {
      _showSnackBar("비밀번호는 8~20자여야 합니다.");
      return;
    }

    final int? age = int.tryParse(ageText);
    if (age == null || age <= 0) {
      _showSnackBar("유효한 나이를 입력해주세요.");
      return;
    }

    setState(() => _isLoading = true);

    // 서버 URL
    final String? baseUrl = dotenv.env['SERVER_URL'];
    const String endpoint = '/auth/signup';
    final String url = '$baseUrl$endpoint';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'nickName': nickName,
          'age': age,
          'role': _selectedRole,
        }),
      );

      if (response.statusCode == 201) {
        _showSnackBar("회원가입 성공!");
        Navigator.pop(context); // 회원가입 성공 후 이전 화면으로 이동
      } else {
        final errorData = jsonDecode(response.body);
        _showSnackBar("오류: ${errorData['message'] ?? '회원가입 실패'}");
      }
    } catch (e) {
      _showSnackBar("네트워크 오류가 발생했습니다: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("회원가입")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 100),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextFormField(
                controller: _emailController,
                labelText: "이메일",
              ),
              const SizedBox(height: 20),
              CustomTextFormField(
                controller: _passwordController,
                obscuureText: true,
                labelText: "비밀번호",
              ),
              const SizedBox(height: 20),
              CustomTextFormField(
                controller: _confirmPasswordController,
                obscuureText: true,
                labelText: "비밀번호 확인",
              ),
              const SizedBox(height: 20),
              const Text("역할 선택"),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      contentPadding: EdgeInsets.zero,
                      activeColor: AppColors.primaryColor,
                      title: const Text("학생"),
                      value: "student",
                      groupValue: _selectedRole,
                      onChanged: (value) {
                        setState(() {
                          _selectedRole = value!;
                          if (_selectedRole == "student") {
                            _ageController.text = "";
                          }
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      contentPadding: EdgeInsets.zero,
                      activeColor: AppColors.primaryColor,
                      title: const Text("부모님"),
                      value: "parent",
                      groupValue: _selectedRole,
                      onChanged: (value) {
                        setState(() {
                          _selectedRole = value!;
                          if (_selectedRole == "parent") {
                            _ageController.text = ""; // 부모님 선택 시 기본 나이 설정
                          }
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              CustomTextFormField(
                controller: _nickNameController,
                labelText: "닉네임을 입력하세요.",
              ),
              const SizedBox(height: 20),
              CustomTextFormField(
                controller: _ageController,
                keyboardType: TextInputType.number,
                labelText: "나이를 입력하세요",
              ),
              const SizedBox(height: 30),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Center(
                      child: CustomButton(
                        onPressed: _signup,
                        text: "회원가입",
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
