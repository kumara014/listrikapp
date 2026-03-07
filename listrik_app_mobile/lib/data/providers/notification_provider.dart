import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import 'auth_provider.dart';

final notificationProvider = StateNotifierProvider<NotificationNotifier, NotificationState>((ref) {
  return NotificationNotifier(ref.watch(apiServiceProvider));
});

class NotificationState {
  final List<dynamic> items;
  final bool isLoading;

  NotificationState({this.items = const [], this.isLoading = false});

  NotificationState copyWith({List<dynamic>? items, bool? isLoading}) {
    return NotificationState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  int get unreadCount => items.where((i) => i['read_at'] == null).length;
}

class NotificationNotifier extends StateNotifier<NotificationState> {
  final ApiService _apiService;

  NotificationNotifier(this._apiService) : super(NotificationState());

  Future<void> fetchNotifications() async {
    state = state.copyWith(isLoading: true);
    try {
      final response = await _apiService.get('/notifications');
      state = state.copyWith(items: response['data'], isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  Future<void> markAsRead(int id) async {
    try {
      await _apiService.post('/notifications/$id/read', {});
      await fetchNotifications();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _apiService.post('/notifications/read-all', {});
      await fetchNotifications();
    } catch (e) {
      rethrow;
    }
  }
}
