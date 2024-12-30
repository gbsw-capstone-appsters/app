import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String _refreshUrl = '${dotenv.env['API_URL']}/auth/refresh';

  // 토큰이 만료되었거나 만료 임박 여부를 확인하는 함수
  bool _isTokenExpiredOrNearExpiry(String token) {
    try {
      // JWT 토큰 디코딩
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);

      // 만료 시간 가져오기 (Unix 타임스탬프)
      int exp = decodedToken['exp'];

      // 현재 시간 가져오기 (Unix 타임스탬프)
      int currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      // 남은 시간 계산
      int timeLeft = exp - currentTime;

      // 남은 시간 출력
      print('남은 시간: ${timeLeft ~/ 60}분 ${timeLeft % 60}초');

      // 만료 시간 5분 이하이면 true 반환
      return timeLeft <= 300; // 5분 (300초)
    } catch (e) {
      // JWT 디코딩 실패 시 만료된 것으로 간주
      print('Error decoding JWT: $e');
      return true;
    }
  }

  // 유효한 access token 반환 (필요시 재발급)
  Future<String?> getValidAccessToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('accessToken');

    // Access Token이 없거나 만료된 경우
    if (accessToken == null || _isTokenExpiredOrNearExpiry(accessToken)) {
      print("Access Token 만료 또는 없음. 재발급 요청...");
      bool success = await _refreshAccessToken();
      if (success) {
        accessToken = prefs.getString('accessToken');
      } else {
        print("Access Token 재발급 실패");
        return null;
      }
    }

    return accessToken;
  }

  // Refresh Token을 사용하여 Access Token 재발급
  Future<bool> _refreshAccessToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? refreshToken = prefs.getString('refreshToken');

    // Refresh Token이 없는 경우 실패 반환
    if (refreshToken == null) {
      print("Refresh Token 없음");
      return false;
    }

    try {
      // GET 요청으로 토큰 재발급
      final response = await http.get(
        Uri.parse(_refreshUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $refreshToken',
        },
      );

      print("Refresh Token 요청 응답: ${response.statusCode}");

      if (response.statusCode == 200) {
        // 응답 데이터 파싱
        final responseData = jsonDecode(response.body);
        final newAccessToken = responseData['accessToken'];
        final newRefreshToken = responseData['refreshToken'];

        // 새 토큰 저장
        await prefs.setString('accessToken', newAccessToken);
        await prefs.setString('refreshToken', newRefreshToken);

        print("새로운 Access Token 재발급 성공");
        return true;
      } else {
        print("토큰 재발급 실패: ${response.body}");
        return false;
      }
    } catch (e) {
      print('Error refreshing token: $e');
      return false;
    }
  }
}
