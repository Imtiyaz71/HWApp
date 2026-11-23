import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/user_model.dart';
import '../../services/app_services.dart';
import '../../theme/app_theme.dart';

class AiSolverScreen extends StatefulWidget {
  final UserModel? user;
  const AiSolverScreen({super.key, this.user});

  @override
  State<AiSolverScreen> createState() => _AiSolverScreenState();
}

class _AiSolverScreenState extends State<AiSolverScreen> {
  final _questionController = TextEditingController();
  File? _selectedImage;
  bool _isLoading = false;
  String? _solution;
  final ImagePicker _picker = ImagePicker();

  late String _selectedClass;
  String _selectedSubject = 'Mathematics';
  List<String> _subjects = [];

  final List<String> _classes = [
    'Play', 'Nursery', 'KG',
    'Class 1', 'Class 2', 'Class 3', 'Class 4', 'Class 5',
    'Class 6', 'Class 7', 'Class 8', 'Class 9', 'Class 10'
  ];

  @override
  void initState() {
    super.initState();
    _selectedClass = widget.user?.className ?? 'Class 8';
    _loadSubjects();
  }

  Future<void> _loadSubjects() async {
    final list = await AcademicService.getSubjects(
      widget.user?.curriculumType ?? 'General',
      _selectedClass,
    );
    if (mounted) {
      setState(() {
        _subjects = list.isNotEmpty
            ? list
            : ['Mathematics', 'Science', 'Bangla', 'English', 'ICT'];
        if (!_subjects.contains(_selectedSubject)) {
          _selectedSubject = _subjects.first;
        }
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(source: source, imageQuality: 75);
    if (picked != null) {
      setState(() => _selectedImage = File(picked.path));
    }
  }

  Future<void> _solveProblem() async {
    final question = _questionController.text.trim();
    if (question.isEmpty && _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please write your question or snap a homework photo.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _solution = null;
    });

    String? base64Image;
    if (_selectedImage != null) {
      final bytes = await _selectedImage!.readAsBytes();
      base64Image = base64Encode(bytes);
    }

    final res = await AiService.solveHomework(
      questionText: question.isNotEmpty ? question : 'Solve this homework problem step by step with clear explanations.',
      subjectName: _selectedSubject,
      className: _selectedClass,
      imageBase64: base64Image,
      userApiKey: null, // Fully automated zero-key
    );

    setState(() => _isLoading = false);

    if (res['success'] == true) {
      setState(() {
        _solution = res['solution'];
      });
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res['message'] ?? 'Failed to get solution.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🤖 AI Homework Solver'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // AI Header Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, Color(0xFF00796B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    offset: const Offset(0, 4),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.auto_awesome, color: Colors.amber, size: 24),
                      SizedBox(width: 8),
                      Text(
                        'Instant AI Step-by-Step Solver',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Snap a photo or type any homework question. Gemini AI will explain the solution step by step in Bengali & English!',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Class & Subject Selector
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedClass,
                    decoration: const InputDecoration(labelText: 'Class / Grade'),
                    items: _classes
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _selectedClass = val);
                        _loadSubjects();
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _subjects.contains(_selectedSubject) ? _selectedSubject : null,
                    decoration: const InputDecoration(labelText: 'Subject'),
                    items: _subjects
                        .map((s) => DropdownMenuItem(value: s, child: Text(s, overflow: TextOverflow.ellipsis)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedSubject = val);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Question Text Input
            TextField(
              controller: _questionController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Type your homework question, math equation, or topic here...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 14),

            // Image Preview & Upload Buttons
            if (_selectedImage != null)
              Stack(
                alignment: Alignment.topRight,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(_selectedImage!, height: 180, width: double.infinity, fit: BoxFit.cover),
                  ),
                  IconButton(
                    icon: const CircleAvatar(
                      backgroundColor: Colors.red,
                      radius: 14,
                      child: Icon(Icons.close, color: Colors.white, size: 16),
                    ),
                    onPressed: () => setState(() => _selectedImage = null),
                  ),
                ],
              ),
            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Camera'),
                    onPressed: () => _pickImage(ImageSource.camera),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Gallery'),
                    onPressed: () => _pickImage(ImageSource.gallery),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Solve Button
            ElevatedButton.icon(
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Icon(Icons.psychology_outlined),
              label: Text(
                _isLoading ? 'Analyzing & Solving with AI...' : 'Solve with AI',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _isLoading ? null : _solveProblem,
            ),
            const SizedBox(height: 24),

            // Solution Result Box
            if (_solution != null) ...[
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.check_circle_outline, color: Colors.green),
                              SizedBox(width: 8),
                              Text('AI Solution & Explanation', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(Icons.copy, size: 20, color: AppColors.primary),
                            tooltip: 'Copy Solution',
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: _solution!));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Solution copied to clipboard!')),
                              );
                            },
                          ),
                        ],
                      ),
                      const Divider(),
                      const SizedBox(height: 8),
                      SelectableText(
                        _solution!,
                        style: const TextStyle(fontSize: 15, height: 1.5, color: Colors.black87),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
