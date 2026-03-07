import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.gray50,
      body: Column(
        children: [
          _buildHeader(user?.name ?? 'Pengguna'),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildMenuSection([
                    _MenuItem(icon: Icons.description_outlined, title: 'Pesanan Saya', sub: 'Lihat seluruh riwayat pesanan', color: AppColors.blue500, onTap: () {}),
                    _MenuItem(icon: Icons.card_membership_outlined, title: 'Sertifikat Saya', sub: 'Unduh sertifikat NIDI & SLO', color: AppColors.green500, onTap: () => context.push('/certificates')),
                    _MenuItem(icon: Icons.person_outline, title: 'Edit Profil', sub: 'Ubah data diri dan informasi akun', color: AppColors.orange500, onTap: () {}),
                  ]),
                  const SizedBox(height: 12),
                  _buildMenuSection([
                    _MenuItem(icon: Icons.help_outline, title: 'Pusat Bantuan', sub: 'Pertanyaan umum dan panduan', color: AppColors.gray400, onTap: () {}),
                    _MenuItem(icon: Icons.policy_outlined, title: 'Kebijakan Privasi', sub: 'Syarat dan ketentuan layanan', color: AppColors.gray400, onTap: () {}),
                  ]),
                  const SizedBox(height: 24),
                  _buildLogoutButton(ref, context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(String name) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 32),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.blue900, AppColors.blue700],
        ),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: Colors.white24,
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : 'U',
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white),
            ),
          ),
          const SizedBox(height: 16),
          Text(name, style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
          const SizedBox(height: 4),
          const Text('Customer Account', style: TextStyle(fontSize: 12, color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _buildMenuSection(List<Widget> items) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.gray100)),
      child: Column(children: items),
    );
  }

  Widget _buildLogoutButton(WidgetRef ref, BuildContext context) {
    return GestureDetector(
      onTap: () => ref.read(authProvider.notifier).logout(),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppColors.red100, borderRadius: BorderRadius.circular(14)),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout, color: AppColors.red500, size: 20),
            SizedBox(width: 10),
            Text('Keluar dari Akun', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.red500)),
          ],
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String sub;
  final Color color;
  final VoidCallback onTap;

  const _MenuItem({required this.icon, required this.title, required this.sub, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.gray800)),
                  Text(sub, style: const TextStyle(fontSize: 10, color: AppColors.gray400)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.gray200),
          ],
        ),
      ),
    );
  }
}
