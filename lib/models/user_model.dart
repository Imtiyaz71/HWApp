class UserModel {
  final int userId;
  final String name;
  final String phone;
  final String? email;
  final String role; // 'Student' or 'Teacher'
  final String? schoolName;
  final String? schoolAddress;
  final String? className;
  final String? curriculumType;
  final List<String>? specialistSubjects;
  final String? token;

  bool get isTeacher => role.toLowerCase() == 'teacher';

  UserModel({
    required this.userId,
    required this.name,
    required this.phone,
    this.email,
    required this.role,
    this.schoolName,
    this.schoolAddress,
    this.className,
    this.curriculumType,
    this.specialistSubjects,
    this.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['userId'] ?? json['UserId'] ?? 0,
      name: json['name'] ?? json['Name'] ?? '',
      phone: json['phone'] ?? json['Phone'] ?? '',
      email: json['email'] ?? json['Email'],
      role: json['role'] ?? json['Role'] ?? 'Student',
      schoolName: json['schoolName'] ?? json['SchoolName'],
      schoolAddress: json['schoolAddress'] ?? json['SchoolAddress'],
      className: json['className'] ?? json['ClassName'],
      curriculumType: json['curriculumType'] ?? json['CurriculumType'],
      specialistSubjects: json['specialistSubjects'] != null
          ? List<String>.from(json['specialistSubjects'])
          : (json['SpecialistSubjects'] != null
              ? List<String>.from(json['SpecialistSubjects'])
              : null),
      token: json['token'] ?? json['Token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'phone': phone,
      'email': email,
      'role': role,
      'schoolName': schoolName,
      'schoolAddress': schoolAddress,
      'className': className,
      'curriculumType': curriculumType,
      'specialistSubjects': specialistSubjects,
      'token': token,
    };
  }
}
