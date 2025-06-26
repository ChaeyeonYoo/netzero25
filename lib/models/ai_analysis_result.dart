class AiAnalysisResult {
  final bool success;
  final String message;
  final Map<String, dynamic> data;
  final String? error;
  final String mode;
  final Map<String, dynamic>? result;

  AiAnalysisResult({
    required this.success,
    required this.message,
    required this.data,
    this.error,
    required this.mode,
    this.result,
  });

  factory AiAnalysisResult.fromJson(Map<String, dynamic> json) {
    // 서버 응답 구조에 맞게 파싱
    final resultData = json['result'];
    Map<String, dynamic>? resultMap;
    String resultMessage = '';

    print('AiAnalysisResult.fromJson 디버깅:');
    print('- 전체 JSON: $json');
    print('- resultData 타입: ${resultData.runtimeType}');
    print('- resultData 값: $resultData');

    // result가 Map인 경우 (배변 분석)
    if (resultData is Map<String, dynamic>) {
      resultMap = resultData;
      resultMessage = resultData['message'] ?? '';
      print('- Map 파싱: $resultMessage');
    }
    // result가 String인 경우 (음식 분석)
    else if (resultData is String) {
      resultMessage = resultData;
      // 음식 분석의 경우 result를 String으로 유지
      resultMap = null; // result 필드를 String으로 유지하기 위해 null로 설정
      print('- String 파싱: $resultMessage');
    }

    final result = AiAnalysisResult(
      success: json['mode'] != null, // mode가 있으면 성공으로 간주
      message: resultMessage,
      data: resultMap ?? {},
      error: json['error'],
      mode: json['mode'] ?? '',
      result:
          resultData is String
              ? null
              : resultMap, // String인 경우 null로 설정하여 message에서 추출
    );

    print('- 생성된 객체: success=${result.success}, message=${result.message}');
    print('- result 필드 타입: ${result.result.runtimeType}');
    print('- message 길이: ${result.message.length}');
    return result;
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data,
      'mode': mode,
      if (error != null) 'error': error,
      if (result != null) 'result': result,
    };
  }

  // 편의 메서드들
  int get score =>
      (result is Map<String, dynamic>) ? (result?['score'] ?? 0) : 0;
  double get probability =>
      (result is Map<String, dynamic>)
          ? ((result?['probability'] ?? 0.0).toDouble())
          : 0.0;
  String get tagName =>
      (result is Map<String, dynamic>) ? (result?['tagName'] ?? '') : '';
  double get avoidedEmissionsGram =>
      (result is Map<String, dynamic>)
          ? ((result?['avoided_emissions_gram'] ?? 0.0).toDouble())
          : 0.0;

  // 음식 분석용 탄소 배출량 추출
  double get carbonEmissionsKg {
    print('carbonEmissionsKg 호출:');
    print('- result 타입: ${result.runtimeType}');
    print('- result 값: $result');

    // message 필드 안전하게 접근
    final messageValue = message;
    print('- message 값: $messageValue');
    print('- message 길이: ${messageValue.length}');
    print('- message가 비어있나?: ${messageValue.isEmpty}');

    // message에서 직접 추출 (음식 분석의 경우)
    if (messageValue.isNotEmpty) {
      print('message에서 탄소 배출량 추출 디버깅:');
      print('- 원본 message: $messageValue');

      // markdown 코드 블록 제거
      String cleanString = messageValue;
      if (cleanString.contains('```plaintext')) {
        cleanString =
            cleanString
                .replaceAll('```plaintext', '')
                .replaceAll('```', '')
                .trim();
        print('- 코드 블록 제거 후: $cleanString');
      }

      // "예상 탄소 배출량: 21.12 kg CO2e" 형태에서 숫자 추출
      final regex = RegExp(r'(\d+\.?\d*)');
      final match = regex.firstMatch(cleanString);
      if (match != null) {
        final extracted = double.tryParse(match.group(1) ?? '0') ?? 0.0;
        print('- 추출된 숫자: $extracted');
        return extracted;
      }
      print('- 숫자 추출 실패');
    } else {
      print('- message가 비어있어서 추출 불가');
    }

    print('- 탄소 배출량 추출 실패');
    return 0.0;
  }

  // 탄소 점수 계산: 50 + (90 - 탄소배출량) / (90 - 50) * 40
  int get carbonScore {
    final emissions = carbonEmissionsKg;
    if (emissions <= 0) return 50;

    // 50kg 이하면 최고점수, 90kg 이상이면 최저점수
    if (emissions <= 50) return 90;
    if (emissions >= 90) return 50;

    // 계산식: 50 + (90 - 탄소배출량) / (90 - 50) * 40
    final score = 50 + ((90 - emissions) / (90 - 50)) * 40;
    return score.round();
  }
}

// 배변 분석 결과 모델
class PoopAnalysisResult {
  final String healthStatus; // 건강 상태
  final String consistency; // 일관성
  final String color; // 색상
  final String recommendation; // 권장사항
  final double confidence; // 신뢰도

  PoopAnalysisResult({
    required this.healthStatus,
    required this.consistency,
    required this.color,
    required this.recommendation,
    required this.confidence,
  });

  factory PoopAnalysisResult.fromJson(Map<String, dynamic> json) {
    return PoopAnalysisResult(
      healthStatus: json['health_status'] ?? '정상',
      consistency: json['consistency'] ?? '보통',
      color: json['color'] ?? '갈색',
      recommendation: json['recommendation'] ?? '정상적인 배변입니다.',
      confidence: (json['confidence'] ?? 0.0).toDouble(),
    );
  }
}

// 음식 분석 결과 모델
class FoodAnalysisResult {
  final String foodType; // 음식 종류
  final String nutritionalValue; // 영양가
  final String safetyLevel; // 안전도
  final String recommendation; // 권장사항
  final double confidence; // 신뢰도

  FoodAnalysisResult({
    required this.foodType,
    required this.nutritionalValue,
    required this.safetyLevel,
    required this.recommendation,
    required this.confidence,
  });

  factory FoodAnalysisResult.fromJson(Map<String, dynamic> json) {
    return FoodAnalysisResult(
      foodType: json['food_type'] ?? '알 수 없음',
      nutritionalValue: json['nutritional_value'] ?? '보통',
      safetyLevel: json['safety_level'] ?? '안전',
      recommendation: json['recommendation'] ?? '적당량을 섭취하세요.',
      confidence: (json['confidence'] ?? 0.0).toDouble(),
    );
  }
}
