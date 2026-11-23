import 'dart:convert';
import 'dart:io';
import '../api/api_client.dart';
import '../api/api_constants.dart';
import '../models/problem_model.dart';
import '../models/notification_model.dart';

class AcademicService {
  static Future<List<String>> getClasses(String curriculumType) async {
    try {
      final response = await ApiClient.get('${ApiConstants.classes}?curriculumType=$curriculumType');
      if (response.statusCode == 200) {
        return List<String>.from(jsonDecode(response.body));
      }
    } catch (_) {}
    return [];
  }

  static Future<List<String>> getSubjects(String curriculumType, String className) async {
    try {
      final response = await ApiClient.get(
        '${ApiConstants.subjects}?curriculumType=$curriculumType&className=$className',
      );
      if (response.statusCode == 200) {
        return List<String>.from(jsonDecode(response.body));
      }
    } catch (_) {}
    return [];
  }
}

class ProblemService {
  static Future<bool> createProblem({
    required String subjectName,
    required String className,
    required String curriculumType,
    required String title,
    required String description,
    File? imageFile,
  }) async {
    try {
      final streamed = await ApiClient.postMultipart(
        ApiConstants.createProblem,
        fields: {
          'SubjectName': subjectName,
          'ClassName': className,
          'CurriculumType': curriculumType,
          'Title': title,
          'Description': description,
        },
        file: imageFile,
        fileField: 'ImageFile',
      );
      return streamed.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  static Future<List<HomeworkProblemModel>> getFeed({
    String? subjectName,
    String? className,
  }) async {
    try {
      String query = '';
      if (subjectName != null && subjectName.isNotEmpty) {
        query += 'subjectName=$subjectName&';
      }
      if (className != null && className.isNotEmpty) {
        query += 'className=$className';
      }

      final url = '${ApiConstants.feed}${query.isNotEmpty ? '?$query' : ''}';
      final response = await ApiClient.get(url);
      if (response.statusCode == 200) {
        final List list = jsonDecode(response.body);
        return list.map((item) => HomeworkProblemModel.fromJson(item)).toList();
      }
    } catch (_) {}
    return [];
  }

  static Future<HomeworkProblemModel?> getProblemDetails(int id) async {
    try {
      final response = await ApiClient.get(ApiConstants.problemDetails(id));
      if (response.statusCode == 200) {
        return HomeworkProblemModel.fromJson(jsonDecode(response.body));
      }
    } catch (_) {}
    return null;
  }

  static Future<bool> addReply({
    required int problemId,
    required String replyText,
    File? imageFile,
    File? audioFile,
  }) async {
    try {
      final streamed = await ApiClient.postMultipart(
        ApiConstants.reply(problemId),
        fields: {'ReplyText': replyText},
        file: imageFile,
        fileField: 'ImageFile',
        audioFile: audioFile,
        audioField: 'AudioFile',
      );
      return streamed.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  static Future<Map<String, dynamic>?> toggleLike(int replyId) async {
    try {
      final response = await ApiClient.post(ApiConstants.toggleLike(replyId), {});
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (_) {}
    return null;
  }
}

class AiService {
  static Future<Map<String, dynamic>> solveHomework({
    required String questionText,
    String subjectName = '',
    String className = '',
    String? imageBase64,
    String? userApiKey,
  }) async {
    try {
      final response = await ApiClient.post(ApiConstants.aiSolve, {
        'questionText': questionText,
        'subjectName': subjectName,
        'className': className,
        'imageBase64': imageBase64,
        'userApiKey': userApiKey,
      });

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true, 'solution': data['solution']};
      } else {
        return {'success': false, 'message': data['errorMessage'] ?? 'Failed to solve problem.'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }
}

class NotificationService {
  static Future<List<NotificationModel>> getNotifications() async {
    try {
      final response = await ApiClient.get(ApiConstants.notifications);
      if (response.statusCode == 200) {
        final List list = jsonDecode(response.body);
        return list.map((item) => NotificationModel.fromJson(item)).toList();
      }
    } catch (_) {}
    return [];
  }

  static Future<bool> markAsRead(int id) async {
    try {
      final response = await ApiClient.post(ApiConstants.markAsRead(id), {});
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}

class TuitionApiService {
  static Future<List<TuitionPostModel>> getTuitionFeed({
    String? className,
    String? location,
    String? curriculum,
  }) async {
    try {
      String query = '';
      if (className != null && className.isNotEmpty) query += 'className=$className&';
      if (location != null && location.isNotEmpty) query += 'location=$location&';
      if (curriculum != null && curriculum.isNotEmpty) query += 'curriculum=$curriculum&';

      final url = '${ApiConstants.tuitionFeed}${query.isNotEmpty ? '?$query' : ''}';
      final response = await ApiClient.get(url);
      if (response.statusCode == 200) {
        final List list = jsonDecode(response.body);
        return list.map((item) => TuitionPostModel.fromJson(item)).toList();
      }
    } catch (_) {}
    return [];
  }

  static Future<bool> createTuition({
    required String className,
    required String subjects,
    required String location,
    String curriculumType = 'General',
    String? salary,
    String? daysPerWeek,
    String tuitionType = 'Home Tuition',
    String? description,
  }) async {
    try {
      final response = await ApiClient.post(ApiConstants.createTuition, {
        'className': className,
        'subjects': subjects,
        'location': location,
        'curriculumType': curriculumType,
        'salary': salary,
        'daysPerWeek': daysPerWeek,
        'tuitionType': tuitionType,
        'description': description,
      });
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> applyTuition(int id, {String? qualifications, String? experience, String? message}) async {
    try {
      final response = await ApiClient.post(ApiConstants.applyTuition(id), {
        'qualifications': qualifications,
        'experience': experience,
        'message': message,
      });
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
