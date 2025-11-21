// lib/models/PhishingResult.dart

class PhishingResult {
  final String url;
  final bool isPhishing;
  final int prediction;
  final double confidence;
  final double probability;
  final String riskLevel;
  final String timestamp;

  PhishingResult({
    required this.url,
    required this.isPhishing,
    required this.prediction,
    required this.confidence,
    required this.probability,
    required this.riskLevel,
    required this.timestamp,
  });

  factory PhishingResult.fromJson(Map<String, dynamic> json) {
    return PhishingResult(
      url: json['url'] ?? '',
      isPhishing: json['is_phishing'] ?? false,
      prediction: json['prediction'] ?? 0,
      confidence: (json['confidence'] ?? 0.0).toDouble(),
      probability: (json['probability'] ?? 0.0).toDouble(),
      riskLevel: json['risk_level'] ?? 'UNKNOWN',
      timestamp: json['timestamp'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'is_phishing': isPhishing,
      'prediction': prediction,
      'confidence': confidence,
      'probability': probability,
      'risk_level': riskLevel,
      'timestamp': timestamp,
    };
  }

  // Helper getter for UI
  String get predictionLabel => isPhishing ? 'phishing' : 'safe';
}

class PhishingResponse {
  final bool success;
  final String message;
  final PhishingResult data;

  PhishingResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory PhishingResponse.fromJson(Map<String, dynamic> json) {
    return PhishingResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: PhishingResult.fromJson(json['data'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {'success': success, 'message': message, 'data': data.toJson()};
  }
}
