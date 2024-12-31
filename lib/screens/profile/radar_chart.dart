import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CustomRadarChart extends StatefulWidget {
  const CustomRadarChart({super.key});

  @override
  State<CustomRadarChart> createState() => _CustomRadarChartState();
}

class _CustomRadarChartState extends State<CustomRadarChart> {
  bool isLoading = true;
  Map<String, dynamic> scores = {
    "문법": 0,
    "고사성어": 0,
    "독해": 0,
    "어휘": 0,
    "사자성어": 0,
  };

  @override
  void initState() {
    super.initState();
    fetchScores();
  }

  Future<void> fetchScores() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString('accessToken');

      if (accessToken == null) {
        throw Exception("Access Token이 없습니다.");
      }

      final String? baseUrl = dotenv.env['SERVER_URL'];
      const String endpoint = '/quiz/student/best-scores';
      final String url = '$baseUrl$endpoint';
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (mounted) {
          setState(() {
            scores.forEach((key, value) {
              if (responseData.containsKey(key)) {
                scores[key] = (responseData[key] as num).toDouble() / 100;
              } else {
                scores[key] = 0.0;
              }
            });
            isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
        throw Exception('퀴즈 데이터를 불러오지 못했습니다.');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Center(
      child: SizedBox(
        width: MediaQuery.of(context).size.width / 1.5,
        height: 300,
        child: RadarChart(
          RadarChartData(
            dataSets: [
              RadarDataSet(
                entryRadius: 3,
                dataEntries: [
                  RadarEntry(value: scores["문법"]),
                  RadarEntry(value: scores["고사성어"]),
                  RadarEntry(value: scores["독해"]),
                  RadarEntry(value: scores["어휘"]),
                  RadarEntry(value: scores["사자성어"]),
                ],
                fillColor: Colors.blue.withOpacity(0.15),
                borderColor: Colors.blue,
                borderWidth: 2,
              ),
            ],
            radarShape: RadarShape.polygon,
            radarBorderData: const BorderSide(color: Colors.transparent),
            gridBorderData: BorderSide(color: Colors.grey.shade300, width: 0.5),
            radarBackgroundColor: Colors.transparent,
            tickBorderData: BorderSide(
              color: Colors.grey.shade400,
              width: 0.5,
            ),
            tickCount: 5,
            ticksTextStyle: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade600,
            ),
            titleTextStyle: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            titlePositionPercentageOffset: 0.2,
            getTitle: (index, angle) {
              switch (index) {
                case 0:
                  return const RadarChartTitle(text: "문법");
                case 1:
                  return const RadarChartTitle(text: "고사성어");
                case 2:
                  return const RadarChartTitle(text: "독해");
                case 3:
                  return const RadarChartTitle(text: "어휘");
                case 4:
                  return const RadarChartTitle(text: "사자성어");
                default:
                  return const RadarChartTitle(text: '');
              }
            },
          ),
        ),
      ),
    );
  }
}
