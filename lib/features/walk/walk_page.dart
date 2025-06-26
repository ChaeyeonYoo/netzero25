import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import '../shared/top_app_bar.dart';
import '../shared/bottom_nav_bar.dart';
import '../../app/routes.dart';
import '../../utils/logger.dart';

// Google Maps API 키가 설정되어 있을 때만 import
// import 'package:google_maps_flutter/google_maps_flutter.dart';

class WalkPage extends StatefulWidget {
  const WalkPage({super.key});

  @override
  State<WalkPage> createState() => _WalkPageState();
}

class _WalkPageState extends State<WalkPage> {
  @override
  void initState() {
    super.initState();
    Logger.lifecycle('WalkPage', 'initState started');
    Logger.info('Google Maps API key configured: $_hasGoogleMapsApiKey');
    Logger.debug('Initial position: $_initialPosition');
  }
  // 타이머 관련 변수
  Timer? _timer;
  int _elapsedSeconds = 0;
  bool _isRunning = false;
  bool _isPaused = false;

  // 산책 데이터
  double _distance = 0.0;
  int _carbonReduced = 0;

  // Google Maps 관련 변수
  GoogleMapController? _mapController;
  static const LatLng _initialPosition = LatLng(37.5714, 126.9769); // 광화문 좌표

  // Google Maps API 키 설정 여부 확인
  static const bool _hasGoogleMapsApiKey = true; // API key is configured in iOS/Android native code

  @override
  void dispose() {
    Logger.lifecycle('WalkPage', 'dispose started');
    _timer?.cancel();
    Logger.debug('Timer cancelled');
    super.dispose();
    Logger.lifecycle('WalkPage', 'dispose completed');
  }

  void _startTimer() {
    Logger.debug('_startTimer called');
    if (!_isRunning) {
      Logger.info('Starting walk timer');
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
    Logger.debug('_pauseTimer called');
    if (_isRunning && !_isPaused) {
      Logger.info('Pausing walk timer');
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
    Logger.debug('_stopTimer called');
    Logger.info('Stopping walk timer - Distance: $_distance km, Carbon reduced: $_carbonReduced g');
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
    Logger.lifecycle('WalkPage', 'build method called');
    
    try {
      return Scaffold(
      appBar: const TopAppBar(title: 'PetZero'),
      backgroundColor: const Color(0xFFE3F4D6),
      body: Stack(
        children: [
          // Google Maps with error handling
          _buildMapWidget(),

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
              Logger.navigation('Navigating to Home', from: 'Walk', to: 'Home');
              Navigator.of(context).pushReplacementNamed(AppRoutes.home);
              break;
            case 1:
              Logger.debug('Already on Walk page');
              break;
            case 2:
              Logger.navigation('Navigating to Ranking', from: 'Walk', to: 'Ranking');
              Navigator.of(context).pushReplacementNamed(AppRoutes.ranking);
              break;
            case 3:
              Logger.navigation('Navigating to Community', from: 'Walk', to: 'Community');
              Navigator.of(context).pushReplacementNamed(AppRoutes.community);
              break;
          }
        },
      ),
    );
    } catch (e, stackTrace) {
      Logger.error('Error building WalkPage', error: e, stackTrace: stackTrace);
      return Scaffold(
        appBar: const TopAppBar(title: 'PetZero'),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('산책 페이지를 불러올 수 없습니다.\n$e'),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildMapWidget() {
    try {
      Logger.debug('Building Google Map widget');
      return GoogleMap(
        onMapCreated: (controller) {
          Logger.info('Google Map created');
          try {
            _mapController = controller;
            Logger.debug('Map controller assigned successfully');
          } catch (e, stackTrace) {
            Logger.error('Failed to assign map controller', error: e, stackTrace: stackTrace);
          }
        },
        initialCameraPosition: const CameraPosition(
          target: _initialPosition,
          zoom: 16,
        ),
        myLocationEnabled: true,
        myLocationButtonEnabled: false,
        zoomControlsEnabled: false,
        markers: _createMarkers(),
      );
    } catch (e, stackTrace) {
      Logger.error('Failed to build Google Map widget', error: e, stackTrace: stackTrace);
      return Container(
        color: Colors.grey[300],
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.map, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                '지도를 불러올 수 없습니다',
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 8),
              Text(
                '오류: $e',
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }
  }

  Set<Marker> _createMarkers() {
    return {
      // 쓰레기통 마커들
      Marker(
        markerId: const MarkerId('trash_bin_1'),
        position: const LatLng(37.5722, 126.9769),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: const InfoWindow(title: '쓰레기통', snippet: '배변봉투 버리기'),
      ),
      Marker(
        markerId: const MarkerId('trash_bin_2'),
        position: const LatLng(37.5710, 126.9775),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: const InfoWindow(title: '쓰레기통', snippet: '배변봉투 버리기'),
      ),
      Marker(
        markerId: const MarkerId('trash_bin_3'),
        position: const LatLng(37.5700, 126.9760),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: const InfoWindow(title: '쓰레기통', snippet: '배변봉투 버리기'),
      ),
    };
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
