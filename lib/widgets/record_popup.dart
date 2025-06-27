import 'package:flutter/material.dart';
import '../features/camera/camera_page.dart';
import '../app/routes.dart';

Widget buildRecordPopup(
  BuildContext context, {
  VoidCallback? onRecordComplete,
}) {
  return AlertDialog(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    titlePadding: const EdgeInsets.only(top: 16, left: 16, right: 8),
    title: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Spacer(),
        const Expanded(
          flex: 10,
          child: Text(
            '무엇을 기록하시겠습니까?',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    ),
    content: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildRecordButton(
          icon: Icons.delete,
          label: '배변 기록',
          onTap: () {
            Navigator.of(context).pop();
            Navigator.of(context).push(
              MaterialPageRoute(
                builder:
                    (context) => CameraPage(
                      recordType: RecordType.poop,
                      onRecordComplete: onRecordComplete,
                    ),
              ),
            );
          },
        ),
        const SizedBox(width: 24),
        _buildRecordButton(
          icon: Icons.restaurant,
          label: '음식 기록',
          onTap: () {
            Navigator.of(context).pop();
            Navigator.of(context).push(
              MaterialPageRoute(
                builder:
                    (context) => CameraPage(
                      recordType: RecordType.food,
                      onRecordComplete: onRecordComplete,
                    ),
              ),
            );
          },
        ),
      ],
    ),
  );
}

Widget _buildRecordButton({
  required IconData icon,
  required String label,
  required VoidCallback onTap,
}) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(40),
        child: CircleAvatar(
          radius: 30,
          backgroundColor: Colors.green,
          child: Icon(icon, color: Colors.white, size: 30),
        ),
      ),
      const SizedBox(height: 8),
      Text(label, style: const TextStyle(fontSize: 14)),
    ],
  );
}
