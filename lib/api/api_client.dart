import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  static const Duration timeoutDuration = Duration(seconds: 20);

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static Future<Map<String, String>> _getHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  static Future<http.Response> get(String url) async {
    final headers = await _getHeaders();
    return await http
        .get(Uri.parse(url), headers: headers)
        .timeout(timeoutDuration);
  }

  static Future<http.Response> post(String url, Map<String, dynamic> body) async {
    final headers = await _getHeaders();
    return await http
        .post(
          Uri.parse(url),
          headers: headers,
          body: jsonEncode(body),
        )
        .timeout(timeoutDuration);
  }

  static Future<http.StreamedResponse> postMultipart(
    String url, {
    required Map<String, String> fields,
    File? file,
    String fileField = 'ImageFile',
    File? audioFile,
    String audioField = 'AudioFile',
  }) async {
    final token = await getToken();
    final request = http.MultipartRequest('POST', Uri.parse(url));

    if (token != null && token.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    request.fields.addAll(fields);

    if (file != null && await file.exists()) {
      request.files.add(await http.MultipartFile.fromPath(fileField, file.path));
    }

    if (audioFile != null && await audioFile.exists()) {
      request.files.add(await http.MultipartFile.fromPath(audioField, audioFile.path));
    }

    return await request.send().timeout(timeoutDuration);
  }
}
