import 'dart:convert';
import 'package:http/http.dart' as http;

class PhishingDetectionService {
  final String baseUrl;

  PhishingDetectionService({required this.baseUrl});

  Future<Map<String, dynamic>> checkPhishing(String url) async {
    final uri = Uri.parse('$baseUrl/phish');

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'url': url}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Failed to check URL safety');
    }
  }
}
