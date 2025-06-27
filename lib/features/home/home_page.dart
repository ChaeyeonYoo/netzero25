import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../shared/top_app_bar.dart';
import '../shared/bottom_nav_bar.dart';
import '../../widgets/record_popup.dart';
import '../../app/routes.dart';
import '../../services/score_service.dart';
import '../../core/logger.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late ScoreService _scoreService;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    Logger.info('HomePage 초기화 시작', context: 'HomePage');
    _initializeScoreService();
  }

  Future<void> _initializeScoreService() async {
    try {
      _scoreService = ScoreService.instance;
      await _scoreService.initialize();
      setState(() {
        _isLoading = false;
      });
      Logger.info('HomePage 초기화 완료', context: 'HomePage');
    } catch (e, stackTrace) {
      Logger.error(
        'HomePage 초기화 실패',
        context: 'HomePage',
        error: e,
        stackTrace: stackTrace,
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _refreshScore() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Logger.debug('HomePage build 호출', context: 'HomePage');

    if (_isLoading) {
      return Scaffold(
        appBar: const TopAppBar(title: 'PetZero'),
        backgroundColor: const Color(0xFFE3F4D6),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final scoreSystem = _scoreService.scoreSystem;
    final ringColor = scoreSystem.getRingColor();
    final progressPercent = scoreSystem.progressPercent;

    return Scaffold(
      appBar: const TopAppBar(title: 'PetZero'),
      backgroundColor: const Color(0xFFE3F4D6), // 연초록 배경
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircularPercentIndicator(
                radius: 60.0,
                lineWidth: 12.0,
                percent: progressPercent,
                center: Image.asset('assets/images/foot.png', width: 70),
                progressColor: ringColor,
                backgroundColor: Colors.white,
                circularStrokeCap: CircularStrokeCap.round,
              ),
              const SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    scoreSystem.getCurrentStatus(),
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${scoreSystem.currentPoints}점 / 100점",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    scoreSystem.getPointsToNextLevelText(),
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "배변 기록: ${scoreSystem.totalPoopRecords}회",
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Text(
                    "총 탄소 점수: ${scoreSystem.totalCarbonScore.toStringAsFixed(1)}점",
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),

          // 레벨업 알림 (레벨 1 이상일 때)
          if (scoreSystem.currentLevel > 1) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.green.shade300),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.star, color: Colors.green.shade700, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    "레벨 ${scoreSystem.currentLevel} 달성!",
                    style: TextStyle(
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // 캐릭터 이미지
          Image.asset('assets/images/dog.png', width: 180),

          // 기록하기 버튼
          ElevatedButton.icon(
            onPressed: () {
              showDialog(
                context: context,
                builder:
                    (context) => buildRecordPopup(
                      context,
                      onRecordComplete: _refreshScore,
                    ),
              );
            },
            icon: const Icon(Icons.camera_alt, color: Colors.white, size: 30),
            label: const Text(
              '기록하기',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shadowColor: Colors.green.shade200,
              elevation: 6,
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: 0,
        onTap: (index) {
          switch (index) {
            case 0:
              // 홈 페이지는 이미 현재 페이지
              break;
            case 1:
              Navigator.of(context).pushReplacementNamed(AppRoutes.walk);
              break;
            case 2:
              Navigator.of(context).pushNamed(AppRoutes.ranking);
              break;
            case 3:
              Navigator.of(context).pushNamed(AppRoutes.community);
              break;
          }
        },
      ),
    );
  }
}
