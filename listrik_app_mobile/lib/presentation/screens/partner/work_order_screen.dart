import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/order_model.dart';
import '../../../data/providers/order_provider.dart';
import '../../../data/providers/partner_provider.dart';
import 'package:listrik_app_mobile/presentation/widgets/app_snackbar.dart';

class WorkOrderScreen extends ConsumerStatefulWidget {
  final String id;
  const WorkOrderScreen({super.key, required this.id});

  @override
  ConsumerState<WorkOrderScreen> createState() => _WorkOrderScreenState();
}

class _WorkOrderScreenState extends ConsumerState<WorkOrderScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(orderProvider.notifier).fetchOrders());
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final orderId = int.tryParse(widget.id);
    final order = ref.watch(orderProvider.notifier).getOrderById(orderId ?? 0);

    if (order == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: AppColors.gray50,
      body: Column(
        children: [
          _buildWodHeader(order),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                children: [
                  _buildCustomerCard(order),
                  const SizedBox(height: 12),
                  _buildWorkDetailCard(order),
                  const SizedBox(height: 12),
                  _buildMapPreview(),
                  const SizedBox(height: 12),
                  _buildStatusUpdateCard(order),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWodHeader(OrderModel order) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF064E3B), AppColors.green500],
        ),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: const Row(
              children: [
                Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 14),
                SizedBox(width: 10),
                Text('Detail Pekerjaan', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.15)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(order.agendaNumber, style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 0.5)),
                const SizedBox(height: 14),
                Row(
                  children: [
                    _buildHeaderTag(order.serviceTypeLabel),
                    const SizedBox(width: 8),
                    _buildHeaderTag(order.statusLabel.toUpperCase(), isStatus: true, color: order.statusColor),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderTag(String text, {bool isStatus = false, Color? color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isStatus ? (color ?? Colors.green).withOpacity(0.35) : Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(text, style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white)),
    );
  }

  Widget _buildCustomerCard(OrderModel order) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gray100),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: AppColors.blue50, borderRadius: BorderRadius.circular(14)),
            child: Center(
              child: Text(
                'CU',
                style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.blue500),
              ),
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Customer Name', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.gray800)),
                Text('0812-3456-7890', style: TextStyle(fontSize: 11, color: AppColors.gray400)),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => AppSnackbar.showSuccess(context, 'Membuka WhatsApp...'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(color: const Color(0xFF25D366), borderRadius: BorderRadius.circular(10)),
              child: const Row(
                children: [
                  Icon(Icons.chat_bubble_outline, color: Colors.white, size: 14),
                  SizedBox(width: 6),
                  Text('WA', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkDetailCard(OrderModel order) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gray100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.description_outlined, color: AppColors.green500, size: 16),
              SizedBox(width: 8),
              Text('Detail Pekerjaan', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.gray800)),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Jenis Layanan', order.serviceTypeLabel),
          _buildInfoRow('Daya Listrik', '${order.powerCapacity} Watt'),
          _buildInfoRow('Jenis Instalasi', order.installationType),
          _buildInfoRow('Alamat', order.address),
          const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Divider(height: 1, color: AppColors.gray50)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Pendapatan', style: TextStyle(fontSize: 10, color: AppColors.gray400, fontWeight: FontWeight.w500)),
              Text(order.formattedPrice, style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.green500)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 10, color: AppColors.gray400, fontWeight: FontWeight.w500)),
          const SizedBox(width: 20),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.gray800),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapPreview() {
    return Container(
      height: 100,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [AppColors.green50, AppColors.blue50]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.green100),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Opacity(
            opacity: 0.1,
            child: Icon(Icons.grid_4x4, size: 200, color: AppColors.green500),
          ),
          const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.location_on, color: AppColors.red500, size: 28),
              SizedBox(height: 4),
              Text('Lihat di Google Maps', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.green700)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusUpdateCard(OrderModel order) {
    String nextStatus = '';
    String nextLabel = '';
    Color btnColor = AppColors.green500;
    Color statusColor = AppColors.gray400;

    if (order.status == 'verified' || order.status == 'pending') {
      nextStatus = 'in_progress';
      nextLabel = '▶ Mulai Pengerjaan';
      btnColor = AppColors.blue500;
      statusColor = AppColors.blue500;
    } else if (order.status == 'in_progress') {
      nextStatus = 'generate';
      nextLabel = '✓ Selesai — Generate Sertifikat';
      btnColor = AppColors.green500;
      statusColor = AppColors.orange500;
    } else if (order.status == 'generate') {
      nextStatus = 'completed';
      nextLabel = '🏅 Tandai Selesai';
      btnColor = AppColors.purple500;
      statusColor = AppColors.purple500;
    }

    if (nextStatus.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppColors.green50, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.green100)),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, color: AppColors.green500, size: 20),
            SizedBox(width: 8),
            Text('Pekerjaan Selesai', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.green700)),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gray100),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Update Status', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.gray800)),
          const SizedBox(height: 14),
          Row(
            children: [
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) => Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: statusColor.withOpacity(0.3), spreadRadius: 4 * _pulseController.value)],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              RichText(
                text: TextSpan(
                  style: const TextStyle(fontSize: 12, color: AppColors.gray600),
                  children: [
                    const TextSpan(text: 'Status: '),
                    TextSpan(text: order.statusLabel.toUpperCase(), style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.w900, color: statusColor)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => _showUpdateDialog(order, nextStatus, nextLabel, btnColor),
            style: ElevatedButton.styleFrom(
              backgroundColor: btnColor,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 4,
              shadowColor: btnColor.withOpacity(0.3),
            ),
            child: Text(nextLabel, style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showUpdateDialog(OrderModel order, String status, String label, Color color) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.gray200, borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 24),
            Text('Update Progres?', style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.gray800)),
            const SizedBox(height: 12),
            Text(
              'Apakah kamu yakin ingin mengubah status pesanan ini menjadi $label?',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: AppColors.gray600, height: 1.5),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => context.pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.gray100,
                      foregroundColor: AppColors.gray600,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                    ),
                    child: const Text('Batal', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      context.pop();
                      try {
                        await ref.read(partnerProvider.notifier).updateWorkOrderStatus(order.id, status);
                        await ref.read(orderProvider.notifier).fetchOrders();
                        if (mounted) AppSnackbar.showSuccess(context, '✅ Status berhasil diperbarui');
                      } catch (e) {
                        if (mounted) AppSnackbar.showError(context, e.toString());
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 4,
                      shadowColor: color.withOpacity(0.3),
                    ),
                    child: const Text('Ya, Update', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
