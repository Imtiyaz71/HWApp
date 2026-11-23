import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  final UserModel user;
  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  void _showChangePasswordDialog() {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Row(
                children: [
                  Icon(Icons.lock_reset, color: AppColors.primary),
                  SizedBox(width: 8),
                  Text('Change Password'),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: oldPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Current Password'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: newPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'New Password (min 3 chars)'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: confirmPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Confirm New Password'),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isSubmitting ? null : () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          final oldP = oldPasswordController.text.trim();
                          final newP = newPasswordController.text.trim();
                          final confP = confirmPasswordController.text.trim();

                          if (oldP.isEmpty || newP.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please fill in both current and new password.')),
                            );
                            return;
                          }

                          if (newP != confP) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('New passwords do not match.')),
                            );
                            return;
                          }

                          setDialogState(() => isSubmitting = true);
                          final res = await AuthService.changePassword(
                            oldPassword: oldP,
                            newPassword: newP,
                          );
                          setDialogState(() => isSubmitting = false);

                          if (res['success'] == true) {
                            Navigator.pop(ctx);
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(res['message'] ?? 'Password changed successfully!'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          } else {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(res['message'] ?? 'Failed to change password.'),
                                  backgroundColor: AppColors.error,
                                ),
                              );
                            }
                          }
                        },
                  child: isSubmitting
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Update Password'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to log out of your account?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await AuthService.logout();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final u = widget.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('👤 Profile & Account'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // User Avatar & Name Card
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 46,
                    backgroundColor: AppColors.primary.withOpacity(0.15),
                    child: Text(
                      u.name.isNotEmpty ? u.name[0].toUpperCase() : 'U',
                      style: const TextStyle(fontSize: 38, fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(u.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    decoration: BoxDecoration(
                      color: u.isTeacher ? Colors.orange.shade50 : Colors.teal.shade50,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: u.isTeacher ? Colors.orange : Colors.teal),
                    ),
                    child: Text(
                      u.role.toUpperCase(),
                      style: TextStyle(
                        color: u.isTeacher ? Colors.orange.shade900 : Colors.teal.shade900,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 26),

            // Profile Info List
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  children: [
                    _buildInfoTile(Icons.phone_outlined, 'Phone', u.phone),
                    if (u.email != null && u.email!.isNotEmpty) ...[
                      const Divider(height: 1),
                      _buildInfoTile(Icons.email_outlined, 'Email', u.email!),
                    ],
                    if (u.schoolName != null && u.schoolName!.isNotEmpty) ...[
                      const Divider(height: 1),
                      _buildInfoTile(Icons.school_outlined, 'Institution / School', u.schoolName!),
                    ],
                    if (u.className != null && u.className!.isNotEmpty) ...[
                      const Divider(height: 1),
                      _buildInfoTile(Icons.class_outlined, 'Class / Grade', u.className!),
                    ],
                    if (u.curriculumType != null && u.curriculumType!.isNotEmpty) ...[
                      const Divider(height: 1),
                      _buildInfoTile(Icons.auto_stories_outlined, 'Curriculum', u.curriculumType!),
                    ],
                    if (u.specialistSubjects != null && u.specialistSubjects!.isNotEmpty) ...[
                      const Divider(height: 1),
                      _buildInfoTile(Icons.star_outline, 'Specialist Subjects', u.specialistSubjects!.join(', ')),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Actions Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.lock_outline, color: AppColors.primary),
                    title: const Text('Change Password', style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: const Text('Update your login password'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _showChangePasswordDialog,
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: const Text('Log Out', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
                    trailing: const Icon(Icons.chevron_right, color: Colors.red),
                    onTap: _handleLogout,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'OurHomeworks Platform v2.0 • Clean Architecture\nBuilt with ❤️ for Bangladesh Education',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      subtitle: Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black87)),
    );
  }
}
