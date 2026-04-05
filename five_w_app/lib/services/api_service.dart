import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/five_w_model.dart';
import 'api_interface.dart';
import 'settings_service.dart';

class ApiService implements ApiInterface {
  @override
  Future<AnalyzeResponse> analyzeTopic(String profession, String topic) async {
    final baseUrl = await SettingsService.getBackendUrl();
    if (baseUrl.isEmpty) {
      throw Exception(
          'Backend not configured. Tap the settings icon to enter your server IP.');
    }

    // Verify backend is reachable
    try {
      await http
          .get(Uri.parse('$baseUrl/health'))
          .timeout(const Duration(seconds: 3));
    } catch (e) {
      debugPrint("Backend health check failed: $e");
      throw Exception(
          'Cannot reach backend at $baseUrl. Check that the server is running and you are on the same network.');
    }

    // Perform the analyze request with a generous timeout for AI processing
    final response = await http
        .post(
          Uri.parse('$baseUrl/analyze-topic'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'profession': profession,
            'topic': topic,
          }),
        )
        .timeout(const Duration(seconds: 90));

    if (response.statusCode == 200) {
      return AnalyzeResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(
          'Analysis failed: ${response.statusCode} - ${response.body}');
    }
  }
}
