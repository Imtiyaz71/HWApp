class HomeworkProblemModel {
  final int id;
  final int studentId;
  final String studentName;
  final String studentPhone;
  final String? schoolName;
  final String className;
  final String curriculumType;
  final String subjectName;
  final String title;
  final String description;
  final String? imageUrl;
  final DateTime createdAt;
  final int totalReplies;
  final int totalLikes;
  final bool isLikedByMe;
  final List<ProblemReplyModel> replies;

  HomeworkProblemModel({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.studentPhone,
    this.schoolName,
    required this.className,
    required this.curriculumType,
    required this.subjectName,
    required this.title,
    required this.description,
    this.imageUrl,
    required this.createdAt,
    this.totalReplies = 0,
    this.totalLikes = 0,
    this.isLikedByMe = false,
    this.replies = const [],
  });

  factory HomeworkProblemModel.fromJson(Map<String, dynamic> json) {
    return HomeworkProblemModel(
      id: json['id'] ?? 0,
      studentId: json['studentId'] ?? 0,
      studentName: json['studentName'] ?? '',
      studentPhone: json['studentPhone'] ?? '',
      schoolName: json['schoolName'],
      className: json['className'] ?? '',
      curriculumType: json['curriculumType'] ?? '',
      subjectName: json['subjectName'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt']) ?? DateTime.now()
          : DateTime.now(),
      totalReplies: json['totalReplies'] ?? 0,
      totalLikes: json['totalLikes'] ?? 0,
      isLikedByMe: json['isLikedByMe'] ?? false,
      replies: json['replies'] != null
          ? (json['replies'] as List)
              .map((r) => ProblemReplyModel.fromJson(r))
              .toList()
          : [],
    );
  }
}

class ProblemReplyModel {
  final int id;
  final int problemId;
  final int userId;
  final String userName;
  final String userRole;
  final String replyText;
  final String? imageUrl;
  final String? audioUrl;
  final DateTime createdAt;
  int likeCount;
  bool isLikedByMe;

  ProblemReplyModel({
    required this.id,
    required this.problemId,
    required this.userId,
    required this.userName,
    required this.userRole,
    required this.replyText,
    this.imageUrl,
    this.audioUrl,
    required this.createdAt,
    this.likeCount = 0,
    this.isLikedByMe = false,
  });

  factory ProblemReplyModel.fromJson(Map<String, dynamic> json) {
    return ProblemReplyModel(
      id: json['id'] ?? 0,
      problemId: json['problemId'] ?? 0,
      userId: json['userId'] ?? 0,
      userName: json['userName'] ?? '',
      userRole: json['userRole'] ?? '',
      replyText: json['replyText'] ?? '',
      imageUrl: json['imageUrl'],
      audioUrl: json['audioUrl'],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt']) ?? DateTime.now()
          : DateTime.now(),
      likeCount: json['likeCount'] ?? 0,
      isLikedByMe: json['isLikedByMe'] ?? false,
    );
  }
}

class TuitionPostModel {
  final int id;
  final int studentOrGuardianId;
  final String posterName;
  final String phone;
  final String curriculumType;
  final String className;
  final String subjects;
  final String location;
  final String? salary;
  final String? daysPerWeek;
  final String tuitionType;
  final String? description;
  final String status;
  final DateTime createdAt;
  final int totalApplicants;
  final bool hasApplied;

  TuitionPostModel({
    required this.id,
    required this.studentOrGuardianId,
    required this.posterName,
    required this.phone,
    required this.curriculumType,
    required this.className,
    required this.subjects,
    required this.location,
    this.salary,
    this.daysPerWeek,
    this.tuitionType = 'Home Tuition',
    this.description,
    this.status = 'Open',
    required this.createdAt,
    this.totalApplicants = 0,
    this.hasApplied = false,
  });

  factory TuitionPostModel.fromJson(Map<String, dynamic> json) {
    return TuitionPostModel(
      id: json['id'] ?? 0,
      studentOrGuardianId: json['studentOrGuardianId'] ?? 0,
      posterName: json['posterName'] ?? '',
      phone: json['phone'] ?? '',
      curriculumType: json['curriculumType'] ?? 'General',
      className: json['className'] ?? '',
      subjects: json['subjects'] ?? '',
      location: json['location'] ?? '',
      salary: json['salary'],
      daysPerWeek: json['daysPerWeek'],
      tuitionType: json['tuitionType'] ?? 'Home Tuition',
      description: json['description'],
      status: json['status'] ?? 'Open',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt']) ?? DateTime.now()
          : DateTime.now(),
      totalApplicants: json['totalApplicants'] ?? 0,
      hasApplied: json['hasApplied'] ?? false,
    );
  }
}
