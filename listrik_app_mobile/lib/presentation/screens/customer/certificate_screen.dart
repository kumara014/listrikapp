import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/order_model.dart';
import '../../../data/providers/order_provider.dart';
import '../../../data/services/pdf_service.dart';

class CertificateScreen extends ConsumerWidget {
  const CertificateScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderState = ref.watch(orderProvider);
    final completedOrders = orderState.orders.where((o) => o.status == 'completed').toList();

    return Scaffold(
      backgroundColor: AppColors.gray50,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: completedOrders.isEmpty
                ? _buildEmptyState()
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildMainCertificate(completedOrders.first, context),
                        const SizedBox(height: 24),
                        const Text(
                          'Sertifikat Lainnya',
                          style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.gray800),
                        ),
                        const SizedBox(height: 12),
                        ...completedOrders.skip(1).map((order) => _buildCertificateListItem(order, context)),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.blue900, AppColors.blue700],
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 12),
          const Text(
            'Sertifikat Saya',
            style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_turned_in_outlined, size: 64, color: AppColors.gray200),
          const SizedBox(height: 16),
          const Text('Belum ada sertifikat terbit', style: TextStyle(color: AppColors.gray400)),
        ],
      ),
    );
  }

  Widget _buildMainCertificate(OrderModel order, BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.gray100),
            boxShadow: [BoxShadow(color: AppColors.blue500.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 4))],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.blue900, AppColors.blue700, AppColors.blue500],
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.verified_user, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 12),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('SERTIFIKAT RESMI', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Colors.white70, letterSpacing: 1)),
                        Text('Sertifikat Laik Operasi', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white)),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(color: AppColors.blue50, borderRadius: BorderRadius.circular(10)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('NOMOR SLO', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.blue700)),
                          Text('SLO/${order.agendaNumber}', style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.blue700)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow('Nama Pemohon', 'Budi Santoso'),
                    _buildInfoRow('Alamat', order.address),
                    _buildInfoRow('Daya Listrik', '${order.powerCapacity} Watt'),
                    _buildInfoRow('Tanggal Terbit', '06 Mar 2026'),
                    _buildInfoRow('Masa Berlaku', '5 Tahun'),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                color: AppColors.green50,
                child: const Row(
                  children: [
                    Icon(Icons.check_circle, color: AppColors.green500, size: 16),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Sertifikat resmi diterbitkan oleh LIT-TR dan diverifikasi oleh Listrik App',
                        style: TextStyle(fontSize: 9, color: AppColors.green700, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => PdfService.generateCertificate(order),
                icon: const Icon(Icons.download_rounded, size: 16),
                label: const Text('Unduh PDF'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.blue500,
                  minimumSize: const Size(0, 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: () => Share.share('Lihat sertifikat SLO saya di Listrik App: SLO/${order.agendaNumber}'),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.gray200)),
                child: const Icon(Icons.share_outlined, color: AppColors.gray600, size: 20),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 10, color: AppColors.gray400)),
          Text(value, style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.gray800)),
        ],
      ),
    );
  }

  Widget _buildCertificateListItem(OrderModel order, BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.gray100)),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(color: AppColors.blue500, borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.description, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(order.serviceTypeLabel, style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.gray800)),
                Text('SLO/${order.agendaNumber}', style: const TextStyle(fontSize: 9, color: AppColors.gray400)),
              ],
            ),
          ),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('28 Feb 2026', style: TextStyle(fontSize: 9, color: AppColors.gray400)),
              SizedBox(height: 4),
              Icon(Icons.arrow_forward_ios, size: 10, color: AppColors.gray200),
            ],
          ),
        ],
      ),
    );
  }
}
