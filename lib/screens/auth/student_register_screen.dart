import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/app_services.dart';
import '../../theme/app_theme.dart';
import '../home/student_home_screen.dart';

class StudentRegisterScreen extends StatefulWidget {
  const StudentRegisterScreen({super.key});

  @override
  State<StudentRegisterScreen> createState() => _StudentRegisterScreenState();
}

class _StudentRegisterScreenState extends State<StudentRegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _studentNameController = TextEditingController();
  final _fatherNameController = TextEditingController();
  final _motherNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _schoolNameController = TextEditingController();
  final _schoolAddressController = TextEditingController();
  final _passwordController = TextEditingController(text: '123');

  String _gender = 'Male';
  String _curriculumType = 'General';
  String _selectedClass = 'Class 8';

  List<String> _classList = [
    'Play', 'Nursery', 'KG',
    'Class 1', 'Class 2', 'Class 3', 'Class 4', 'Class 5',
    'Class 6', 'Class 7', 'Class 8', 'Class 9', 'Class 10'
  ];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadClasses();
  }

  Future<void> _loadClasses() async {
    final classes = await AcademicService.getClasses(_curriculumType);
    if (classes.isNotEmpty && mounted) {
      setState(() {
        _classList = classes;
        _selectedClass = _classList.first;
      });
    }
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final result = await AuthService.registerStudent(
      studentName: _studentNameController.text.trim(),
      fatherName: _fatherNameController.text.trim(),
      motherName: _motherNameController.text.trim(),
      guardianPhone: _phoneController.text.trim(),
      guardianEmail: _emailController.text.trim(),
      address: _addressController.text.trim(),
      gender: _gender,
      curriculumType: _curriculumType,
      className: _selectedClass,
      schoolName: _schoolNameController.text.trim(),
      schoolAddress: _schoolAddressController.text.trim(),
      password: _passwordController.text,
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (result['success'] == true) {
      final user = result['user'];
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => StudentHomeScreen(user: user)),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Registration failed.'),
          backgroundColor: AppTheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Student Registration')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Student & Guardian Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _studentNameController,
                decoration: const InputDecoration(
                  labelText: 'Student Full Name *',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _fatherNameController,
                      decoration: const InputDecoration(labelText: "Father's Name"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _motherNameController,
                      decoration: const InputDecoration(labelText: "Mother's Name"),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Guardian Phone Number *',
                  hintText: 'e.g. 01700000000',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                validator: (v) => v == null || v.trim().isEmpty ? 'Guardian phone is required' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Guardian Email (Optional)',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _gender,
                      decoration: const InputDecoration(labelText: 'Gender'),
                      items: ['Male', 'Female', 'Other']
                          .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                          .toList(),
                      onChanged: (val) => setState(() => _gender = val!),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _curriculumType,
                      decoration: const InputDecoration(labelText: 'Curriculum'),
                      items: ['General', 'English Medium']
                          .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                      onChanged: (val) {
                        setState(() => _curriculumType = val!);
                        _loadClasses();
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                value: _classList.contains(_selectedClass) ? _selectedClass : _classList.firstOrNull,
                decoration: const InputDecoration(
                  labelText: 'Class / Grade *',
                  prefixIcon: Icon(Icons.class_outlined),
                ),
                items: _classList
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (val) => setState(() => _selectedClass = val!),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _schoolNameController,
                decoration: const InputDecoration(
                  labelText: 'School Name *',
                  prefixIcon: Icon(Icons.account_balance_outlined),
                ),
                validator: (v) => v == null || v.trim().isEmpty ? 'School name is required' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _schoolAddressController,
                decoration: const InputDecoration(labelText: 'School Address'),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Student Home Address',
                  prefixIcon: Icon(Icons.home_outlined),
                ),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Default Password',
                  hintText: '123',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
              ),
              const SizedBox(height: 28),
              ElevatedButton(
                onPressed: _isLoading ? null : _handleRegister,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text('Complete Student Registration'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
