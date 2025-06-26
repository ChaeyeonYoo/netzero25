import 'package:flutter/material.dart';
import 'package:petzero/features/shared/top_app_bar.dart';
import 'package:camera/camera.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../services/ai_service.dart';
import '../shared/bottom_nav_bar.dart';
import '../../app/routes.dart';

enum RecordType {
  poop, // 배설 기록
  food, // 음식 기록
}

class CameraPage extends StatefulWidget {
  final RecordType recordType;

  const CameraPage({super.key, required this.recordType});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  late CameraController _cameraController;
  bool _isCameraInitialized = false;
  bool _isAnalyzing = false;
  Map<String, dynamic>? _analysisResult;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    if (cameras.isNotEmpty) {
      _cameraController = CameraController(cameras[0], ResolutionPreset.high);

      try {
        await _cameraController.initialize();
        setState(() {
          _isCameraInitialized = true;
        });
      } catch (e) {
        print('카메라 초기화 실패: $e');
      }
    }
  }

  Future<void> _takePicture() async {
    if (!_isCameraInitialized) return;

    try {
      final XFile image = await _cameraController.takePicture();
      await _analyzeImage(File(image.path));
    } catch (e) {
      _showErrorDialog('사진 촬영 실패: $e');
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        await _analyzeImage(File(image.path));
      }
    } catch (e) {
      _showErrorDialog('갤러리에서 이미지 선택 실패: $e');
    }
  }

  Future<void> _analyzeImage(File imageFile) async {
    setState(() {
      _isAnalyzing = true;
      _analysisResult = null;
    });

    try {
      Map<String, dynamic> result;

      if (widget.recordType == RecordType.poop) {
        result = await AiService.analyzePoop(imageFile);
      } else {
        result = await AiService.analyzeFood(imageFile);
      }

      setState(() {
        _analysisResult = result;
        _isAnalyzing = false;
      });

      _showAnalysisResult(result);
    } catch (e) {
      setState(() {
        _isAnalyzing = false;
      });
      _showErrorDialog('AI 분석 실패: $e');
    }
  }

  void _showAnalysisResult(Map<String, dynamic> result) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(_getTitle()),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('분석 결과:', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                ...result.entries
                    .map(
                      (entry) => Padding(
                        padding: EdgeInsets.symmetric(vertical: 2),
                        child: Text('${entry.key}: ${entry.value}'),
                      ),
                    )
                    .toList(),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('확인'),
              ),
            ],
          ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('오류'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('확인'),
              ),
            ],
          ),
    );
  }

  void _toggleCamera() async {
    if (!_isCameraInitialized) return;

    final cameras = await availableCameras();
    final currentIndex = cameras.indexOf(_cameraController.description);
    final nextIndex = (currentIndex + 1) % cameras.length;

    await _cameraController.dispose();
    _cameraController = CameraController(
      cameras[nextIndex],
      ResolutionPreset.high,
    );

    try {
      await _cameraController.initialize();
      setState(() {});
    } catch (e) {
      print('카메라 전환 실패: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TopAppBar(title: 'PetZero'),
      backgroundColor: const Color(0xFFE3F4D6),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 20),
                    width: double.infinity,
                    child:
                        _isCameraInitialized
                            ? CameraPreview(_cameraController)
                            : const Center(child: CircularProgressIndicator()),
                  ),
                ),
                // 뒤로 가기 버튼
                Positioned(
                  top: 20,
                  left: 20,
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
                // 분석 중 로딩 표시
                if (_isAnalyzing)
                  Container(
                    color: Colors.black.withOpacity(0.5),
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(color: Colors.white),
                          SizedBox(height: 16),
                          Text(
                            'AI 분석 중...',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: _isAnalyzing ? null : _pickFromGallery,
                  child: CircleAvatar(
                    radius: 26,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.image,
                      color: _isAnalyzing ? Colors.grey : Colors.green.shade700,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: _isAnalyzing ? null : _takePicture,
                  child: CircleAvatar(
                    radius: 32,
                    backgroundColor: _isAnalyzing ? Colors.grey : Colors.green,
                    child: Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: _isAnalyzing ? null : _toggleCamera,
                  child: CircleAvatar(
                    radius: 26,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.cameraswitch,
                      color: _isAnalyzing ? Colors.grey : Colors.green.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: 0,
        onTap: (index) {
          // 네비게이션 처리
        },
      ),
    );
  }

  String _getTitle() {
    switch (widget.recordType) {
      case RecordType.poop:
        return '배변 기록';
      case RecordType.food:
        return '음식 기록';
    }
  }
}
