import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../shared/top_app_bar.dart';
import '../shared/bottom_nav_bar.dart';
import '../../widgets/record_popup.dart';
import '../../app/routes.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
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
                percent: 0.81,
                center: Image.asset('assets/images/foot.png', width: 70),
                progressColor: Colors.green,
                backgroundColor: Colors.white,
                circularStrokeCap: CircularStrokeCap.round,
              ),
              const SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text("현재 탄소 감축량", style: TextStyle(fontSize: 14)),
                  SizedBox(height: 4),
                  Text(
                    "0.81 kg 하루(일)",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text("목표까지 0.19 kg", style: TextStyle(fontSize: 14)),
                ],
              ),
            ],
          ),

          // 캐릭터 이미지
          Image.asset('assets/images/dog.png', width: 180),

          // 기록하기 버튼
          ElevatedButton.icon(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => buildRecordPopup(context),
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
