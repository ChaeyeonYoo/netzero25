import 'package:flutter/material.dart';
import '../../utils/logger.dart';

class BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const BottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: Color.fromARGB(255, 255, 255, 255),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildTabItem(icon: Icons.home, label: '홈', index: 0),
          _buildTabItem(icon: Icons.directions_walk, label: '산책', index: 1),
          _buildTabItem(icon: Icons.emoji_events, label: '랭킹', index: 2),
          _buildTabItem(icon: Icons.forum, label: '커뮤니티', index: 3),
        ],
      ),
    );
  }

  Widget _buildTabItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = index == selectedIndex;

    return GestureDetector(
      onTap: () {
        Logger.navigation(
          'Tab tapped',
          from: _getTabName(selectedIndex),
          to: _getTabName(index),
        );
        Logger.debug('Navigation index changed from $selectedIndex to $index');
        onTap(index);
      },
      behavior: HitTestBehavior.translucent,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isSelected ? Colors.white : Colors.grey),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getTabName(int index) {
    switch (index) {
      case 0:
        return '홈';
      case 1:
        return '산책';
      case 2:
        return '랭킹';
      case 3:
        return '커뮤니티';
      default:
        return 'Unknown';
    }
  }
}
