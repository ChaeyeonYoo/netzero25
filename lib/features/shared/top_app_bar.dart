import 'package:flutter/material.dart';

class TopAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onMyPressed;
  final VoidCallback? onBadgePressed;
  final VoidCallback? onNotificationPressed;

  const TopAppBar({
    super.key,
    required this.title,
    this.onMyPressed,
    this.onBadgePressed,
    this.onNotificationPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      elevation: 1,
      automaticallyImplyLeading: false, // 기본 leading 제거

      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 좌측 MY 버튼
          GestureDetector(
            onTap: onMyPressed,
            child: Image.asset("assets/images/mybtn.png", width: 50),
          ),

          // 우측 뱃지 & 알림
          Row(
            children: [
              GestureDetector(
                onTap: onBadgePressed,
                child: Image.asset("assets/images/badgebtn.png", width: 40),
              ),
              const SizedBox(width: 8), // 간격 좁게 조절
              GestureDetector(
                onTap: onNotificationPressed,
                child: Image.asset("assets/images/alertbtn.png", width: 40),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56);
}
