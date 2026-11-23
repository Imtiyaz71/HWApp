import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/api_client.dart';
import '../api/api_constants.dart';
import '../models/user_model.dart';

class AuthService {
  static Future<Map<String, dynamic>> registerStudent({
    required String studentName,
    String? fatherName,
    String? motherName,
    required String guardianPhone,
    String? guardianEmail,
    String? address,
    String? gender,
    required String curriculumType,
    required String className,
    required String schoolName,
    String? schoolAddress,
    String password = '123',
  }) async {
    try {
      final response = await ApiClient.post(ApiConstants.registerStudent, {
        'studentName': studentName.trim(),
        'fatherName': fatherName?.trim().isNotEmpty == true ? fatherName!.trim() : null,
        'motherName': motherName?.trim().isNotEmpty == true ? motherName!.trim() : null,
        'guardianPhone': guardianPhone.trim(),
        'guardianEmail': guardianEmail?.trim().isNotEmpty == true ? guardianEmail!.trim() : null,
        'address': address?.trim().isNotEmpty == true ? address!.trim() : null,
        'gender': gender?.trim() ?? 'Male',
        'curriculumType': curriculumType.trim(),
        'className': className.trim(),
        'schoolName': schoolName.trim(),
        'schoolAddress': schoolAddress?.trim().isNotEmpty == true ? schoolAddress!.trim() : null,
        'password': password.trim().isNotEmpty ? password.trim() : '123',
      });

      final bodyText = response.body.trim();
      if (bodyText.startsWith('<') || bodyText.isEmpty) {
        return {
          'success': false,
          'message': 'Backend server returned HTTP ${response.statusCode}. Please verify server is running.'
        };
      }

      final data = jsonDecode(bodyText);
      final isSuccess = data['success'] == true || data['Success'] == true;

      if (response.statusCode == 200 && isSuccess) {
        await _saveSession(data);
        return {'success': true, 'user': UserModel.fromJson(data)};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? data['Message'] ?? 'Student registration failed.'
        };
      }
    } on TimeoutException {
      return {'success': false, 'message': 'Connection timed out. Please check your internet and server.'};
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString().replaceAll("Exception:", "").trim()}'};
    }
  }

  static Future<Map<String, dynamic>> registerTeacher({
    required String teacherName,
    required String phone,
    String? email,
    String? address,
    required String schoolName,
    String? schoolAddress,
    required List<String> specialistSubjects,
    String password = '123',
  }) async {
    try {
      final response = await ApiClient.post(ApiConstants.registerTeacher, {
        'teacherName': teacherName.trim(),
        'phone': phone.trim(),
        'email': email?.trim().isNotEmpty == true ? email!.trim() : null,
        'address': address?.trim().isNotEmpty == true ? address!.trim() : null,
        'schoolName': schoolName.trim(),
        'schoolAddress': schoolAddress?.trim().isNotEmpty == true ? schoolAddress!.trim() : null,
        'specialistSubjects': specialistSubjects,
        'password': password.trim().isNotEmpty ? password.trim() : '123',
      });

      final bodyText = response.body.trim();
      if (bodyText.startsWith('<') || bodyText.isEmpty) {
        return {
          'success': false,
          'message': 'Backend server returned HTTP ${response.statusCode}. Please verify server is running.'
        };
      }

      final data = jsonDecode(bodyText);
      final isSuccess = data['success'] == true || data['Success'] == true;

      if (response.statusCode == 200 && isSuccess) {
        await _saveSession(data);
        return {'success': true, 'user': UserModel.fromJson(data)};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? data['Message'] ?? 'Teacher registration failed.'
        };
      }
    } on TimeoutException {
      return {'success': false, 'message': 'Connection timed out. Please check your internet and server.'};
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString().replaceAll("Exception:", "").trim()}'};
    }
  }

  static Future<Map<String, dynamic>> login({
    required String identifier,
    required String password,
    String? deviceToken,
  }) async {
    try {
      final response = await ApiClient.post(ApiConstants.login, {
        'identifier': identifier.trim(),
        'password': password.trim(),
        'deviceToken': deviceToken,
      });

      final bodyText = response.body.trim();
      if (bodyText.startsWith('<') || bodyText.isEmpty) {
        return {
          'success': false,
          'message': 'Backend server returned HTTP ${response.statusCode}. Please verify server is running.'
        };
      }

      final data = jsonDecode(bodyText);
      final isSuccess = data['success'] == true || data['Success'] == true;

      if (response.statusCode == 200 && isSuccess) {
        await _saveSession(data);
        return {'success': true, 'user': UserModel.fromJson(data)};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? data['Message'] ?? 'Login failed. Invalid phone/email or password.'
        };
      }
    } on TimeoutException {
      return {'success': false, 'message': 'Connection timed out. Please check your internet and server.'};
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString().replaceAll("Exception:", "").trim()}'};
    }
  }

  static Future<void> _saveSession(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final token = data['token'] ?? data['Token'] ?? '';
    final role = data['role'] ?? data['Role'] ?? '';
    await prefs.setString('auth_token', token);
    await prefs.setString('user_role', role);
    await prefs.setString('user_data', jsonEncode(data));
  }

  static Future<UserModel?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('user_data');
    if (raw != null && raw.isNotEmpty) {
      try {
        return UserModel.fromJson(jsonDecode(raw));
      } catch (_) {}
    }
    return null;
  }

  static Future<Map<String, dynamic>> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      final response = await ApiClient.post(ApiConstants.changePassword, {
        'oldPassword': oldPassword.trim(),
        'newPassword': newPassword.trim(),
      });

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && (data['success'] == true || data['Success'] == true)) {
        return {'success': true, 'message': data['message'] ?? 'Password changed successfully.'};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Failed to change password.'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
