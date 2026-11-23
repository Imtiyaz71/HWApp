import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../api/api_constants.dart';
import '../../models/problem_model.dart';
import '../../models/user_model.dart';
import '../../services/app_services.dart';
import '../../theme/app_theme.dart';
import '../ai/ai_solver_screen.dart';
import '../games/brain_games_screen.dart';
import '../notifications/notifications_screen.dart';
import '../problems/create_problem_screen.dart';
import '../problems/problem_details_screen.dart';
import '../profile/profile_screen.dart';
import '../tuition/tuition_board_screen.dart';

class StudentHomeScreen extends StatefulWidget {
  final UserModel user;
  const StudentHomeScreen({super.key, required this.user});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  int _currentBottomNavIndex = 0;

  List<HomeworkProblemModel> _problems = [];
  List<String> _subjects = [];
  String? _selectedSubject;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSubjects();
    _loadFeed();
  }

  Future<void> _loadSubjects() async {
    final list = await AcademicService.getSubjects(
      widget.user.curriculumType ?? 'General',
      widget.user.className ?? 'Class 8',
    );
    if (mounted) {
      setState(() => _subjects = list);
    }
  }

  Future<void> _loadFeed() async {
    setState(() => _isLoading = true);
    final list = await ProblemService.getFeed(
      subjectName: _selectedSubject,
      className: widget.user.className,
    );
    if (mounted) {
      setState(() {
        _problems = list;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildSocialFeedPage(),
      TuitionBoardScreen(user: widget.user),
      AiSolverScreen(user: widget.user),
      BrainGamesScreen(userClass: widget.user.className),
      ProfileScreen(user: widget.user),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentBottomNavIndex,
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentBottomNavIndex,
        onTap: (index) => setState(() => _currentBottomNavIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey.shade600,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dynamic_feed),
            activeIcon: Icon(Icons.dynamic_feed, color: AppColors.primary),
            label: 'Feed',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school_outlined),
            activeIcon: Icon(Icons.school, color: AppColors.primary),
            label: 'Tuition',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.psychology_outlined),
            activeIcon: Icon(Icons.psychology, color: AppColors.primary),
            label: 'AI Solver',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sports_esports_outlined),
            activeIcon: Icon(Icons.sports_esports, color: AppColors.primary),
            label: 'Brain Games',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person, color: AppColors.primary),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildSocialFeedPage() {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset('assets/images/logo.png', fit: BoxFit.contain),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Hi, ${widget.user.name}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text('${widget.user.className ?? "Class"} • ${widget.user.curriculumType ?? "General"}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen())),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_a_photo, color: Colors.white),
        label: const Text('Ask Homework', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        onPressed: () async {
          final res = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => CreateProblemScreen(user: widget.user)),
          );
          if (res == true) _loadFeed();
        },
      ),
      body: RefreshIndicator(
        onRefresh: _loadFeed,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // 1. Facebook-style "What's on your mind?" create post bar
              _buildCreatePostCard(),

              // 2. Horizontal Subject Pills
              _buildSubjectFilterList(),

              // 3. Social Feed Problem Cards
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.all(40),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_problems.isEmpty)
                _buildEmptyFeedPlaceholder()
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _problems.length,
                  itemBuilder: (context, index) {
                    final p = _problems[index];
                    return _buildSocialProblemCard(p);
                  },
                ),
              const SizedBox(height: 70),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCreatePostCard() {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primary.withOpacity(0.15),
                child: Text(
                  widget.user.name.isNotEmpty ? widget.user.name[0].toUpperCase() : 'S',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    final res = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => CreateProblemScreen(user: widget.user)),
                    );
                    if (res == true) _loadFeed();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Text(
                      'হোমওয়ার্কে আটকে গেছো? প্রশ্ন করো...',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildQuickPostAction(Icons.photo_camera_back, 'Photo / Math', Colors.green, () async {
                final res = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => CreateProblemScreen(user: widget.user)),
                );
                if (res == true) _loadFeed();
              }),
              _buildQuickPostAction(Icons.auto_awesome, 'AI Solve', Colors.orange, () {
                setState(() => _currentBottomNavIndex = 2);
              }),
              _buildQuickPostAction(Icons.school, 'Find Tuition', Colors.blue, () {
                setState(() => _currentBottomNavIndex = 1);
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickPostAction(IconData icon, String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87)),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectFilterList() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: _subjects.length + 1,
        itemBuilder: (context, i) {
          final isAll = i == 0;
          final subj = isAll ? 'All Subjects' : _subjects[i - 1];
          final isSelected = isAll ? _selectedSubject == null : _selectedSubject == subj;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(subj),
              selected: isSelected,
              selectedColor: AppColors.primary,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              onSelected: (val) {
                setState(() => _selectedSubject = isAll ? null : subj);
                _loadFeed();
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildSocialProblemCard(HomeworkProblemModel p) {
    final dateFormat = DateFormat('dd MMM, hh:mm a');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Social Header
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.primary.withOpacity(0.12),
                  child: Text(
                    p.studentName.isNotEmpty ? p.studentName[0].toUpperCase() : 'S',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.studentName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '${p.className} • ${p.subjectName}',
                              style: TextStyle(color: Colors.blue.shade800, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(dateFormat.format(p.createdAt), style: const TextStyle(color: Colors.grey, fontSize: 11)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Problem Title & Description
            Text(
              p.title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 6),
            Text(
              p.description,
              style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.4),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),

            // Optional Image Attachment
            if (p.imageUrl != null && p.imageUrl!.isNotEmpty) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  ApiConstants.imageBaseUrl + p.imageUrl!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const SizedBox(),
                ),
              ),
            ],

            const Divider(height: 24),

            // Social Interaction Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.chat_bubble_outline, size: 18, color: Colors.grey),
                    const SizedBox(width: 6),
                    Text('${p.totalReplies} Solutions', style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w600)),
                  ],
                ),
                Row(
                  children: [
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      icon: const Icon(Icons.reply, size: 16, color: Colors.white),
                      label: const Text('View & Reply', style: TextStyle(color: Colors.white, fontSize: 12)),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => ProblemDetailsScreen(problemId: p.id)),
                      ).then((_) => _loadFeed()),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyFeedPlaceholder() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            const Icon(Icons.menu_book, size: 60, color: Colors.grey),
            const SizedBox(height: 12),
            const Text('No homework questions posted yet!', style: TextStyle(fontSize: 16, color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            const Text('Be the first to ask your question!', style: TextStyle(fontSize: 13, color: Colors.grey)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Ask Homework Problem'),
              onPressed: () async {
                final res = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => CreateProblemScreen(user: widget.user)),
                );
                if (res == true) _loadFeed();
              },
            ),
          ],
        ),
      ),
    );
  }
}
