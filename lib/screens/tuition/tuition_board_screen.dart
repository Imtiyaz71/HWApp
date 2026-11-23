import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/problem_model.dart';
import '../../models/user_model.dart';
import '../../services/app_services.dart';
import '../../theme/app_theme.dart';

class TuitionBoardScreen extends StatefulWidget {
  final UserModel user;
  const TuitionBoardScreen({super.key, required this.user});

  @override
  State<TuitionBoardScreen> createState() => _TuitionBoardScreenState();
}

class _TuitionBoardScreenState extends State<TuitionBoardScreen> {
  List<TuitionPostModel> _posts = [];
  bool _isLoading = true;
  String _selectedClassFilter = 'All';

  final List<String> _filterClasses = [
    'All', 'Play', 'Nursery', 'KG',
    'Class 1', 'Class 2', 'Class 3', 'Class 4', 'Class 5',
    'Class 6', 'Class 7', 'Class 8', 'Class 9', 'Class 10'
  ];

  @override
  void initState() {
    super.initState();
    _loadTuitions();
  }

  Future<void> _loadTuitions() async {
    setState(() => _isLoading = true);
    final list = await TuitionApiService.getTuitionFeed(
      className: _selectedClassFilter == 'All' ? null : _selectedClassFilter,
    );
    if (mounted) {
      setState(() {
        _posts = list;
        _isLoading = false;
      });
    }
  }

  void _showCreateTuitionDialog() {
    final classController = TextEditingController(text: widget.user.className ?? 'Class 8');
    final subjectsController = TextEditingController();
    final locationController = TextEditingController(text: widget.user.schoolAddress ?? '');
    final salaryController = TextEditingController();
    final daysController = TextEditingController(text: '3 days/week');
    final descController = TextEditingController();
    String tuitionType = 'Home Tuition';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text('📢 Post Tuition Requirement', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary)),
                    const SizedBox(height: 16),
                    TextField(
                      controller: classController,
                      decoration: const InputDecoration(labelText: 'Class / Grade (e.g. Class 9, KG)'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: subjectsController,
                      decoration: const InputDecoration(labelText: 'Subjects (e.g. Math, Physics, English)'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: locationController,
                      decoration: const InputDecoration(labelText: 'Area / Location (e.g. Mirpur, Dhaka)'),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: salaryController,
                            decoration: const InputDecoration(labelText: 'Budget / Salary (e.g. 5000 Tk)'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: daysController,
                            decoration: const InputDecoration(labelText: 'Days / Week'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: tuitionType,
                      decoration: const InputDecoration(labelText: 'Tuition Type'),
                      items: ['Home Tuition', 'Online Tuition', 'Batch / Coaching']
                          .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                          .toList(),
                      onChanged: (val) => setModalState(() => tuitionType = val!),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descController,
                      maxLines: 2,
                      decoration: const InputDecoration(labelText: 'Additional Details / Requirements'),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        if (subjectsController.text.trim().isEmpty || locationController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please fill in subjects and location.')),
                          );
                          return;
                        }
                        Navigator.pop(ctx);
                        final success = await TuitionApiService.createTuition(
                          className: classController.text.trim(),
                          subjects: subjectsController.text.trim(),
                          location: locationController.text.trim(),
                          salary: salaryController.text.trim(),
                          daysPerWeek: daysController.text.trim(),
                          tuitionType: tuitionType,
                          description: descController.text.trim(),
                        );
                        if (success) {
                          _loadTuitions();
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Tuition requirement posted successfully!')),
                            );
                          }
                        }
                      },
                      child: const Text('Post Requirement'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showApplyDialog(TuitionPostModel post) {
    final qualController = TextEditingController();
    final expController = TextEditingController();
    final msgController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Apply for ${post.className} (${post.subjects})'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: qualController,
                  decoration: const InputDecoration(labelText: 'Your Educational Qualification (e.g. BSc in Math, DU)'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: expController,
                  decoration: const InputDecoration(labelText: 'Tuition Experience (e.g. 3 Years)'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: msgController,
                  maxLines: 2,
                  decoration: const InputDecoration(labelText: 'Message to Guardian / Student'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                final ok = await TuitionApiService.applyTuition(
                  post.id,
                  qualifications: qualController.text.trim(),
                  experience: expController.text.trim(),
                  message: msgController.text.trim(),
                );
                if (ok && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Application submitted to guardian! 🎉')),
                  );
                  _loadTuitions();
                } else if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Application failed or already applied.')),
                  );
                }
              },
              child: const Text('Submit Application'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTeacher = widget.user.isTeacher;
    final dateFormat = DateFormat('dd MMM, yyyy');

    return Scaffold(
      appBar: AppBar(
        title: const Text('🎓 Tuition Matchmaker'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: SizedBox(
            height: 44,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _filterClasses.length,
              itemBuilder: (context, i) {
                final c = _filterClasses[i];
                final isSelected = _selectedClassFilter == c;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(c),
                    selected: isSelected,
                    selectedColor: Colors.white,
                    checkmarkColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: isSelected ? AppColors.primary : Colors.white70,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    backgroundColor: Colors.white.withOpacity(0.15),
                    onSelected: (val) {
                      setState(() => _selectedClassFilter = c);
                      _loadTuitions();
                    },
                  ),
                );
              },
            ),
          ),
        ),
      ),
      floatingActionButton: !isTeacher
          ? FloatingActionButton.extended(
              onPressed: _showCreateTuitionDialog,
              icon: const Icon(Icons.add),
              label: const Text('Need Tuition?'),
            )
          : null,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _posts.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.school_outlined, size: 70, color: Colors.grey),
                      const SizedBox(height: 12),
                      const Text('No tuition requirements posted yet.', style: TextStyle(fontSize: 16, color: AppColors.textSecondary)),
                      if (!isTeacher) ...[
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.add),
                          label: const Text('Post Tuition Need'),
                          onPressed: _showCreateTuitionDialog,
                        ),
                      ],
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadTuitions,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(14),
                    itemCount: _posts.length,
                    itemBuilder: (context, i) {
                      final post = _posts[i];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundColor: AppColors.primary.withOpacity(0.15),
                                    child: const Icon(Icons.person, color: AppColors.primary),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(post.posterName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                        Text(
                                          '${post.className} • ${post.curriculumType}',
                                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.green.shade50,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.green.shade300),
                                    ),
                                    child: Text(
                                      post.tuitionType,
                                      style: TextStyle(color: Colors.green.shade800, fontSize: 11, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(height: 24),
                              Row(
                                children: [
                                  const Icon(Icons.menu_book, size: 18, color: AppColors.primary),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Subjects: ${post.subjects}',
                                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.location_on_outlined, size: 18, color: Colors.redAccent),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text('Location: ${post.location}', style: const TextStyle(color: Colors.black87)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  if (post.salary != null && post.salary!.isNotEmpty) ...[
                                    const Icon(Icons.payments_outlined, size: 18, color: Colors.green),
                                    const SizedBox(width: 6),
                                    Text('Salary: ${post.salary}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                                    const SizedBox(width: 16),
                                  ],
                                  if (post.daysPerWeek != null && post.daysPerWeek!.isNotEmpty) ...[
                                    const Icon(Icons.calendar_today_outlined, size: 16, color: Colors.blueGrey),
                                    const SizedBox(width: 6),
                                    Text(post.daysPerWeek!, style: const TextStyle(color: Colors.blueGrey)),
                                  ],
                                ],
                              ),
                              if (post.description != null && post.description!.isNotEmpty) ...[
                                const SizedBox(height: 10),
                                Text(
                                  post.description!,
                                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                                ),
                              ],
                              const SizedBox(height: 14),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '📅 Posted: ${dateFormat.format(post.createdAt)}',
                                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                                  ),
                                  if (isTeacher)
                                    ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: post.hasApplied ? Colors.grey : AppColors.primary,
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      ),
                                      icon: Icon(post.hasApplied ? Icons.check : Icons.send, size: 16),
                                      label: Text(post.hasApplied ? 'Applied' : 'Apply Now'),
                                      onPressed: post.hasApplied ? null : () => _showApplyDialog(post),
                                    )
                                  else
                                    Text(
                                      '${post.totalApplicants} Applicant(s)',
                                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
