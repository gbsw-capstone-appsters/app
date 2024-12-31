import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ReadingComprehension extends StatefulWidget {
  const ReadingComprehension({super.key});

  @override
  State<ReadingComprehension> createState() => _ReadingComprehensionState();
}

class _ReadingComprehensionState extends State<ReadingComprehension> {
  String? passage; // 받아온 지문 데이터를 저장
  bool isLoading = true; // 로딩 상태 관리

  @override
  void initState() {
    super.initState();
    fetchPassage(); // 지문 데이터 가져오기
  }

  Future<void> fetchPassage() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString('accessToken');

      if (accessToken == null) {
        throw Exception("Access Token이 없습니다.");
      }

      final String? baseUrl = dotenv.env['SERVER_URL'];
      const String endpoint = '/quiz/start';
      final String url = '$baseUrl$endpoint';

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          "userId": 1, // 사용자 ID 예시
          "category": "사자성어" // 카테고리 예시
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        setState(() {
          passage = data['passage']; // 받아온 지문 데이터 저장
          isLoading = false;
        });
      } else {
        throw Exception('데이터를 불러오는 데 실패했습니다.');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('오류 발생: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("지문 보기"),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Text(
                  passage ?? "지문을 불러오지 못했습니다.",
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.6,
                  ),
                ),
              ),
            ),
    );
  }
}
