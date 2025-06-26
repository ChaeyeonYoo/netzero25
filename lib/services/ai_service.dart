import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import '../models/ai_analysis_result.dart';

class AiService {
  // 서버 URL 설정 (로컬 Flask 서버 또는 Azure 서버)
  static const String _azureUrl =
      'https://pet-zero-awgagdavgkhtehe0.koreacentral-01.azurewebsites.net';
  // TODO: 실제 Flask 서버 URL로 변경하세요
  static const String _localFlaskUrl =
      'http://localhost:5000'; // Flask 서버 기본 포트
  // 예시: 'http://192.168.1.100:5000' 또는 'https://your-flask-server.com'
  static const String _analyzeEndpoint = '/analyze';

  // 현재 사용할 서버 URL (Azure 서버 사용)
  static const String _baseUrl = _azureUrl;

  /// 배변 분석 요청
  static Future<AiAnalysisResult> analyzePoop(File imageFile) async {
    return _analyzeImage(imageFile, '배변');
  }

  /// 음식 분석 요청
  static Future<AiAnalysisResult> analyzeFood(File imageFile) async {
    return _analyzeImage(imageFile, '음식');
  }

  /// Flask 서버로 이미지 분석 요청
  static Future<AiAnalysisResult> _analyzeImage(
    File imageFile,
    String mode,
  ) async {
    try {
      print('$mode 분석 시작: ${imageFile.path}');
      print('Flask 서버 URL: $_baseUrl$_analyzeEndpoint');

      // multipart 요청 생성 (Flask 서버용)
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl$_analyzeEndpoint'),
      );

      // 이미지 파일 추가
      var stream = http.ByteStream(imageFile.openRead());
      var length = await imageFile.length();
      var multipartFile = http.MultipartFile(
        'image',
        stream,
        length,
        filename: path.basename(imageFile.path),
      );
      request.files.add(multipartFile);

      // mode 파라미터 추가
      request.fields['mode'] = mode;

      print('Flask 서버로 요청 전송 중... (mode: $mode)');
      print('파일 크기: $length bytes');

      // 요청 전송
      var response = await request.send();
      var responseBytes = await response.stream.toBytes();
      var responseData = utf8.decode(responseBytes, allowMalformed: true);

      print('Flask 서버 응답: ${response.statusCode} - $responseData');

      if (response.statusCode == 200) {
        var jsonData = json.decode(responseData);
        return AiAnalysisResult.fromJson(jsonData);
      } else {
        throw Exception('$mode 분석 실패: ${response.statusCode} - $responseData');
      }
    } catch (e) {
      print('$mode 분석 오류: $e');
      throw Exception('$mode 분석 중 오류 발생: $e');
    }
  }

  /// Flask 서버 상태 확인
  static Future<bool> checkFlaskServerStatus() async {
    try {
      final response = await http
          .get(
            Uri.parse('$_baseUrl/health'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(Duration(seconds: 5));

      print('Flask 서버 상태 확인: ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      print('Flask 서버 연결 실패: $e');
      return false;
    }
  }

  /// Flask 서버로 JSON 요청 (대안 방법)
  static Future<AiAnalysisResult> analyzeImageByUrl(
    String imageUrl,
    RecordType recordType,
  ) async {
    try {
      final mode = recordType == RecordType.poop ? '배변' : '음식';

      final response = await http.post(
        Uri.parse('$_baseUrl$_analyzeEndpoint'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'image_url': imageUrl, 'mode': mode}),
      );

      if (response.statusCode == 200) {
        var jsonData = json.decode(
          utf8.decode(response.bodyBytes, allowMalformed: true),
        );
        return AiAnalysisResult.fromJson(jsonData);
      } else {
        throw Exception('이미지 분석 실패: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('이미지 분석 중 오류 발생: $e');
    }
  }

  /// Azure 서버로 요청 (백업용)
  static Future<AiAnalysisResult> analyzeWithAzure(
    File imageFile,
    RecordType recordType,
  ) async {
    try {
      final mode = recordType == RecordType.poop ? '배변' : '음식';

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$_azureUrl$_analyzeEndpoint'),
      );

      var stream = http.ByteStream(imageFile.openRead());
      var length = await imageFile.length();
      var multipartFile = http.MultipartFile(
        'image',
        stream,
        length,
        filename: path.basename(imageFile.path),
      );
      request.files.add(multipartFile);
      request.fields['mode'] = mode;

      print('Azure 서버로 요청 전송 중... (mode: $mode)');

      var response = await request.send();
      var responseBytes = await response.stream.toBytes();
      var responseData = utf8.decode(responseBytes, allowMalformed: true);

      if (response.statusCode == 200) {
        var jsonData = json.decode(responseData);
        return AiAnalysisResult.fromJson(jsonData);
      } else {
        throw Exception('Azure 분석 실패: ${response.statusCode} - $responseData');
      }
    } catch (e) {
      throw Exception('Azure 분석 중 오류 발생: $e');
    }
  }
}

// RecordType enum (이미 camera_page.dart에 있지만 여기서도 사용)
enum RecordType { poop, food }
