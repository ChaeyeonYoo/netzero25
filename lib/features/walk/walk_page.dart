import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../shared/top_app_bar.dart';
import '../shared/bottom_nav_bar.dart';
import '../../app/routes.dart';
import '../../widgets/google_map_widget.dart';
import '../../core/logger.dart';
import '../../models/store.dart';
import '../../services/store_service.dart';

// 배달 상태 enum
enum DeliveryStatus {
  none, // 배달 없음
  accepted, // 배달 수락됨
  pickedUp, // 픽업 완료
  completed, // 배달 완료
}

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

  // 맵 관련 변수
  bool _hasGoogleMapsApiKey = true; // API 키가 설정되어 있음
  bool _mapError = false;

  // 배달 관련 변수
  DeliveryStatus _deliveryStatus = DeliveryStatus.none;
  Store? _currentDelivery;
  Timer? _pickupTimer;
  int _pickupCountdown = 3; // 3초 카운트다운

  @override
  void initState() {
    super.initState();
    Logger.info('WalkPage 초기화 시작', context: 'WalkPage');
    _initializeWalkPage();
  }

  void _initializeWalkPage() {
    try {
      Logger.debug('산책 페이지 초기화 중...', context: 'WalkPage');
      // 초기화 로직
      Logger.info('WalkPage 초기화 완료', context: 'WalkPage');
    } catch (e, stackTrace) {
      Logger.error(
        'WalkPage 초기화 실패',
        context: 'WalkPage',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  void dispose() {
    Logger.info('WalkPage dispose 시작', context: 'WalkPage');
    _timer?.cancel();
    _pickupTimer?.cancel();
    Logger.info('WalkPage dispose 완료', context: 'WalkPage');
    super.dispose();
  }

  void _startTimer() {
    Logger.debug('타이머 시작', context: 'WalkPage');
    if (!_isRunning) {
      setState(() {
        _isRunning = true;
        _isPaused = false;
      });

      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          _elapsedSeconds++;
          // 거리와 탄소 감축량 계산 (더 현실적인 값)
          _distance = (_elapsedSeconds * 0.0014).clamp(
            0.0,
            double.infinity,
          ); // 1초당 약 1.4m (보행 속도)
          _carbonReduced = (_elapsedSeconds * 3).clamp(
            0,
            999999,
          ); // 1초당 3g 탄소 감축
        });
      });
      Logger.info('타이머 시작됨', context: 'WalkPage');
    }
  }

  void _pauseTimer() {
    Logger.debug('타이머 일시정지/재개', context: 'WalkPage');
    if (_isRunning && !_isPaused) {
      setState(() {
        _isPaused = true;
      });
      _timer?.cancel();
      Logger.info('타이머 일시정지됨', context: 'WalkPage');
    } else if (_isRunning && _isPaused) {
      setState(() {
        _isPaused = false;
      });
      _startTimer();
      Logger.info('타이머 재개됨', context: 'WalkPage');
    }
  }

  void _stopTimer() {
    Logger.debug('타이머 정지', context: 'WalkPage');
    setState(() {
      _isRunning = false;
      _isPaused = false;
      _elapsedSeconds = 0;
      _distance = 0.0;
      _carbonReduced = 0;
    });
    _timer?.cancel();
    Logger.info('타이머 정지됨', context: 'WalkPage');
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Widget _buildMapWidget() {
    if (!_hasGoogleMapsApiKey) {
      Logger.warning('Google Maps API 키가 설정되지 않음', context: 'WalkPage');
      return _buildMapErrorWidget('Google Maps API 키가 설정되지 않았습니다.');
    }

    if (_mapError) {
      Logger.error('지도 로딩 실패', context: 'WalkPage');
      return _buildMapErrorWidget('지도를 불러올 수 없습니다.');
    }

    try {
      Logger.debug('Google Maps 위젯 생성 중...', context: 'WalkPage');
      return GoogleMapWidget(
        latitude: 37.5665, // 서울 시청 좌표
        longitude: 126.9780,
        zoom: 15,
        showMyLocation: true,
        showStores: true, // 가게 표시 활성화
        onDeliveryAccepted: _acceptDelivery, // 배달 수락 콜백
      );
    } catch (e, stackTrace) {
      Logger.error(
        'Google Maps 위젯 생성 실패',
        context: 'WalkPage',
        error: e,
        stackTrace: stackTrace,
      );
      setState(() {
        _mapError = true;
      });
      return _buildMapErrorWidget('지도 초기화 중 오류가 발생했습니다.');
    }
  }

  Widget _buildMapErrorWidget(String message) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.map, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              '지도 오류',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // 배달 수락 처리
  void _acceptDelivery(Store store) {
    Logger.info('배달 수락: ${store.name}', context: 'WalkPage');

    // 실제 API 호출
    _acceptDeliveryRequest(store);
  }

  // 실제 배달 요청 수락 API 호출
  Future<void> _acceptDeliveryRequest(Store store) async {
    try {
      final storeService = StoreService.instance;
      final userId = 'user002'; // 실제로는 로그인된 사용자 ID 사용

      if (store.deliveryRequestId == null) {
        Logger.error('배달 요청 ID가 없습니다', context: 'WalkPage');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('배달 요청 정보가 없습니다.')));
        return;
      }

      final result = await storeService.acceptDeliveryRequest(
        store.deliveryRequestId!,
        userId,
      );

      Logger.info('배달 요청 수락 성공: $result', context: 'WalkPage');

      setState(() {
        _deliveryStatus = DeliveryStatus.accepted;
        _currentDelivery = store;
      });

      // 3초 후 자동 픽업 완료
      _startPickupCountdown();
    } catch (e, stackTrace) {
      Logger.error(
        '배달 요청 수락 실패',
        context: 'WalkPage',
        error: e,
        stackTrace: stackTrace,
      );
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('배달 요청 수락에 실패했습니다: $e')));
    }
  }

  // 픽업 카운트다운 시작
  void _startPickupCountdown() {
    _pickupCountdown = 3;
    _pickupTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _pickupCountdown--;
      });

      if (_pickupCountdown <= 0) {
        timer.cancel();
        _completePickup();
      }
    });
  }

  // 픽업 완료
  void _completePickup() {
    Logger.info('픽업 완료: ${_currentDelivery?.name}', context: 'WalkPage');
    setState(() {
      _deliveryStatus = DeliveryStatus.pickedUp;
    });
  }

  // 배달 완료
  void _completeDelivery() {
    Logger.info('배달 완료: ${_currentDelivery?.name}', context: 'WalkPage');
    _showImagePickerDialog();
  }

  // 이미지 선택 다이얼로그
  void _showImagePickerDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text('배달 완료 인증'),
            content: const Text('배달 완료를 인증하기 위해 사진을 촬영해주세요.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('취소'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.camera);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: const Text('카메라'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.gallery);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: const Text('갤러리'),
              ),
            ],
          ),
    );
  }

  // 이미지 선택
  Future<void> _pickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        Logger.info('이미지 선택됨: ${image.path}', context: 'WalkPage');
        _processDeliveryCompletion(File(image.path));
      } else {
        Logger.info('이미지 선택 취소됨', context: 'WalkPage');
      }
    } catch (e, stackTrace) {
      Logger.error(
        '이미지 선택 실패',
        context: 'WalkPage',
        error: e,
        stackTrace: stackTrace,
      );
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('이미지 선택에 실패했습니다.')));
    }
  }

  // 배달 완료 처리
  void _processDeliveryCompletion(File imageFile) {
    Logger.info('배달 완료 처리 시작', context: 'WalkPage');

    // 실제 API 호출
    _completeDeliveryRequest(imageFile);
  }

  // 실제 배달 완료 API 호출
  Future<void> _completeDeliveryRequest(File imageFile) async {
    try {
      final storeService = StoreService.instance;
      final userId = 'user002'; // 실제로는 로그인된 사용자 ID 사용

      if (_currentDelivery?.deliveryRequestId == null) {
        Logger.error('배달 요청 ID가 없습니다', context: 'WalkPage');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('배달 요청 정보가 없습니다.')));
        return;
      }

      // TODO: 이미지를 서버에 업로드하고 URL을 받아오는 로직
      // 현재는 임시로 로컬 파일 경로 사용
      final photoUrl = imageFile.path;

      final result = await storeService.completeDelivery(
        _currentDelivery!.deliveryRequestId!,
        userId,
        photoUrl,
      );

      Logger.info('배달 완료 성공: $result', context: 'WalkPage');

      setState(() {
        _deliveryStatus = DeliveryStatus.completed;
      });

      // 배달 완료 팝업 표시
      _showDeliveryCompletedDialog();
    } catch (e, stackTrace) {
      Logger.error(
        '배달 완료 실패',
        context: 'WalkPage',
        error: e,
        stackTrace: stackTrace,
      );
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('배달 완료에 실패했습니다: $e')));
    }
  }

  // 배달 완료 팝업
  void _showDeliveryCompletedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 24),
                const SizedBox(width: 8),
                const Text('배달 완료!'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('${_currentDelivery?.name}'),
                const SizedBox(height: 8),
                const Text('배달이 성공적으로 완료되었습니다!'),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.emoji_events,
                        color: Colors.green.shade600,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '배달 완료 인증됨',
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text('수고하셨습니다! 🎉'),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _resetDelivery();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('확인'),
              ),
            ],
          ),
    );
  }

  // 배달 상태 리셋
  void _resetDelivery() {
    setState(() {
      _deliveryStatus = DeliveryStatus.none;
      _currentDelivery = null;
      _pickupCountdown = 3;
    });
    _pickupTimer?.cancel();
  }

  // 배달 상태 텍스트 반환
  String _getDeliveryStatusText() {
    switch (_deliveryStatus) {
      case DeliveryStatus.accepted:
        return '배달 수락됨 - 픽업해주세요';
      case DeliveryStatus.pickedUp:
        return '픽업 완료 - 배달해주세요';
      case DeliveryStatus.completed:
        return '배달 완료';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    Logger.debug('WalkPage build 호출', context: 'WalkPage');

    return Scaffold(
      appBar: const TopAppBar(title: 'PetZero'),
      backgroundColor: const Color(0xFFE3F4D6),
      body: Stack(
        children: [
          // 지도 위젯
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(color: Colors.grey.shade200),
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: _buildMapWidget(),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 하단 정보 카드
          Align(
            alignment: Alignment.bottomCenter,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 배달 상태 표시
                if (_deliveryStatus != DeliveryStatus.none) ...[
                  Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Image.asset(
                          'assets/images/store.png',
                          width: 32,
                          height: 32,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _currentDelivery?.name ?? '',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _getDeliveryStatusText(),
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (_deliveryStatus == DeliveryStatus.accepted) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade100,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              '$_pickupCountdown초',
                              style: TextStyle(
                                color: Colors.orange.shade700,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ] else if (_deliveryStatus ==
                            DeliveryStatus.pickedUp) ...[
                          ElevatedButton(
                            onPressed: _completeDelivery,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text('배달 완료'),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],

                // 기존 하단 정보 카드
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 24,
                  ),
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
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: 1,
        onTap: (index) {
          Logger.debug('탭 변경: $index', context: 'WalkPage');
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
