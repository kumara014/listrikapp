import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/order_model.dart';
import '../../../data/providers/order_provider.dart';
import '../../widgets/empty_state.dart';

class OrderListScreen extends ConsumerWidget {
  const OrderListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(orderProvider);

    return Scaffold(
      backgroundColor: AppColors.gray50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pesanan Saya',
              style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.gray800),
            ),
            Text(
              '${orders.length} total pesanan',
              style: const TextStyle(fontSize: 11, color: AppColors.gray400, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
      body: orders.isEmpty
          ? const EmptyState(
              icon: Icons.inventory_2_outlined,
              title: 'Belum ada pesanan',
              subtitle: 'Kamu belum memiliki riwayat pesanan instalasi listrik.',
            )
          : RefreshIndicator(
              onRefresh: () => ref.read(orderProvider.notifier).fetchOrders(),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: orders.length,
                itemBuilder: (context, index) => _buildOrderCard(context, orders[index]),
              ),
            ),
    );
  }

  Widget _buildOrderCard(BuildContext context, OrderModel order) {
    return GestureDetector(
      onTap: () => context.push('/tracking/${order.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.gray100),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(order.agendaNumber, style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.gray800)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: order.statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(100)),
                  child: Text(
                    order.statusLabel.toUpperCase(),
                    style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 9, fontWeight: FontWeight.w800, color: order.statusColor),
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(height: 1, color: AppColors.gray100),
            ),
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(color: AppColors.blue50, borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.description_outlined, color: AppColors.blue500, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(order.serviceTypeLabel, style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.gray800)),
                      Text('${order.powerCapacity} Watt · ${order.installationType}', style: const TextStyle(fontSize: 10, color: AppColors.gray400)),
                    ],
                  ),
                ),
                Text(
                  order.formattedPrice,
                  style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.blue500),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
