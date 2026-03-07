import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/order_model.dart';
import '../../../data/providers/order_provider.dart';
import '../../widgets/app_snackbar.dart';

class TrackingScreen extends ConsumerStatefulWidget {
  final String id;
  const TrackingScreen({super.key, required this.id});

  @override
  ConsumerState<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends ConsumerState<TrackingScreen> with SingleTickerProviderStateMixin {
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

  void _showCancelConfirmation() {
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
            const Text('Batalkan Pesanan?', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.gray800)),
            const SizedBox(height: 12),
            const Text(
              'Apakah kamu yakin ingin membatalkan pesanan ini? Tindakan ini tidak dapat dibatalkan.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: AppColors.gray600, height: 1.5),
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
                    child: const Text('Tidak', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      context.pop();
                      AppSnackbar.showError(context, '🚫 Pesanan berhasil dibatalkan');
                      context.pop(); // Go back from tracking
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.red500,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 4,
                      shadowColor: AppColors.red500.withOpacity(0.3),
                    ),
                    child: const Text('Ya, Batalkan', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
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
          _buildTrackingHeader(order),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Status Pengerjaan', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.gray800)),
                  const SizedBox(height: 16),
                  _buildTimeline(order),
                  const SizedBox(height: 24),
                  _buildInfoCard(order),
                ],
              ),
            ),
          ),
          if (order.status == 'pending' || order.status == 'verified')
            Container(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: ElevatedButton(
                onPressed: _showCancelConfirmation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.red100,
                  foregroundColor: AppColors.red500,
                  elevation: 0,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: const BorderSide(color: AppColors.red500)),
                ),
                child: const Text('Batalkan Pesanan', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 13, fontWeight: FontWeight.w700)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTrackingHeader(OrderModel order) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.blue900, AppColors.blue700],
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
                Text('Detail Pesanan', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white)),
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
                const Text('NOMOR AGENDA', style: TextStyle(fontSize: 9, color: Colors.white60, letterSpacing: 1, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(order.agendaNumber, style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 0.5)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildAgendaTag(order.serviceTypeLabel),
                    const SizedBox(width: 8),
                    _buildAgendaTag(order.status.toUpperCase().replaceAll('_', ' '), isStatus: true, color: order.statusColor),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgendaTag(String text, {bool isStatus = false, Color? color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isStatus ? (color ?? Colors.green).withOpacity(0.3) : Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(text, style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white)),
    );
  }

  Widget _buildTimeline(OrderModel order) {
    final steps = ['pending', 'verified', 'in_progress', 'generate', 'completed'];
    final labels = ['Pesanan Dibuat', 'Diverifikasi Admin', 'Sedang Dikerjakan', 'Generate Sertifikat', 'Selesai'];
    final subs = ['', '', 'Mitra sedang di lokasi', 'Sertifikat sedang dibuat', 'Pesanan selesai'];
    final currentIdx = steps.indexOf(order.status);

    return Column(
      children: List.generate(steps.length, (index) {
        bool isDone = index < currentIdx || (order.status == 'completed' && index == 4);
        bool isActive = index == currentIdx && order.status != 'completed';
        bool isLast = index == steps.length - 1;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                if (isActive) 
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) => Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: AppColors.blue500,
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: AppColors.blue500.withOpacity(0.25), spreadRadius: 4 * _pulseController.value, blurRadius: 8 * _pulseController.value)],
                      ),
                      child: const Center(child: Icon(Icons.circle, color: Colors.white, size: 6)),
                    ),
                  )
                else
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: isDone ? AppColors.green500 : AppColors.gray200,
                      shape: BoxShape.circle,
                    ),
                    child: isDone ? const Icon(Icons.check, color: Colors.white, size: 12) : null,
                  ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 34,
                    color: isDone ? AppColors.green500 : AppColors.gray200,
                  ),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(labels[index], style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 12, fontWeight: FontWeight.w800, color: isDone || isActive ? AppColors.gray800 : AppColors.gray400)),
                  if (isActive && subs[index].isNotEmpty) Text(subs[index], style: const TextStyle(fontSize: 10, color: AppColors.gray400, height: 1.5)),
                  if (isDone) const Text('06 Mar 2026 · 11:15', style: TextStyle(fontSize: 9, color: AppColors.green500, fontWeight: FontWeight.w600, height: 1.5)),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildInfoCard(OrderModel order) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.gray100), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Detail Pesanan', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.gray800)),
          const SizedBox(height: 12),
          _buildInfoRow('Mitra', 'PT Listrik Maju'),
          _buildInfoRow('Alamat', order.address),
          _buildInfoRow('Daya', '${order.powerCapacity} Watt'),
          const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Divider(height: 1, color: AppColors.gray50)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Harga', style: TextStyle(fontSize: 10, color: AppColors.gray400, fontWeight: FontWeight.w500)),
              Text(order.formattedPrice, style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.blue500)),
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
}
