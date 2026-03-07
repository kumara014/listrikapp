import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../data/models/order_model.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/providers/order_provider.dart';
import 'order_list_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(orderProvider.notifier).fetchOrders());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray50,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildHomeContent(),
          const OrderListScreen(),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHomeContent() {
    final user = ref.watch(authProvider);
    final orders = ref.watch(orderProvider);
    final activeOrdersCount = orders.where((o) => o.status != 'completed' && o.status != 'cancelled').length;

    return Column(
      children: [
        _buildHeader(user?.name ?? 'Pengguna', activeOrdersCount),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => ref.read(orderProvider.notifier).fetchOrders(),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader('Pilih Layanan'),
                  const SizedBox(height: 12),
                  _buildServiceGrid(),
                  const SizedBox(height: 24),
                  _buildSectionHeader('Pesanan Terbaru', onSeeAll: () => setState(() => _currentIndex = 1)),
                  const SizedBox(height: 12),
                  _buildRecentOrders(orders),
                  if (orders.any((o) => o.status == 'completed')) ...[
                    const SizedBox(height: 24),
                    _buildSectionHeader('Sertifikat Saya', onSeeAll: () => context.push('/certificates')),
                    const SizedBox(height: 12),
                    _buildCertificateBanner(),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(String name, int activeCount) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 28),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.blue900, AppColors.blue700, AppColors.blue500],
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Selamat pagi,', style: TextStyle(fontSize: 11, color: Colors.white60)),
                  Text('$name 👋', style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
                ],
              ),
              GestureDetector(
                onTap: () => context.push('/notifications'),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: const Icon(Icons.notifications_none, color: Colors.white, size: 18),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withOpacity(0.15)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Total Pesanan Aktif', style: TextStyle(fontSize: 10, color: Colors.white60)),
                      Text('$activeCount Pesanan', style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
                      const Text('Sedang diproses · Menunggu', style: TextStyle(fontSize: 10, color: Colors.white54)),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => setState(() => _currentIndex = 1),
                  child: const Icon(Icons.arrow_forward_ios, color: Colors.white38, size: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, {VoidCallback? onSeeAll}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.gray800)),
        if (onSeeAll != null)
          GestureDetector(
            onTap: onSeeAll,
            child: const Text('Lihat semua', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.blue500)),
          ),
      ],
    );
  }

  Widget _buildServiceGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.4,
      children: [
        _buildServiceCard('NIDI', 'Nomor Identitas Instalasi Listrik', Icons.description_outlined, AppColors.blue500, AppColors.blue50, 'nidi'),
        _buildServiceCard('SLO', 'Sertifikat Laik Operasi', Icons.verified_outlined, AppColors.green500, AppColors.green100, 'slo'),
        _buildServiceCard('NIDI & SLO', 'Paket NIDI dan SLO sekaligus', Icons.flash_on_outlined, AppColors.orange500, AppColors.orange100, 'nidi_slo'),
        _buildServiceCard('Paket Lengkap', 'NIDI + SLO + Daftar PLN', Icons.star_outline, AppColors.purple500, AppColors.purple100, 'full_package'),
      ],
    );
  }

  Widget _buildServiceCard(String title, String desc, IconData icon, Color color, Color bgColor, String type) {
    return GestureDetector(
      onTap: () => context.push('/order?serviceType=$type'),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.gray100, width: 1.5),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.gray800)),
            const SizedBox(height: 2),
            Expanded(child: Text(desc, style: const TextStyle(fontSize: 9, color: AppColors.gray400, height: 1.3), maxLines: 2, overflow: TextOverflow.ellipsis)),
            Text('Mulai →', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 10, fontWeight: FontWeight.w700, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentOrders(List<OrderModel> orders) {
    if (orders.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        width: double.infinity,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.gray100)),
        child: const Column(
          children: [
            Icon(Icons.inventory_2_outlined, color: AppColors.gray200, size: 32),
            SizedBox(height: 8),
            Text('Belum ada pesanan', style: TextStyle(fontSize: 12, color: AppColors.gray400)),
          ],
        ),
      );
    }

    return Column(
      children: orders.take(3).map((order) => _buildOrderCard(order)).toList(),
    );
  }

  Widget _buildOrderCard(OrderModel order) {
    return GestureDetector(
      onTap: () => context.push('/tracking/${order.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.gray100),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(order.agendaNumber, style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.gray800)),
                const SizedBox(height: 2),
                Text('${order.serviceTypeLabel} · ${order.powerCapacity} watt', style: const TextStyle(fontSize: 10, color: AppColors.gray400)),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: order.statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(100)),
                  child: Text(
                    order.status.replaceAll('_', ' ').toUpperCase(),
                    style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 8, fontWeight: FontWeight.w800, color: order.statusColor),
                  ),
                ),
                const SizedBox(height: 4),
                Text(order.formattedPrice, style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.blue500)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCertificateBanner() {
    return GestureDetector(
      onTap: () => context.push('/certificates'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [AppColors.blue900, AppColors.blue700]),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(width: 40, height: 40, decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.verified_user, color: Colors.white, size: 20)),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Lihat Sertifikat SLO', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white)),
                  Text('Sertifikat kamu sudah terbit dan siap digunakan', style: TextStyle(fontSize: 10, color: Colors.white70)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white38, size: 14),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: AppColors.gray100))),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home_outlined, 'Beranda', active: _currentIndex == 0, onTap: () => setState(() => _currentIndex = 0)),
              _buildNavItem(Icons.description_outlined, 'Pesanan', active: _currentIndex == 1, onTap: () => setState(() => _currentIndex = 1)),
              _buildNavItem(Icons.person_outline, 'Profil', active: _currentIndex == 2, onTap: () => setState(() => _currentIndex = 2)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, {bool active = false, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: active ? AppColors.blue500 : AppColors.gray400, size: 22),
          const SizedBox(height: 2),
          if (active) Container(width: 4, height: 4, decoration: const BoxDecoration(color: AppColors.blue500, shape: BoxShape.circle)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 9, fontWeight: active ? FontWeight.w700 : FontWeight.w600, color: active ? AppColors.blue500 : AppColors.gray400)),
        ],
      ),
    );
  }
}
