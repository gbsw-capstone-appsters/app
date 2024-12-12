import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class CustomRadarChart extends StatefulWidget {
  const CustomRadarChart({super.key});

  @override
  State<CustomRadarChart> createState() => _CustomRadarChartState();
}

class _CustomRadarChartState extends State<CustomRadarChart> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: MediaQuery.of(context).size.width / 1.5,
        height: 300,
        child: RadarChart(
          RadarChartData(
            dataSets: [
              RadarDataSet(
                entryRadius: 3,
                dataEntries: const [
                  RadarEntry(value: 0.8),
                  RadarEntry(value: 0.5),
                  RadarEntry(value: 0.4),
                  RadarEntry(value: 0.6),
                  RadarEntry(value: 0.7),
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
                  return const RadarChartTitle(text: "어휘력");
                case 1:
                  return const RadarChartTitle(text: "문장 이해력");
                case 2:
                  return const RadarChartTitle(text: "추론 능력");
                case 3:
                  return const RadarChartTitle(text: "비판적 사고");
                case 4:
                  return const RadarChartTitle(text: "정보 활용 능력");
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
