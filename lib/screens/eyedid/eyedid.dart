import 'package:eyedid_flutter/constants/eyedid_flutter_calibration_option.dart';
import 'package:eyedid_flutter/events/eyedid_flutter_drop.dart';
import 'package:eyedid_flutter/eyedid_flutter_initialized_result.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:eyedid_flutter/gaze_tracker_options.dart';
import 'package:eyedid_flutter/events/eyedid_flutter_metrics.dart';
import 'package:eyedid_flutter/events/eyedid_flutter_status.dart';
import 'package:eyedid_flutter/events/eyedid_flutter_calibration.dart';
import 'package:eyedid_flutter/eyedid_flutter.dart';

// GazePoint 클래스 정의
class GazePoint {
  final double x;
  final double y;
  final DateTime timestamp;

  GazePoint(this.x, this.y, this.timestamp);
}

// ReadingAnalysis 클래스 정의
// ReadingAnalysis 클래스 정의
class ReadingAnalysis {
  final List<String> paragraphs;
  final Map<int, List<GazePoint>> gazeDataPerParagraph = {};
  final DateTime startTime;
  late final List<GlobalKey> paragraphKeys;

  // 각 문단의 위치 정보를 저장할 리스트
  final List<Rect> paragraphRects = [];

  ReadingAnalysis(this.paragraphs) : startTime = DateTime.now() {
    paragraphKeys = List.generate(paragraphs.length, (_) => GlobalKey());
  }

  void addGazePoint(double x, double y) {
    final paragraphIndex = _findParagraphIndex(y);
    if (paragraphIndex != -1) {
      gazeDataPerParagraph.putIfAbsent(paragraphIndex, () => []);
      gazeDataPerParagraph[paragraphIndex]!
          .add(GazePoint(x, y, DateTime.now()));
    }
  }

  int _findParagraphIndex(double y) {
    for (int i = 0; i < paragraphRects.length; i++) {
      if (paragraphRects[i].top <= y && y <= paragraphRects[i].bottom) {
        return i;
      }
    }
    return -1;
  }

  double _calculateDwellTime(List<GazePoint> points) {
    if (points.isEmpty) return 0.0;
    final duration =
        points.last.timestamp.difference(points.first.timestamp).inMilliseconds;
    return duration / 1000.0; // 초 단위로 변환
  }

  double _calculateReadingLinearity(List<GazePoint> points) {
    if (points.length < 2) return 0.0;

    double linearityScore = 0.0;
    for (int i = 1; i < points.length; i++) {
      final dx = points[i].x - points[i - 1].x;
      if (dx > 0) {
        // 왼쪽에서 오른쪽으로의 움직임
        linearityScore += 1;
      }
    }
    return linearityScore / (points.length - 1);
  }

  double calculateReadingScore() {
    double score = 0.0;

    for (var entry in gazeDataPerParagraph.entries) {
      final dwellTime = _calculateDwellTime(entry.value);
      final linearity = _calculateReadingLinearity(entry.value);

      // 점수 계산 (각 항목을 50% 가중치로 적용)
      score += (dwellTime * 0.5 + linearity * 0.5);
    }

    // 정규화하여 0 ~ 100 범위로 변환
    double normalizedScore = (score / paragraphs.length) * 100;

    // 최대 100점으로 제한
    return normalizedScore.clamp(0, 100);
  }

  Future<void> calculateParagraphRects(BuildContext context) async {
    await Future.delayed(Duration(milliseconds: 100)); // UI가 완전히 렌더링될 때까지 대기
    paragraphRects.clear();
    for (var key in paragraphKeys) {
      final renderBox = key.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox != null) {
        final position = renderBox.localToGlobal(Offset.zero);
        final size = renderBox.size;
        paragraphRects.add(
            Rect.fromLTWH(position.dx, position.dy, size.width, size.height));
      }
    }
  }
}

class Eyedid extends StatefulWidget {
  const Eyedid({super.key});

  @override
  State<Eyedid> createState() => _EyedidState();
}

class _EyedidState extends State<Eyedid> {
  final _eyedidFlutterPlugin = EyedidFlutter();
  var _hasCameraPermission = false;
  var _isInitialied = false;
  final _licenseKey = "dev_mpqzcjezk4xvdj3662tnkawjlut1fzw4c4b2hvj0";
  var _version = 'Unknown';
  var _stateString = "IDLE";
  var _hasCameraPermissionString = "NO_GRANTED";
  var _trackingBtnText = "START TRACKING";
  var _showingGaze = false;
  var _isCaliMode = false;
  bool isReading = false;

  late ReadingAnalysis readingAnalysis;

  StreamSubscription<dynamic>? _trackingEventSubscription;
  StreamSubscription<dynamic>? _dropEventSubscription;
  StreamSubscription<dynamic>? _statusEventSubscription;
  StreamSubscription<dynamic>? _calibrationEventSubscription;

  var _x = 0.0, _y = 0.0;
  var _gazeColor = Colors.red;
  var _nextX = 0.0, _nextY = 0.0, _calibrationProgress = 0.0;

  @override
  void initState() {
    super.initState();
    readingAnalysis = ReadingAnalysis([
      "어느 여름날, 한 소년은 푸른 숲속에서 새소리를 들으며 걷고 있었다. 그는 자연의 신비로움에 감탄하며 발길을 멈추지 않았다.",
      "길을 걷던 중, 그는 조용한 시냇물을 발견했다. 물은 맑고 투명했으며, 햇살이 비치면 반짝거렸다. 소년은 물가에 앉아 자신의 발을 담그며 마음의 평화를 느꼈다.",
      "숲 속 깊은 곳에는 오래된 나무 한 그루가 서 있었다. 나무는 마치 이야기를 들려주는 듯했다. 소년은 나무 아래 앉아 바람에 흔들리는 나뭇잎 소리를 들으며 잠시 눈을 감았다.",
      "시간이 흐르자, 소년은 숲속의 친구들을 만났다. 작은 새들은 그의 어깨에 앉아 노래를 불렀고, 토끼와 다람쥐는 그의 곁에서 놀았다.",
      "해가 지고, 소년은 집으로 돌아갔다. 그는 숲에서의 하루를 떠올리며 미소 지었다. 자연이 준 선물은 그에게 평화와 행복을 가져다주었다.",
    ]);
    initPlatformState();
  }

  Future<void> checkCameraPermission() async {
    _hasCameraPermission = await _eyedidFlutterPlugin.checkCameraPermission();

    if (!_hasCameraPermission) {
      _hasCameraPermission =
          await _eyedidFlutterPlugin.requestCameraPermission();
    }

    if (!mounted) return;

    setState(() {
      _hasCameraPermissionString = _hasCameraPermission ? "granted" : "denied";
    });
  }

  Future<void> initPlatformState() async {
    await checkCameraPermission();
    if (_hasCameraPermission) {
      String platformVersion;
      try {
        platformVersion = await _eyedidFlutterPlugin.getPlatformVersion();
      } on PlatformException catch (error) {
        print(error);
        platformVersion = 'Failed to get platform version.';
      }

      if (!mounted) return;
      initEyedidPlugin();
      setState(() {
        _version = platformVersion;
      });

      // UI가 빌드된 후 문단 위치 계산
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await readingAnalysis.calculateParagraphRects(context);
      });
    }
  }

  Future<void> initEyedidPlugin() async {
    String requestInitGazeTracker = "failed Request";
    try {
      final options = GazeTrackerOptionsBuilder()
          .setPreset(CameraPreset.vga640x480)
          .setUseGazeFilter(true)
          .setUseBlink(false)
          .setUseUserStatus(false)
          .build();
      final result = await _eyedidFlutterPlugin.initGazeTracker(
          licenseKey: _licenseKey, options: options);
      var enable = false;
      var showGaze = false;
      if (result.result) {
        enable = true;
        listenEvents();
        _eyedidFlutterPlugin.startTracking();
      } else if (result.message == InitializedResult.isAlreadyAttempting ||
          result.message == InitializedResult.gazeTrackerAlreadyInitialized) {
        enable = true;
        listenEvents();
        final isTracking = await _eyedidFlutterPlugin.isTracking();
        if (isTracking) {
          showGaze = true;
        }
      }

      setState(() {
        _isInitialied = enable;
        _stateString = "${result.result} : (${result.message})";
        _showingGaze = showGaze;
      });
    } on PlatformException catch (e) {
      requestInitGazeTracker = "Occur PlatformException (${e.message})";
      setState(() {
        _stateString = requestInitGazeTracker;
      });
    }
  }

  void listenEvents() {
    _trackingEventSubscription?.cancel();
    _dropEventSubscription?.cancel();
    _statusEventSubscription?.cancel();
    _calibrationEventSubscription?.cancel();

    _trackingEventSubscription =
        _eyedidFlutterPlugin.getTrackingEvent().listen((event) {
      final info = MetricsInfo(event);
      if (info.gazeInfo.trackingState == TrackingState.success) {
        setState(() {
          _x = info.gazeInfo.gaze.x;
          _y = info.gazeInfo.gaze.y;
          _gazeColor = Colors.green;

          if (isReading) {
            readingAnalysis.addGazePoint(_x, _y);
          }
        });
      } else {
        setState(() {
          _gazeColor = Colors.red;
        });
      }
    });

    _dropEventSubscription =
        _eyedidFlutterPlugin.getDropEvent().listen((event) {
      final info = DropInfo(event);
      debugPrint("Dropped at timestamp: ${info.timestamp}");
    });

    _statusEventSubscription =
        _eyedidFlutterPlugin.getStatusEvent().listen((event) {
      final info = StatusInfo(event);
      if (info.type == StatusType.start) {
        setState(() {
          _stateString = "start Tracking";
          _showingGaze = true;
        });
      } else {
        setState(() {
          _stateString = "stop Tracking : ${info.errorType?.name}";
          _showingGaze = false;
        });
      }
    });

    _calibrationEventSubscription =
        _eyedidFlutterPlugin.getCalibrationEvent().listen((event) {
      final info = CalibrationInfo(event);
      if (info.type == CalibrationType.nextPoint) {
        setState(() {
          _nextX = info.next!.x;
          _nextY = info.next!.y;
          _calibrationProgress = 0.0;
        });
        Future.delayed(const Duration(milliseconds: 500), () {
          _eyedidFlutterPlugin.startCollectSamples();
        });
      } else if (info.type == CalibrationType.progress) {
        setState(() {
          _calibrationProgress = info.progress!;
        });
      } else if (info.type == CalibrationType.finished) {
        setState(() {
          _isCaliMode = false;
        });
      } else if (info.type == CalibrationType.canceled) {
        debugPrint("Calibration canceled ${info.data?.length}");
        setState(() {
          _isCaliMode = false;
        });
      }
    });
  }

  void _trackingBtnPressed() {
    if (_isInitialied) {
      if (_trackingBtnText == "START TRACKING") {
        try {
          _eyedidFlutterPlugin.startTracking();
          _trackingBtnText = "STOP TRACKING";
        } on PlatformException catch (e) {
          setState(() {
            _stateString = "Occur PlatformException (${e.message})";
          });
        }
      } else {
        try {
          _eyedidFlutterPlugin.stopTracking();
          _trackingBtnText = "START TRACKING";
        } on PlatformException catch (e) {
          setState(() {
            _stateString = "Occur PlatformException (${e.message})";
          });
        }
      }
      setState(() {
        _trackingBtnText = _trackingBtnText;
      });
    }
  }

  void _calibrationBtnPressed() {
    if (_isInitialied) {
      try {
        _eyedidFlutterPlugin.startCalibration(CalibrationMode.five,
            usePreviousCalibration: true);
        setState(() {
          _isCaliMode = true;
        });
      } on PlatformException catch (e) {
        setState(() {
          _stateString = "Occur PlatformException (${e.message})";
        });
      }
    }
  }

  void _startReadingAnalysis() {
    setState(() {
      if (!isReading) {
        // 읽기 시작
        isReading = true;
        readingAnalysis = ReadingAnalysis(readingAnalysis.paragraphs);
        // 문단 위치 다시 계산
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          await readingAnalysis.calculateParagraphRects(context);
        });
      } else {
        // 읽기 종료 및 분석
        final score = readingAnalysis.calculateReadingScore();
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('독해력 분석 결과'),
            content: Text('당신의 독해력 점수는 ${score.toInt()}점입니다.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('확인'),
              ),
            ],
          ),
        );
        isReading = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          if (!_isCaliMode)
            Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 40),
                    itemCount: readingAnalysis.paragraphs.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          readingAnalysis.paragraphs[index],
                          key: readingAnalysis
                              .paragraphKeys[index], // GlobalKey 할당
                          style: const TextStyle(fontSize: 18),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      if (_isInitialied)
                        ElevatedButton(
                          onPressed: _trackingBtnPressed,
                          child: Text(_trackingBtnText),
                        ),
                      if (_isInitialied && _showingGaze)
                        ElevatedButton(
                          onPressed: _calibrationBtnPressed,
                          child: const Text("시선 조정하기"),
                        ),
                      if (_showingGaze)
                        ElevatedButton(
                          onPressed: _startReadingAnalysis,
                          child: Text(isReading ? '분석하기' : '읽기 시작'),
                        ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text("뒤로가기"),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          if (_showingGaze && !_isCaliMode)
            Positioned(
              left: _x - 5,
              top: _y - 5,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: _gazeColor,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          if (_isCaliMode)
            Positioned(
              left: _nextX - 10,
              top: _nextY - 10,
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  value: _calibrationProgress,
                  backgroundColor: Colors.grey,
                  color: Colors.blue,
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // 모든 스트림 구독 해제
    _trackingEventSubscription?.cancel();
    _dropEventSubscription?.cancel();
    _statusEventSubscription?.cancel();
    _calibrationEventSubscription?.cancel();
    super.dispose();
  }
}
