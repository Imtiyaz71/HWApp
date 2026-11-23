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
import '../problems/problem_details_screen.dart';
import '../profile/profile_screen.dart';
import '../tuition/tuition_board_screen.dart';

class TeacherHomeScreen extends StatefulWidget {
  final UserModel user;
  const TeacherHomeScreen({super.key, required this.user});

  @override
  State<TeacherHomeScreen> createState() => _TeacherHomeScreenState();
}

class _TeacherHomeScreenState extends State<TeacherHomeScreen> {
  int _currentBottomNavIndex = 0;

  List<HomeworkProblemModel> _problems = [];
  String? _selectedSubject;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    if (widget.user.specialistSubjects != null && widget.user.specialistSubjects!.isNotEmpty) {
      _selectedSubject = widget.user.specialistSubjects!.first;
    }
    _loadFeed();
  }

  Future<void> _loadFeed() async {
    setState(() => _isLoading = true);
    final list = await ProblemService.getFeed(
      subjectName: _selectedSubject,
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
      _buildTeacherFeedPage(),
      TuitionBoardScreen(user: widget.user),
      AiSolverScreen(user: widget.user),
      const BrainGamesScreen(userClass: 'Teacher'),
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
            icon: Icon(Icons.feed_outlined),
            activeIcon: Icon(Icons.feed, color: AppColors.primary),
            label: 'Questions',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.work_outline),
            activeIcon: Icon(Icons.work, color: AppColors.primary),
            label: 'Tuition Jobs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.psychology_outlined),
            activeIcon: Icon(Icons.psychology, color: AppColors.primary),
            label: 'AI Helper',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sports_esports_outlined),
            activeIcon: Icon(Icons.sports_esports, color: AppColors.primary),
            label: 'Brain Arena',
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

  Widget _buildTeacherFeedPage() {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset('assets/images/logo.png', fit: BoxFit.contain),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Teacher ${widget.user.name}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text(
              widget.user.specialistSubjects?.isNotEmpty == true
                  ? 'Specialist: ${widget.user.specialistSubjects!.join(", ")}'
                  : 'Teacher Portal',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen())),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadFeed,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // Teacher Opportunities Banner
              _buildTeacherWelcomeCard(),

              // Subject Filter Chips
              _buildSubjectFilterList(),

              // Student Homework Problem Cards
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
                    return _buildTeacherProblemCard(p);
                  },
                ),
              const SizedBox(height: 70),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTeacherWelcomeCard() {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange.shade700, Colors.deepOrange.shade500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 24,
            backgroundColor: Colors.white,
            child: Icon(Icons.volunteer_activism, color: Colors.deepOrange, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Solve Doubts & Earn Reputation!',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 4),
                Text(
                  'Help students with voice explanations & picture solutions. Check "Tuition Jobs" to apply for new home tuitions.',
                  style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectFilterList() {
    final subjects = widget.user.specialistSubjects ?? ['Mathematics', 'Science', 'English', 'Bangla'];

    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: subjects.length + 1,
        itemBuilder: (context, i) {
          final isAll = i == 0;
          final subj = isAll ? 'All Feed' : subjects[i - 1];
          final isSelected = isAll ? _selectedSubject == null : _selectedSubject == subj;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(subj),
              selected: isSelected,
              selectedColor: Colors.deepOrange,
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

  Widget _buildTeacherProblemCard(HomeworkProblemModel p) {
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
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
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
                      Text('${p.className} • ${p.subjectName} • ${dateFormat.format(p.createdAt)}', style: const TextStyle(color: Colors.grey, fontSize: 11)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.amber.shade400),
                  ),
                  child: Text(
                    '${p.totalReplies} Solutions',
                    style: TextStyle(color: Colors.amber.shade900, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(p.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 6),
            Text(
              p.description,
              style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.4),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
            if (p.imageUrl != null && p.imageUrl!.isNotEmpty) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  ApiConstants.imageBaseUrl + p.imageUrl!,
                  height: 190,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const SizedBox(),
                ),
              ),
            ],
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.mic_none, size: 18, color: Colors.grey),
                    SizedBox(width: 4),
                    Text('Voice & Pic Supported', style: TextStyle(color: Colors.grey, fontSize: 11)),
                  ],
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  icon: const Icon(Icons.edit_note, size: 18),
                  label: const Text('Give Solution', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ProblemDetailsScreen(problemId: p.id)),
                  ).then((_) => _loadFeed()),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyFeedPlaceholder() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(40),
        child: Column(
          children: [
            Icon(Icons.check_circle_outline, size: 60, color: Colors.green),
            SizedBox(height: 12),
            Text('All questions are answered!', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 6),
            Text('New questions from students will appear here in real-time.', style: TextStyle(color: Colors.grey, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
