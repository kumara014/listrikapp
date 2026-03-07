import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../../data/providers/notification_provider.dart';
import '../widgets/empty_state.dart';
import '../widgets/loading_shimmer.dart';

class NotificationScreen extends ConsumerStatefulWidget {
  const NotificationScreen({super.key});

  @override
  ConsumerState<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends ConsumerState<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(notificationProvider.notifier).fetchNotifications());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notificationProvider);
    final notifications = state.items;

    return Scaffold(
      backgroundColor: AppColors.gray50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.gray800, size: 18),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          '🔔 Notifikasi',
          style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.gray800),
        ),
        actions: [
          if (notifications.any((n) => n['read_at'] == null))
            TextButton(
              onPressed: () => ref.read(notificationProvider.notifier).markAllAsRead(),
              child: const Text('Tandai semua dibaca', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.blue500)),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: state.isLoading
          ? const LoadingShimmer(count: 6)
          : notifications.isEmpty
              ? const EmptyState(
                  icon: Icons.notifications_none_outlined,
                  title: 'Belum Ada Notifikasi',
                  subtitle: 'Semua kabar terbaru tentang pesananmu akan muncul di sini.',
                )
              : RefreshIndicator(
                  onRefresh: () => ref.read(notificationProvider.notifier).fetchNotifications(),
                  child: ListView.builder(
                    itemCount: notifications.length,
                    itemBuilder: (context, index) => _buildNotifItem(notifications[index]),
                  ),
                ),
    );
  }

  Widget _buildNotifItem(Map<String, dynamic> n) {
    Color iconBg = AppColors.blue100;
    Color iconFg = AppColors.blue500;
    IconData icon = Icons.info_outline;

    if (n['type'] == 'success') {
      iconBg = AppColors.green100;
      iconFg = AppColors.green500;
      icon = Icons.verified_user_outlined;
    } else if (n['type'] == 'progress') {
      iconBg = AppColors.orange100;
      iconFg = AppColors.orange500;
      icon = Icons.bolt;
    }

    final bool unread = n['read_at'] == null;
    final DateTime createdAt = DateTime.parse(n['created_at']);
    final String timeAgo = _getTimeAgo(createdAt);

    return InkWell(
      onTap: () {
        if (unread) {
          ref.read(notificationProvider.notifier).markAsRead(n['id']);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: unread ? AppColors.blue50.withOpacity(0.5) : Colors.white,
          border: Border(bottom: const BorderSide(color: AppColors.gray100), left: BorderSide(color: unread ? AppColors.blue500 : Colors.transparent, width: 3)),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: iconFg, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(n['title'], style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.gray800)),
                  const SizedBox(height: 4),
                  Text(n['message'], style: const TextStyle(fontSize: 11, color: AppColors.gray600, height: 1.4)),
                  const SizedBox(height: 6),
                  Text(timeAgo, style: const TextStyle(fontSize: 10, color: AppColors.gray400, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            if (unread)
              Container(
                margin: const EdgeInsets.only(top: 4),
                width: 8,
                height: 8,
                decoration: const BoxDecoration(color: AppColors.blue500, shape: BoxShape.circle),
              ),
          ],
        ),
      ),
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final Duration diff = DateTime.now().difference(dateTime);
    if (diff.inDays > 0) return '${diff.inDays} hari lalu';
    if (diff.inHours > 0) return '${diff.inHours} jam lalu';
    if (diff.inMinutes > 0) return '${diff.inMinutes} menit lalu';
    return 'baru saja';
  }
}
