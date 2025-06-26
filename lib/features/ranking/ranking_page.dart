import 'package:flutter/material.dart';
import '../shared/top_app_bar.dart';
import '../shared/bottom_nav_bar.dart';
import '../../app/routes.dart';

class RankingPage extends StatefulWidget {
  const RankingPage({super.key});

  @override
  State<RankingPage> createState() => _RankingPageState();
}

class _RankingPageState extends State<RankingPage> {
  int _selectedPeriod = 0; // 0: 일간, 1: 주간, 2: 월간

  final List<Map<String, dynamic>> _rankingData = [
    {
      'rank': 1,
      'name': '멍멍이',
      'owner': '김철수',
      'score': 1250,
      'avatar': '🐕',
      'isMyPet': false,
    },
    {
      'rank': 2,
      'name': '냥냥이',
      'owner': '이영희',
      'score': 1180,
      'avatar': '🐱',
      'isMyPet': true,
    },
    {
      'rank': 3,
      'name': '토토',
      'owner': '박민수',
      'score': 1120,
      'avatar': '🐶',
      'isMyPet': false,
    },
    {
      'rank': 4,
      'name': '루시',
      'owner': '최지영',
      'score': 1050,
      'avatar': '🐕',
      'isMyPet': false,
    },
    {
      'rank': 5,
      'name': '미미',
      'owner': '정수진',
      'score': 980,
      'avatar': '🐱',
      'isMyPet': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TopAppBar(title: 'PetZero'),
      backgroundColor: const Color(0xFFE3F4D6),
      body: Column(
        children: [
          // 기간 선택 탭
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                _buildPeriodTab('일간', 0),
                _buildPeriodTab('주간', 1),
                _buildPeriodTab('월간', 2),
              ],
            ),
          ),

          // 내 반려동물 순위 카드
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.shade300, width: 2),
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: const Center(
                    child: Text('🐱', style: TextStyle(fontSize: 24)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '내 반려동물',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      const Text(
                        '냥냥이 (이영희)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    '2위',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 랭킹 리스트
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _rankingData.length,
                itemBuilder: (context, index) {
                  final item = _rankingData[index];
                  return _buildRankingItem(item, index);
                },
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: 2,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.of(context).pushReplacementNamed(AppRoutes.home);
              break;
            case 1:
              Navigator.of(context).pushReplacementNamed(AppRoutes.walk);
              break;
            case 2:
              // 랭킹 페이지는 이미 현재 페이지
              break;
            case 3:
              Navigator.of(context).pushReplacementNamed(AppRoutes.community);
              break;
          }
        },
      ),
    );
  }

  Widget _buildPeriodTab(String label, int index) {
    final isSelected = _selectedPeriod == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedPeriod = index;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.green : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRankingItem(Map<String, dynamic> item, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: item['isMyPet'] ? Colors.green.shade50 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border:
            item['isMyPet']
                ? Border.all(color: Colors.green.shade200, width: 1)
                : null,
      ),
      child: Row(
        children: [
          // 순위
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: _getRankColor(item['rank']),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${item['rank']}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // 아바타
          Text(item['avatar'], style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),

          // 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${item['name']} (${item['owner']})',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  '${item['score']}점',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ],
            ),
          ),

          // 내 반려동물 표시
          if (item['isMyPet'])
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                '내 반려동물',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber;
      case 2:
        return Colors.grey;
      case 3:
        return Colors.brown;
      default:
        return Colors.green;
    }
  }
}
