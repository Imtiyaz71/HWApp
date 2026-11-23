import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/notification_model.dart';
import '../../services/app_services.dart';
import '../../theme/app_theme.dart';
import '../problems/problem_details_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<NotificationModel> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    final list = await NotificationService.getNotifications();
    if (mounted) {
      setState(() {
        _notifications = list;
        _isLoading = false;
      });
    }
  }

  Future<void> _handleTapNotification(NotificationModel item) async {
    if (!item.isRead) {
      await NotificationService.markAsRead(item.id);
      setState(() {
        item.isRead = true;
      });
    }

    if (item.relatedProblemId != null && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProblemDetailsScreen(problemId: item.relatedProblemId!),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM, hh:mm a');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadNotifications,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _notifications.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.notifications_none, size: 64, color: AppColors.textSecondary),
                        SizedBox(height: 12),
                        Text(
                          'No notifications yet',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: _notifications.length,
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (ctx, idx) {
                      final notif = _notifications[idx];
                      return ListTile(
                        tileColor: notif.isRead ? Colors.transparent : AppColors.primary.withOpacity(0.05),
                        leading: CircleAvatar(
                          backgroundColor: notif.isRead
                              ? Colors.grey.shade200
                              : AppColors.primary.withOpacity(0.2),
                          child: Icon(
                            notif.type == 'Reply'
                                ? Icons.reply
                                : notif.type == 'Like'
                                    ? Icons.favorite
                                    : Icons.announcement,
                            color: notif.isRead ? Colors.grey : AppColors.primary,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          notif.title,
                          style: TextStyle(
                            fontWeight: notif.isRead ? FontWeight.normal : FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              notif.message,
                              style: const TextStyle(fontSize: 13),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              dateFormat.format(notif.createdAt),
                              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                        onTap: () => _handleTapNotification(notif),
                      );
                    },
                  ),
      ),
    );
  }
}
