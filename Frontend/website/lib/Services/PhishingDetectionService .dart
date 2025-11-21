// lib/Services/PhishingDetectionService.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:website/models/PhishingResult.dart';

class PhishingDetectionService {
  final String baseUrl;

  PhishingDetectionService({required this.baseUrl});

  Future<PhishingResponse> checkPhishing(String url) async {
    final uri = Uri.parse('$baseUrl/phishing/phish');

    print('🌍 [PhishingDetectionService] Sending URL to backend: $url');
    print('🔗 [PhishingDetectionService] Full endpoint: $uri');

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'url': url}),
      );

      print(
        '📦 [PhishingDetectionService] Response status: ${response.statusCode}',
      );
      print(
        '🧾 [PhishingDetectionService] Raw response body: ${response.body}',
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonBody = jsonDecode(response.body);
        print('✅ [PhishingDetectionService] Parsed JSON: $jsonBody');

        final parsedResponse = PhishingResponse.fromJson(jsonBody);
        print(
          '🎯 [PhishingDetectionService] Parsed model: ${parsedResponse.data.url}',
        );
        return parsedResponse;
      } else {
        // Handle error response
        try {
          final error = jsonDecode(response.body);
          print('❌ [PhishingDetectionService] Error response: $error');
          throw Exception(error['message'] ?? 'Failed to check URL safety');
        } catch (e) {
          throw Exception('Server error: ${response.statusCode}');
        }
      }
    } on http.ClientException catch (e) {
      print('🔥 [PhishingDetectionService] Network error: $e');
      throw Exception(
        'Network error: Unable to connect to server. Please check your connection.',
      );
    } on FormatException catch (e) {
      print('🔥 [PhishingDetectionService] JSON parse error: $e');
      throw Exception('Invalid response from server. Please try again.');
    } catch (e) {
      print('🔥 [PhishingDetectionService] Exception occurred: $e');
      rethrow;
    }
  }
}
