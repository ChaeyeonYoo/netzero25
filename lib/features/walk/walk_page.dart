import 'package:flutter/material.dart';
import 'dart:async';
import '../shared/top_app_bar.dart';
import '../shared/bottom_nav_bar.dart';
import '../../app/routes.dart';
import '../../widgets/kakao_map_widget.dart';

class WalkPage extends StatefulWidget {
  const WalkPage({super.key});

  @override
  State<WalkPage> createState() => _WalkPageState();
}

class _WalkPageState extends State<WalkPage> {
  // 타이머 관련 변수
  Timer? _timer;
  int _elapsedSeconds = 0;
  bool _isRunning = false;
  bool _isPaused = false;

  // 산책 데이터
  double _distance = 0.0;
  int _carbonReduced = 0;

  // 지도 관련 변수
  static const double _initialLatitude = 37.5714; // 광화문 위도
  static const double _initialLongitude = 126.9769; // 광화문 경도

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    if (!_isRunning) {
      setState(() {
        _isRunning = true;
        _isPaused = false;
      });

      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          _elapsedSeconds++;
          // 거리와 탄소 감축량 계산 (예시)
          _distance = (_elapsedSeconds * 0.001).clamp(
            0.0,
            double.infinity,
          ); // 1초당 1m
          _carbonReduced = (_elapsedSeconds * 2).clamp(
            0,
            999999,
          ); // 1초당 2g 탄소 감축
        });
      });
    }
  }

  void _pauseTimer() {
    if (_isRunning && !_isPaused) {
      setState(() {
        _isPaused = true;
      });
      _timer?.cancel();
    } else if (_isRunning && _isPaused) {
      setState(() {
        _isPaused = false;
      });
      _startTimer();
    }
  }

  void _stopTimer() {
    setState(() {
      _isRunning = false;
      _isPaused = false;
      _elapsedSeconds = 0;
      _distance = 0.0;
      _carbonReduced = 0;
    });
    _timer?.cancel();
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TopAppBar(title: 'PetZero'),
      backgroundColor: const Color(0xFFE3F4D6),
      body: Stack(
        children: [
          // 카카오맵
          KakaoMapWidget(
            latitude: _initialLatitude,
            longitude: _initialLongitude,
            zoom: 16,
            showMyLocation: true,
          ),

          // 하단 정보 카드
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _InfoColumn(
                        title: '산책 거리',
                        value: _distance.toStringAsFixed(1),
                        unit: 'km',
                      ),
                      _InfoColumn(
                        title: '줄인 탄소',
                        value: _carbonReduced.toString(),
                        unit: 'g',
                      ),
                      _InfoColumn(
                        title: '시간',
                        value: _formatTime(_elapsedSeconds),
                        unit: '분',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _IconCircle(
                        icon:
                            _isRunning && !_isPaused
                                ? Icons.pause
                                : Icons.play_arrow,
                        onTap: _isRunning ? _pauseTimer : _startTimer,
                        color:
                            _isRunning && !_isPaused
                                ? Colors.orange
                                : Colors.green,
                      ),
                      const SizedBox(width: 20),
                      _IconCircle(
                        icon: Icons.stop,
                        onTap: _stopTimer,
                        color: Colors.red,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: 1,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.of(context).pushReplacementNamed(AppRoutes.home);
              break;
            case 1:
              // 산책 페이지는 이미 현재 페이지
              break;
            case 2:
              Navigator.of(context).pushReplacementNamed(AppRoutes.ranking);
              break;
            case 3:
              Navigator.of(context).pushReplacementNamed(AppRoutes.community);
              break;
          }
        },
      ),
    );
  }
}

class _InfoColumn extends StatelessWidget {
  final String title;
  final String value;
  final String unit;

  const _InfoColumn({
    required this.title,
    required this.value,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text('$title ($unit)', style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

class _IconCircle extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  const _IconCircle({
    required this.icon,
    required this.onTap,
    this.color = Colors.green,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Icon(icon, color: color),
      ),
    );
  }
}
