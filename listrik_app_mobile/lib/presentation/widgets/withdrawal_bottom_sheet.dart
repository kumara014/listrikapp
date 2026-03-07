import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_constants.dart';
import '../../data/providers/partner_provider.dart';
import 'package:listrik_app_mobile/presentation/widgets/app_snackbar.dart';
import 'package:go_router/go_router.dart';

class WithdrawalBottomSheet extends ConsumerStatefulWidget {
  final double availableBalance;
  const WithdrawalBottomSheet({super.key, required this.availableBalance});

  @override
  ConsumerState<WithdrawalBottomSheet> createState() => _WithdrawalBottomSheetState();
}

class _WithdrawalBottomSheetState extends ConsumerState<WithdrawalBottomSheet> {
  final _amountController = TextEditingController();
  final _currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
  bool _isLoading = false;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
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
          const Text('Tarik Dana', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.gray800)),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.green50, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.green100)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Saldo Tersedia', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.green700)),
                const SizedBox(height: 4),
                Text(_currencyFormat.format(widget.availableBalance), style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.green700)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text('Masukkan nominal yang ingin ditarik:', style: TextStyle(fontSize: 12, color: AppColors.gray600, fontWeight: FontWeight.w500)),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: AppColors.gray50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.gray200, width: 2),
            ),
            child: TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.gray800),
              decoration: const InputDecoration(
                prefixText: 'Rp ',
                prefixStyle: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.green500),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                border: InputBorder.none,
                hintText: '0',
                hintStyle: TextStyle(color: AppColors.gray200),
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Text('Minimum penarikan Rp 50.000', style: TextStyle(fontSize: 10, color: AppColors.gray400, fontWeight: FontWeight.w500)),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => context.pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.gray100,
                    foregroundColor: AppColors.gray600,
                    elevation: 0,
                    minimumSize: const Size(0, 52),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Batal', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.green500,
                    foregroundColor: Colors.white,
                    elevation: 4,
                    shadowColor: AppColors.green500.withOpacity(0.3),
                    minimumSize: const Size(0, 52),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _isLoading 
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Tarik Dana', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _handleSubmit() async {
    final amountText = _amountController.text.replaceAll('.', '').replaceAll(',', '');
    final amount = double.tryParse(amountText) ?? 0;

    if (amount < 50000) {
      AppSnackbar.showError(context, "⚠️ Minimum penarikan Rp 50.000");
      return;
    }

    if (amount > widget.availableBalance) {
      AppSnackbar.showError(context, "⚠️ Saldo tidak mencukupi");
      return;
    }

    setState(() => _isLoading = true);
    try {
      await ref.read(partnerProvider.notifier).requestWithdrawal(amount);
      if (mounted) {
        AppSnackbar.showSuccess(context, "💰 Pencairan Rp ${NumberFormat('#,###', 'id_ID').format(amount)} berhasil diajukan!");
        context.pop();
      }
    } catch (e) {
      if (mounted) AppSnackbar.showError(context, e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
