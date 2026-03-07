import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/order_model.dart';
import '../services/api_service.dart';
import 'auth_provider.dart';

final orderProvider = StateNotifierProvider<OrderNotifier, List<OrderModel>>((ref) {
  return OrderNotifier(ref.watch(apiServiceProvider));
});

final selectedOrderProvider = StateProvider<OrderModel?>((ref) => null);

class OrderNotifier extends StateNotifier<List<OrderModel>> {
  final ApiService _apiService;

  OrderNotifier(this._apiService) : super([]);

  Future<void> fetchOrders() async {
    try {
      final response = await _apiService.get('/orders');
      // If response is paginated (from Laravel), it might be inside 'data'
      final List<dynamic> data = response is Map ? response['data'] : response;
      state = data.map((item) => OrderModel.fromJson(item)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<OrderModel> createOrder(Map<String, dynamic> data) async {
    try {
      final response = await _apiService.post('/orders', data);
      final newOrder = OrderModel.fromJson(response['order'] ?? response);
      state = [newOrder, ...state];
      return newOrder;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> cancelOrder(int id) async {
    try {
      final response = await _apiService.post('/orders/$id/cancel', {});
      final updatedOrder = OrderModel.fromJson(response['order'] ?? response);
      state = [
        for (final order in state)
          if (order.id == id) updatedOrder else order
      ];
    } catch (e) {
      rethrow;
    }
  }

  OrderModel? getOrderById(int id) {
    try {
      return state.firstWhere((order) => order.id == id);
    } catch (e) {
      return null;
    }
  }
}
