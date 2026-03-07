import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/providers/partner_provider.dart';
import 'package:listrik_app_mobile/presentation/widgets/app_snackbar.dart';

class PartnerProfileScreen extends ConsumerWidget {
  const PartnerProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final partnerState = ref.watch(partnerProvider);
    final profile = partnerState.profile;

    return Scaffold(
      backgroundColor: AppColors.gray50,
      body: Column(
        children: [
          _buildProfileHeader(profile),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildMenuSection([
                    _ProfileMenuItem(
                      icon: Icons.edit_outlined,
                      title: 'Edit Profil',
                      sub: 'Ubah data perusahaan & bank',
                      color: AppColors.green500,
                      onTap: () => _showEditProfileSheet(context, profile),
                    ),
                    _ProfileMenuItem(
                      icon: Icons.description_outlined,
                      title: 'Dokumen Usaha',
                      sub: 'IUJPTL, SBU, rekening',
                      color: AppColors.blue500,
                      onTap: () => AppSnackbar.showInfo(context, 'Membuka dokumen...'),
                    ),
                    _ProfileMenuItem(
                      icon: Icons.history_outlined,
                      title: 'Riwayat Pencairan',
                      sub: 'Lihat semua permintaan withdraw',
                      color: AppColors.orange500,
                      onTap: () => AppSnackbar.showInfo(context, 'Membuka riwayat...'),
                    ),
                  ]),
                  const SizedBox(height: 16),
                  _buildInfoCard(profile),
                  const SizedBox(height: 24),
                  _buildLogoutButton(ref),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(Map<String, dynamic>? profile) {
    String name = profile?['company_name'] ?? 'PT Listrik Maju';
    String initial = name.isNotEmpty ? name[0].toUpperCase() : 'P';
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 70, 20, 32),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF064E3B), AppColors.green500],
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
            ),
            child: Center(
              child: Text(initial, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white)),
            ),
          ),
          const SizedBox(height: 16),
          Text(name, style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
          const SizedBox(height: 4),
          Text(
            profile?['type']?.toUpperCase() ?? 'BU PEMASANGAN & PEMBANGUNAN',
            style: const TextStyle(fontSize: 10, color: Colors.white70, letterSpacing: 0.5),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(100), border: Border.all(color: Colors.white.withOpacity(0.2))),
            child: const Text('✓ Terverifikasi', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 9, fontWeight: FontWeight.w700, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(List<Widget> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gray100),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Column(children: items),
    );
  }

  Widget _buildInfoCard(Map<String, dynamic>? profile) {
    return Container(
      width: double.infinity,
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
              Icon(Icons.account_balance_outlined, color: AppColors.green500, size: 16),
              SizedBox(width: 8),
              Text('Informasi Bank', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.gray800)),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Bank', profile?['bank_name'] ?? '-'),
          _buildInfoRow('No. Rekening', profile?['bank_account_number'] ?? '-'),
          _buildInfoRow('Atas Nama', profile?['bank_account_name'] ?? '-'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String lbl, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(lbl, style: const TextStyle(fontSize: 10, color: AppColors.gray400, fontWeight: FontWeight.w500)),
          Text(val, style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.gray800)),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(WidgetRef ref) {
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

  void _showEditProfileSheet(BuildContext context, Map<String, dynamic>? profile) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EditProfileBottomSheet(profile: profile),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String sub;
  final Color color;
  final VoidCallback onTap;

  const _ProfileMenuItem({required this.icon, required this.title, required this.sub, required this.color, required this.onTap});

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

class EditProfileBottomSheet extends ConsumerStatefulWidget {
  final Map<String, dynamic>? profile;
  const EditProfileBottomSheet({super.key, this.profile});

  @override
  ConsumerState<EditProfileBottomSheet> createState() => _EditProfileBottomSheetState();
}

class _EditProfileBottomSheetState extends ConsumerState<EditProfileBottomSheet> {
  late TextEditingController _nameController;
  late TextEditingController _bankController;
  late TextEditingController _accNumController;
  late TextEditingController _accNameController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile?['company_name']);
    _bankController = TextEditingController(text: widget.profile?['bank_name']);
    _accNumController = TextEditingController(text: widget.profile?['bank_account_number']);
    _accNameController = TextEditingController(text: widget.profile?['bank_account_name']);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(24, 20, 24, MediaQuery.of(context).viewInsets.bottom + 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.gray200, borderRadius: BorderRadius.circular(10)))),
          const SizedBox(height: 24),
          const Text('Edit Profil', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.gray800)),
          const SizedBox(height: 20),
          _buildField('Nama Perusahaan', _nameController),
          _buildField('Nama Bank', _bankController),
          _buildField('No. Rekening', _accNumController),
          _buildField('Atas Nama', _accNameController),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => context.pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.gray100,
                    foregroundColor: AppColors.gray600,
                    elevation: 0,
                    minimumSize: const Size(0, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Batal', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.green500,
                    foregroundColor: Colors.white,
                    elevation: 4,
                    shadowColor: AppColors.green500.withOpacity(0.3),
                    minimumSize: const Size(0, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading 
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Simpan', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(), style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.gray400, letterSpacing: 0.5)),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.gray800),
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.gray50,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.gray200)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.gray200)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.green500, width: 1.5)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSave() async {
    setState(() => _isLoading = true);
    try {
      await ref.read(partnerProvider.notifier).updateProfile({
        'company_name': _nameController.text,
        'bank_name': _bankController.text,
        'bank_account_number': _accNumController.text,
        'bank_account_name': _accNameController.text,
      });
      if (mounted) {
        AppSnackbar.showSuccess(context, '✅ Profil berhasil diperbarui');
        context.pop();
      }
    } catch (e) {
      if (mounted) AppSnackbar.showError(context, e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
