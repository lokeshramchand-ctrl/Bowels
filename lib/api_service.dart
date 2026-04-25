import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl =
      "https://lt9e0fj1favccw8wxgggl2d2.deploy.splsystems.in";

  Future<bool> getTodayStatus(String deviceId) async {
    final res = await http.get(
      Uri.parse('$baseUrl/status/today'),
      headers: {'x-device-id': deviceId},
    );

    return jsonDecode(res.body)['done'];
  }

  Future<Map?> getLatest(String deviceId) async {
    final res = await http.get(
      Uri.parse('$baseUrl/logs/latest'),
      headers: {'x-device-id': deviceId},
    );

    return jsonDecode(res.body)['data'];
  }

  Future<void> createLog(String deviceId, String id, DateTime time) async {
    await http.post(
      Uri.parse('$baseUrl/log'),
      headers: {
        'Content-Type': 'application/json',
        'x-device-id': deviceId,
      },
      body: jsonEncode({
        'id': id,
        'timestamp': time.toIso8601String(),
      }),
    );
  }

  Future<List> getRecent(String deviceId) async {
    final res = await http.get(
      Uri.parse('$baseUrl/logs/recent'),
      headers: {'x-device-id': deviceId},
    );

    return jsonDecode(res.body)['data'] ?? [];
  }
}