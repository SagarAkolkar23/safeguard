// lib/services/auth_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:website/core/BaseUrl.dart';

class AuthService {
  static const String baseUrl = backendBaseUrl;

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final url = Uri.parse("$backendBaseUrl/auth/register");
    final body = jsonEncode({
      "name": name,
      "email": email,
      "password": password,
    });

    print("🔹 [AuthService] Starting registration request...");
    print("🌐 URL: $url");
    print("📦 Request Body: $body");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      print("📥 Response Status Code: ${response.statusCode}");
      print("📩 Response Body: ${response.body}");

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        print("✅ Registration Success: ${data["message"]}");
        return {
          "success": true,
          "message": data["message"] ?? "Registration successful",
        };
      } else {
        final data = jsonDecode(response.body);
        print("❌ Registration Failed: ${data["message"]}");
        return {
          "success": false,
          "message": data["message"] ?? "Registration failed",
        };
      }
    } catch (e, stack) {
      print("🔥 Exception occurred during registration:");
      print(e);
      print("🧱 Stack Trace: $stack");
      return {"success": false, "message": "Error connecting to server: $e"};
    }
  }

 Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse("$baseUrl/auth/login");
    final body = jsonEncode({
      "email": email,
      "password": password,
    });

    print("🔹 [AuthService] Login Request → $url");
    print("📦 Body: $body");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      print("📥 Response (${response.statusCode}): ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("✅ Login Success: ${data["message"]}");
        return {
          "success": true,
          "message": data["message"] ?? "Login successful",
          "user": data["newUser"],
        };
      } else {
        final data = jsonDecode(response.body);
        print("❌ Login Failed: ${data["message"]}");
        return {
          "success": false,
          "message": data["message"] ?? "Invalid credentials",
        };
      }
    } catch (e, stack) {
      print("🔥 Exception during login: $e");
      print("🧱 Stack Trace: $stack");
      return {"success": false, "message": "Error connecting to server: $e"};
    }
  }
}
