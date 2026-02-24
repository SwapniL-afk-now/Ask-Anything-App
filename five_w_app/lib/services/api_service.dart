import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/five_w_model.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

import 'dart:async';
import 'api_interface.dart';

class ApiService implements ApiInterface {
  // Try the local PC IP first, then fallback to the public Localtunnel
  static const String localWifiUrl = 'http://192.168.103.6:8000';
  static const String cloudSimUrl = 'https://rude-mice-sit.loca.lt';

  Future<AnalyzeResponse> analyzeTopic(String profession, String topic) async {
    final uriPath = '/analyze-topic';
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      'profession': profession,
      'topic': topic,
    });

    String selectedBaseUrl = cloudSimUrl; // Default to Cloud

    // 1. Fast Ping the Local Wi-Fi Network to see if it's reachable
    try {
      final healthResponse = await http.get(
        Uri.parse('$localWifiUrl/health'),
      ).timeout(const Duration(seconds: 2));

      if (healthResponse.statusCode == 200) {
        selectedBaseUrl = localWifiUrl; // Phone is on the same Wi-Fi!
      }
    } catch (e) {
      debugPrint("Local WiFi ping failed, defaulting to SIM network: $e");
    }

    // 2. Perform the actual long-running AI request on the chosen network
    if (selectedBaseUrl == localWifiUrl) {
      // Local Wi-Fi execution
      final response = await http.post(
        Uri.parse('$selectedBaseUrl$uriPath'),
        headers: headers,
        body: body,
      );
      
      if (response.statusCode == 200) {
        return AnalyzeResponse.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load analysis locally: ${response.statusCode} - ${response.body}');
      }
    } else {
      // Cloud/SIM execution with Retry Logic and Bypass Headers
      final cloudHeaders = {
        'Content-Type': 'application/json',
        'Bypass-Tunnel-Reminder': 'true',
      };

      int maxRetries = 6;
      for (int i = 0; i < maxRetries; i++) {
        try {
          final response = await http.post(
            Uri.parse('$selectedBaseUrl$uriPath'),
            headers: cloudHeaders,
            body: body,
          );

          if (response.statusCode == 200) {
            return AnalyzeResponse.fromJson(jsonDecode(response.body));
          } else if (response.statusCode == 503 || response.statusCode == 504 || response.statusCode == 502) {
            if (i == maxRetries - 1) {
              throw Exception('Failed to load analysis after retries: ${response.statusCode} - ${response.body}');
            }
            await Future.delayed(const Duration(seconds: 3));
          } else {
            throw Exception('Failed to load analysis: ${response.statusCode} - ${response.body}');
          }
        } catch (e) {
          if (i == maxRetries - 1) rethrow;
          await Future.delayed(const Duration(seconds: 3));
        }
      }
      throw Exception('Failed to communicate with the cloud server.');
    }
  }
}
