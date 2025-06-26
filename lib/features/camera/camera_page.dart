import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:petzero/features/shared/top_app_bar.dart';
import 'package:camera/camera.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../services/ai_service.dart';
import '../shared/bottom_nav_bar.dart';
import '../../app/routes.dart';
import '../../models/ai_analysis_result.dart';

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
  AiAnalysisResult? _analysisResult;
  File? _selectedImageFile;

  // AI 테스트용 이미지 목록
  final List<String> _aiTestImages = [
    'assets/images/aiImage/19.jpeg',
    'assets/images/aiImage/3.jpg',
    'assets/images/aiImage/12.jpg',
    'assets/images/aiImage/KakaoTalk_20250624_122038721_01.jpg',
  ];

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
      setState(() {
        _selectedImageFile = File(image.path);
      });
      await _analyzeImage(File(image.path));
    } catch (e) {
      _showErrorDialog('사진 촬영 실패: $e');
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImageFile = File(image.path);
        });
        await _analyzeImage(File(image.path));
      }
    } catch (e) {
      _showErrorDialog('갤러리에서 이미지 선택 실패: $e');
    }
  }

  void _showAiTestImageSelector() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('AI 테스트 이미지 선택'),
            content: Container(
              width: double.maxFinite,
              height: 400,
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: _aiTestImages.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () async {
                      Navigator.of(context).pop();
                      await _selectAiTestImage(_aiTestImages[index]);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(7),
                        child: Image.asset(
                          _aiTestImages[index],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey.shade200,
                              child: Icon(
                                Icons.error,
                                color: Colors.grey.shade600,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('취소'),
              ),
            ],
          ),
    );
  }

  Future<void> _selectAiTestImage(String imagePath) async {
    try {
      // assets 이미지를 임시 파일로 복사
      final tempDir = Directory.systemTemp;
      final tempFile = File(
        '${tempDir.path}/ai_test_image_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      // assets 이미지를 바이트로 읽어서 임시 파일에 저장
      final ByteData data = await DefaultAssetBundle.of(
        context,
      ).load(imagePath);
      final List<int> bytes = data.buffer.asUint8List();
      await tempFile.writeAsBytes(bytes);

      setState(() {
        _selectedImageFile = tempFile;
      });

      await _analyzeImage(tempFile);
    } catch (e) {
      _showErrorDialog('AI 테스트 이미지 선택 실패: $e');
    }
  }

  Future<void> _analyzeImage(File imageFile) async {
    setState(() {
      _isAnalyzing = true;
      _analysisResult = null;
    });

    try {
      print('이미지 분석 시작: ${imageFile.path}');
      print('파일 크기: ${await imageFile.length()} bytes');
      print('파일 존재 여부: ${await imageFile.exists()}');

      AiAnalysisResult result;

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

  void _showAnalysisResult(AiAnalysisResult result) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(_getTitle()),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_selectedImageFile != null) ...[
                    Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          _selectedImageFile!,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                  ],
                  Text(
                    '분석 결과:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  if (result.success) ...[
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 음식 분석인 경우 특별한 표시
                          if (widget.recordType == RecordType.food) ...[
                            // 디버깅 로그 추가
                            Builder(
                              builder: (context) {
                                print('음식 분석 디버깅:');
                                print(
                                  '- 탄소 배출량: ${result.carbonEmissionsKg}kg',
                                );
                                print('- 탄소 점수: ${result.carbonScore}점');
                                print('- 원본 메시지: ${result.message}');
                                return SizedBox.shrink();
                              },
                            ),
                            Text(
                              '음식 탄소 분석 결과',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.green.shade800,
                              ),
                            ),
                            SizedBox(height: 8),
                            Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: Colors.blue.shade200),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Builder(
                                    builder: (context) {
                                      final emissions =
                                          result.carbonEmissionsKg;
                                      final score = result.carbonScore;
                                      print('화면 표시 값:');
                                      print('- 탄소 배출량: $emissions');
                                      print('- 탄소 점수: $score');
                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '탄소 배출량: ${emissions.toStringAsFixed(1)}kg CO2e',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.blue.shade700,
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            '탄소 점수: ${score}점',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: Colors.orange.shade700,
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 8),
                          ] else ...[
                            // 배변 분석인 경우 기존 표시
                            // 점수 표시
                            if (result.score > 0) ...[
                              Text(
                                '점수: ${result.score}점',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.orange.shade700,
                                ),
                              ),
                              SizedBox(height: 4),
                            ],
                            // 탄소 배출 감소량 표시
                            if (result.avoidedEmissionsGram > 0) ...[
                              Text(
                                '탄소 배출 감소: ${result.avoidedEmissionsGram.toStringAsFixed(1)}g',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.blue.shade700,
                                ),
                              ),
                              SizedBox(height: 4),
                            ],
                          ],
                        ],
                      ),
                    ),
                  ] else ...[
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Text(
                        '분석 실패: ${result.error ?? '알 수 없는 오류'}',
                        style: TextStyle(color: Colors.red.shade800),
                      ),
                    ),
                  ],
                ],
              ),
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
          // 선택된 이미지 표시 영역
          if (_selectedImageFile != null) ...[
            Container(
              height: 200,
              width: double.infinity,
              margin: EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade300, width: 2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Stack(
                  children: [
                    Image.file(
                      _selectedImageFile!,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    ),
                    if (_isAnalyzing)
                      Container(
                        color: Colors.black.withOpacity(0.6),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(color: Colors.white),
                              SizedBox(height: 8),
                              Text(
                                'AI 분석 중...',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
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
            ),
          ],
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
                // 분석 중 로딩 표시 (전체 화면)
                if (_isAnalyzing && _selectedImageFile == null)
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
                // AI 테스트 이미지 선택 버튼
                GestureDetector(
                  onTap: _isAnalyzing ? null : _showAiTestImageSelector,
                  child: CircleAvatar(
                    radius: 26,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.auto_awesome,
                      color:
                          _isAnalyzing ? Colors.grey : Colors.orange.shade700,
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
                // 갤러리 선택 버튼
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
