import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_constants.dart';
import '../../../data/models/order_model.dart';
import '../../../data/providers/order_provider.dart';
import '../../../data/providers/partner_provider.dart';
import '../../widgets/withdrawal_bottom_sheet.dart';
import '../../widgets/work_order_card.dart';
import 'partner_profile_screen.dart';

class PartnerHomeScreen extends ConsumerStatefulWidget {
  const PartnerHomeScreen({super.key});

  @override
  ConsumerState<PartnerHomeScreen> createState() => _PartnerHomeScreenState();
}

class _PartnerHomeScreenState extends ConsumerState<PartnerHomeScreen> {
  int _currentIndex = 0;
  final _currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(partnerProvider.notifier).fetchProfile();
      ref.read(orderProvider.notifier).fetchOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray50,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildHomeContent(),
          _buildOrdersContent(),
          const PartnerProfileScreen(),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // --- TAB 0: HOME CONTENT ---
  Widget _buildHomeContent() {
    final partnerState = ref.watch(partnerProvider);
    final allOrders = ref.watch(orderProvider);
    final profile = partnerState.profile;
    
    final myOrders = allOrders.where((o) => o.partnerId == (profile?['id'] ?? 0)).toList();
    final activeOrders = myOrders.where((o) => ['pending', 'verified', 'in_progress', 'generate'].contains(o.status)).toList();
    final completedOrders = myOrders.where((o) => o.status == 'completed').toList();

    return Column(
      children: [
        _buildHeader(profile),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              await ref.read(partnerProvider.notifier).fetchProfile();
              await ref.read(orderProvider.notifier).fetchOrders();
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatsRow(myOrders.length, activeOrders.length, completedOrders.length),
                  const SizedBox(height: 24),
                  _buildSectionHeader('Pesanan Masuk', onSeeAll: () => setState(() => _currentIndex = 1)),
                  const SizedBox(height: 12),
                  _buildRecentOrders(myOrders),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(Map<String, dynamic>? profile) {
    final balance = (profile?['balance'] as num?)?.toDouble() ?? 0.0;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF064E3B), Color(0xFF065F46), AppColors.green500],
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
                  const Text('Selamat pagi,', style: TextStyle(fontSize: 10, color: Colors.white60)),
                  Text('${profile?['company_name'] ?? 'Partner'} ⚡', style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(100), border: Border.all(color: Colors.white.withOpacity(0.2))),
                    child: const Text('✓ Terverifikasi', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 9, fontWeight: FontWeight.w700, color: Colors.white)),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => context.push('/notifications'),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.15)),
                  ),
                  child: const Icon(Icons.notifications_none, color: Colors.white, size: 18),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.15)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Saldo Tersedia', style: TextStyle(fontSize: 9, color: Colors.white60, fontWeight: FontWeight.w500)),
                      Text(_currencyFormat.format(balance), style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 0.5)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () => _showWithdrawalSheet(balance),
                child: Container(
                  height: 60,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)]),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.account_balance_wallet_outlined, color: AppColors.green500, size: 20),
                      const SizedBox(height: 4),
                      const Text('Tarik Dana', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.green500)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(int total, int active, int completed) {
    return Row(
      children: [
        _buildStatCard(total.toString(), 'Total', AppColors.blue500),
        const SizedBox(width: 10),
        _buildStatCard(active.toString(), 'Aktif', AppColors.orange500),
        const SizedBox(width: 10),
        _buildStatCard(completed.toString(), 'Selesai', AppColors.green500),
      ],
    );
  }

  Widget _buildStatCard(String val, String lbl, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.gray100),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))],
        ),
        child: Column(
          children: [
            Text(val, style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 22, fontWeight: FontWeight.w900, color: color)),
            const SizedBox(height: 2),
            Text(lbl, style: const TextStyle(fontSize: 9, color: AppColors.gray400, fontWeight: FontWeight.w600)),
          ],
        ),
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
            child: const Text('Lihat semua', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.green500)),
          ),
      ],
    );
  }

  Widget _buildRecentOrders(List<OrderModel> orders) {
    if (orders.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.gray100)),
        child: const Column(
          children: [
            Icon(Icons.inventory_2_outlined, color: AppColors.gray200, size: 40),
            SizedBox(height: 12),
            Text('Belum ada pesanan masuk', style: TextStyle(fontSize: 12, color: AppColors.gray400, fontWeight: FontWeight.w500)),
          ],
        ),
      );
    }
    return Column(children: orders.take(5).map((o) => WorkOrderCard(order: o)).toList());
  }

  // --- TAB 1: ORDERS CONTENT ---
  Widget _buildOrdersContent() {
    final partnerState = ref.watch(partnerProvider);
    final allOrders = ref.watch(orderProvider);
    final profile = partnerState.profile;
    final myOrders = allOrders.where((o) => o.partnerId == (profile?['id'] ?? 0)).toList();

    return DefaultTabController(
      length: 5,
      child: Column(
        children: [
          _buildOrdersHeader(),
          const TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            labelColor: AppColors.green500,
            unselectedLabelColor: AppColors.gray400,
            indicatorColor: AppColors.green500,
            indicatorWeight: 3,
            labelStyle: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 11, fontWeight: FontWeight.w800),
            unselectedLabelStyle: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 11, fontWeight: FontWeight.w600),
            tabs: [
              Tab(text: 'Semua'),
              Tab(text: 'Baru'),
              Tab(text: 'Dikerjakan'),
              Tab(text: 'Generate'),
              Tab(text: 'Selesai'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildOrderListGrid(myOrders),
                _buildOrderListGrid(myOrders.where((o) => o.status == 'pending' || o.status == 'verified').toList()),
                _buildOrderListGrid(myOrders.where((o) => o.status == 'in_progress').toList()),
                _buildOrderListGrid(myOrders.where((o) => o.status == 'generate').toList()),
                _buildOrderListGrid(myOrders.where((o) => o.status == 'completed').toList()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 16),
      color: Colors.white,
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Semua Pesanan', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.gray800)),
          Text('Kelola seluruh pekerjaan kamu', style: TextStyle(fontSize: 11, color: AppColors.gray400, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildOrderListGrid(List<OrderModel> orders) {
    if (orders.isEmpty) {
      return const Center(child: Text('Tidak ada pesanan di kategori ini', style: TextStyle(color: AppColors.gray400, fontSize: 12)));
    }
    return RefreshIndicator(
      onRefresh: () => ref.read(orderProvider.notifier).fetchOrders(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        itemBuilder: (context, index) => WorkOrderCard(order: orders[index]),
      ),
    );
  }

  // --- NAVIGATION ---
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
              _buildNavItem(Icons.assignment_outlined, 'Pesanan', active: _currentIndex == 1, onTap: () => setState(() => _currentIndex = 1)),
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
          Icon(icon, color: active ? AppColors.green500 : AppColors.gray400, size: 22),
          const SizedBox(height: 2),
          if (active) Container(width: 4, height: 4, decoration: const BoxDecoration(color: AppColors.green500, shape: BoxShape.circle)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 9, fontWeight: active ? FontWeight.w700 : FontWeight.w600, color: active ? AppColors.green500 : AppColors.gray400)),
        ],
      ),
    );
  }

  void _showWithdrawalSheet(double balance) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => WithdrawalBottomSheet(availableBalance: balance),
    );
  }
}
