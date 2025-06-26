import 'package:flutter/material.dart';
import '../shared/top_app_bar.dart';
import '../shared/bottom_nav_bar.dart';
import '../../app/routes.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  int _selectedCategory = 0; // 0: 전체, 1: 자랑, 2: 질문, 3: 정보공유

  final List<Map<String, dynamic>> _posts = [
    {
      'id': 1,
      'title': '우리 강아지가 오늘도 열심히 산책했어요! 🐕',
      'content': '오늘도 30분 산책하면서 탄소 감축에 기여했어요. 다들 화이팅!',
      'author': '김철수',
      'avatar': '🐕',
      'likes': 24,
      'comments': 8,
      'time': '2시간 전',
      'category': '자랑',
      'image': 'assets/images/walkwithdog.png',
    },
    {
      'id': 2,
      'title': '고양이 배변 관리 꿀팁 공유해요 😺',
      'content': '친환경 모래 사용법과 배변 패턴 관찰하는 방법을 알려드릴게요.',
      'author': '이영희',
      'avatar': '🐱',
      'likes': 15,
      'comments': 12,
      'time': '5시간 전',
      'category': '정보공유',
      'image': null,
    },
    {
      'id': 3,
      'title': '반려동물 음식 추천 부탁드려요',
      'content': '환경 친화적인 반려동물 음식을 찾고 있는데 추천해주세요!',
      'author': '박민수',
      'avatar': '🐶',
      'likes': 8,
      'comments': 15,
      'time': '1일 전',
      'category': '질문',
      'image': null,
    },
    {
      'id': 4,
      'title': '오늘의 산책 기록 📸',
      'content': '공원에서 만난 친구들과 함께 찍은 사진이에요.',
      'author': '최지영',
      'avatar': '🐕',
      'likes': 31,
      'comments': 6,
      'time': '1일 전',
      'category': '자랑',
      'image': 'assets/images/walkwithdog2.jpeg',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TopAppBar(title: 'PetZero'),
      backgroundColor: const Color(0xFFE3F4D6),
      body: Column(
        children: [
          // 카테고리 탭
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
                _buildCategoryTab('전체', 0),
                _buildCategoryTab('자랑', 1),
                _buildCategoryTab('질문', 2),
                _buildCategoryTab('정보공유', 3),
              ],
            ),
          ),

          // 게시글 목록
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _getFilteredPosts().length,
              itemBuilder: (context, index) {
                final post = _getFilteredPosts()[index];
                return _buildPostCard(post);
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: 3,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.of(context).pushReplacementNamed(AppRoutes.home);
              break;
            case 1:
              Navigator.of(context).pushReplacementNamed(AppRoutes.walk);
              break;
            case 2:
              Navigator.of(context).pushReplacementNamed(AppRoutes.ranking);
              break;
            case 3:
              // 커뮤니티 페이지는 이미 현재 페이지
              break;
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showWritePostDialog();
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  List<Map<String, dynamic>> _getFilteredPosts() {
    if (_selectedCategory == 0) {
      return _posts;
    }

    final categoryMap = {1: '자랑', 2: '질문', 3: '정보공유'};

    return _posts
        .where((post) => post['category'] == categoryMap[_selectedCategory])
        .toList();
  }

  Widget _buildCategoryTab(String label, int index) {
    final isSelected = _selectedCategory == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedCategory = index;
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
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPostCard(Map<String, dynamic> post) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더
            Row(
              children: [
                Text(post['avatar'], style: const TextStyle(fontSize: 24)),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post['author'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        post['time'],
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getCategoryColor(post['category']),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    post['category'],
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // 제목
            Text(
              post['title'],
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),

            const SizedBox(height: 8),

            // 내용
            Text(
              post['content'],
              style: TextStyle(color: Colors.grey[700], fontSize: 14),
            ),

            // 이미지 (있는 경우)
            if (post['image'] != null) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  post['image'],
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
            ],

            const SizedBox(height: 12),

            // 액션 버튼
            Row(
              children: [
                _buildActionButton(
                  icon: Icons.favorite_border,
                  label: '${post['likes']}',
                  onTap: () {
                    // 좋아요 기능
                  },
                ),
                const SizedBox(width: 16),
                _buildActionButton(
                  icon: Icons.comment_outlined,
                  label: '${post['comments']}',
                  onTap: () {
                    // 댓글 기능
                  },
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {
                    // 공유 기능
                  },
                  icon: const Icon(Icons.share, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: Colors.grey, size: 20),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case '자랑':
        return Colors.orange;
      case '질문':
        return Colors.blue;
      case '정보공유':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  void _showWritePostDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('새 게시글 작성'),
            content: const Text('게시글 작성 기능은 추후 구현 예정입니다.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('확인'),
              ),
            ],
          ),
    );
  }
}
