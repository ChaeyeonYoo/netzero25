import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

class AiService {
  // AI 서버 URL (실제 서버 URL로 변경 필요)
  static const String _baseUrl = 'http://your-ai-server.com/api';

  // 배변 분석 API
  static const String _poopAnalysisEndpoint = '/analyze-poop';

  // 음식 분석 API
  static const String _foodAnalysisEndpoint = '/analyze-food';

  /// 배변 분석 요청
  static Future<Map<String, dynamic>> analyzePoop(File imageFile) async {
    try {
      // multipart 요청 생성
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl$_poopAnalysisEndpoint'),
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

      // 요청 전송
      var response = await request.send();
      var responseData = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        return json.decode(responseData);
      } else {
        throw Exception('배변 분석 실패: ${response.statusCode} - $responseData');
      }
    } catch (e) {
      throw Exception('배변 분석 중 오류 발생: $e');
    }
  }

  /// 음식 분석 요청
  static Future<Map<String, dynamic>> analyzeFood(File imageFile) async {
    try {
      // multipart 요청 생성
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl$_foodAnalysisEndpoint'),
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

      // 요청 전송
      var response = await request.send();
      var responseData = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        return json.decode(responseData);
      } else {
        throw Exception('음식 분석 실패: ${response.statusCode} - $responseData');
      }
    } catch (e) {
      throw Exception('음식 분석 중 오류 발생: $e');
    }
  }

  /// URL로 이미지 전송 (대안 방법)
  static Future<Map<String, dynamic>> analyzeImageByUrl(
    String imageUrl,
    RecordType recordType,
  ) async {
    try {
      final endpoint =
          recordType == RecordType.poop
              ? _poopAnalysisEndpoint
              : _foodAnalysisEndpoint;

      final response = await http.post(
        Uri.parse('$_baseUrl$endpoint'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'image_url': imageUrl}),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('이미지 분석 실패: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('이미지 분석 중 오류 발생: $e');
    }
  }
}

// RecordType enum (이미 camera_page.dart에 있지만 여기서도 사용)
enum RecordType { poop, food }
