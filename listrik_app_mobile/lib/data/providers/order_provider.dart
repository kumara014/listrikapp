import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/order_model.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import 'auth_provider.dart';

class OrderState {
  final List<OrderModel> orders;
  final bool isLoading;
  final String? error;

  OrderState({
    this.orders = const [],
    this.isLoading = false,
    this.error,
  });

  OrderState copyWith({
    List<OrderModel>? orders,
    bool? isLoading,
    String? error,
  }) {
    return OrderState(
      orders: orders ?? this.orders,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

final orderProvider = StateNotifierProvider<OrderNotifier, OrderState>(
  (ref) {
    final apiService = ref.watch(apiServiceProvider);
    final user = ref.watch(authProvider);
    return OrderNotifier(apiService, user);
  },
);

final selectedOrderProvider = StateProvider<OrderModel?>((ref) => null);

class OrderNotifier extends StateNotifier<OrderState> {
  final ApiService _apiService;
  final UserModel? _user;

  OrderNotifier(this._apiService, this._user) : super(OrderState());

  Future<void> fetchOrders({bool? isPartner}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final effectiveIsPartner = isPartner ?? (_user?.isPartner ?? false);
      final endpoint = effectiveIsPartner ? '/partner/orders' : '/orders';
      final response = await _apiService.get(endpoint);
      
      List<dynamic> data = [];
      if (response is List) {
        data = response;
      } else if (response is Map) {
        data = response['data'] ?? response['orders'] ?? [];
      }
      
      final orders = data.map((item) => OrderModel.fromJson(item)).toList();
      state = state.copyWith(orders: orders, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<OrderModel> createOrder(Map<String, dynamic> data) async {
    try {
      final response = await _apiService.post('/orders', data);
      final newOrder = OrderModel.fromJson(response['order'] ?? response);
      state = state.copyWith(orders: [newOrder, ...state.orders]);
      return newOrder;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> cancelOrder(int id) async {
    try {
      final response = await _apiService.post('/orders/$id/cancel', {});
      final updatedOrder = OrderModel.fromJson(response['order'] ?? response);
      
      final updatedOrders = state.orders.map((order) {
        return order.id == id ? updatedOrder : order;
      }).toList();
      
      state = state.copyWith(orders: updatedOrders);
    } catch (e) {
      rethrow;
    }
  }

  OrderModel? getOrderById(int id) {
    try {
      return state.orders.firstWhere((order) => order.id == id);
    } catch (e) {
      return null;
    }
  }
}
