import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../core/constants/app_constants.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _isLoading = false;
  int _currentStep = 0;
  bool _termsChecked = false;
  bool _obscurePw = true;
  bool _obscureConfirm = true;
  bool _isSuccess = false;

  void _nextStep() {
    if (_currentStep == 0) {
      if (_nameController.text.trim().isEmpty || _emailController.text.trim().isEmpty || _phoneController.text.trim().isEmpty) {
        Fluttertoast.showToast(msg: "Harap isi semua data diri");
        return;
      }
    } else if (_currentStep == 1) {
      if (_passwordController.text.length < 8) {
        Fluttertoast.showToast(msg: "Password minimal 8 karakter");
        return;
      }
      if (_passwordController.text != _confirmPasswordController.text) {
        Fluttertoast.showToast(msg: "Password tidak cocok");
        return;
      }
    } else if (_currentStep == 2) {
      if (!_termsChecked) {
        Fluttertoast.showToast(msg: "Setujui syarat & ketentuan dulu");
        return;
      }
      _handleRegister();
      return;
    }
    
    setState(() {
      _currentStep++;
    });
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    } else {
      context.pop();
    }
  }

  Future<void> _handleRegister() async {
    setState(() => _isLoading = true);

    try {
      await ref.read(authProvider.notifier).register(
        _nameController.text.trim(), 
        _emailController.text.trim(), 
        _passwordController.text.trim(), 
        _phoneController.text.trim()
      );
      
      setState(() => _isSuccess = true);
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    String title = 'Buat Akun Baru';
    if (_currentStep == 1) title = 'Keamanan Akun';
    if (_currentStep == 2) title = 'Konfirmasi';
    if (_isSuccess) title = '';

    return Scaffold(
      backgroundColor: AppColors.gray50,
      appBar: _isSuccess ? null : AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppColors.gray100, borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.arrow_back_ios_new, size: 14, color: AppColors.gray800),
          ),
          onPressed: _prevStep,
        ),
        title: Text(title, style: const TextStyle(
          fontFamily: 'Plus Jakarta Sans',
          fontSize: 16,
          fontWeight: FontWeight.w800,
          color: AppColors.gray800,
        )),
        centerTitle: false,
        shape: const Border(bottom: BorderSide(color: AppColors.gray100, width: 1)),
      ),
      body: _isSuccess ? _buildSuccess() : Column(
        children: [
          _buildProgress(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(top: 16, left: 20, right: 20, bottom: 20),
              child: _buildStepContent(),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: ElevatedButton(
              onPressed: _isLoading ? null : _nextStep,
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: _isLoading 
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Text(_currentStep == 2 ? '✓ Buat Akun' : 'Selanjutnya →'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgress() {
    double progress = (_currentStep + 1) / 3;
    Color color1 = _currentStep >= 0 ? AppColors.blue500 : AppColors.gray400;
    Color color2 = _currentStep >= 1 ? AppColors.blue500 : AppColors.gray400;
    Color color3 = _currentStep >= 2 ? AppColors.blue500 : AppColors.gray400;

    if (_currentStep > 0) color1 = AppColors.green500;
    if (_currentStep > 1) color2 = AppColors.green500;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(left: 18, right: 18, top: 12, bottom: 10),
      child: Column(
        children: [
          Container(
            height: 4,
            width: double.infinity,
            decoration: BoxDecoration(color: AppColors.gray100, borderRadius: BorderRadius.circular(100)),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [AppColors.blue500, AppColors.blue400]),
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('DATA DIRI', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 9, fontWeight: FontWeight.w700, color: color1, letterSpacing: 0.6)),
              Text('KEAMANAN', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 9, fontWeight: FontWeight.w700, color: color2, letterSpacing: 0.6)),
              Text('KONFIRMASI', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 9, fontWeight: FontWeight.w700, color: color3, letterSpacing: 0.6)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent() {
    if (_currentStep == 0) return _buildStep1();
    if (_currentStep == 1) return _buildStep2();
    return _buildStep3();
  }

  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Data Diri', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.gray800)),
        const SizedBox(height: 2),
        const Text('Isi informasi dasar akun kamu', style: TextStyle(fontSize: 11, color: AppColors.gray400, height: 1.5)),
        const SizedBox(height: 16),

        _buildLabel('Nama Lengkap'),
        _buildTextField(_nameController, 'Budi Santoso', Icons.person_outline),
        const SizedBox(height: 12),

        _buildLabel('Email'),
        _buildTextField(_emailController, 'nama@email.com', Icons.email_outlined, type: TextInputType.emailAddress),
        const SizedBox(height: 12),

        _buildLabel('No. HP (WhatsApp)'),
        _buildTextField(_phoneController, '0812-3456-7890', Icons.phone_outlined, type: TextInputType.phone),
        const SizedBox(height: 16),

        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.blue50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.blue100),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.info_outline, color: AppColors.blue700, size: 14),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Nomor HP akan digunakan untuk notifikasi WhatsApp terkait pesanan kamu.',
                  style: TextStyle(fontSize: 10, color: AppColors.blue700, height: 1.5),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Buat Password', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.gray800)),
        const SizedBox(height: 2),
        const Text('Gunakan password yang kuat dan unik', style: TextStyle(fontSize: 11, color: AppColors.gray400, height: 1.5)),
        const SizedBox(height: 16),

        _buildLabel('Password'),
        TextField(
          controller: _passwordController,
          obscureText: _obscurePw,
          decoration: InputDecoration(
            fillColor: Colors.white,
            hintText: 'Minimal 8 karakter',
            suffixIcon: IconButton(
              icon: Icon(_obscurePw ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 18, color: _obscurePw ? AppColors.gray400 : AppColors.blue500),
              onPressed: () => setState(() => _obscurePw = !_obscurePw),
            ),
          ),
          onChanged: (v) => setState((){}),
        ),
        if (_passwordController.text.isNotEmpty) _buildPwStrength(_passwordController.text),
        const SizedBox(height: 16),

        _buildLabel('Konfirmasi Password'),
        TextField(
          controller: _confirmPasswordController,
          obscureText: _obscureConfirm,
          decoration: InputDecoration(
            fillColor: Colors.white,
            hintText: 'Ulangi password',
            suffixIcon: IconButton(
              icon: Icon(_obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 18, color: _obscureConfirm ? AppColors.gray400 : AppColors.blue500),
              onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
            ),
          ),
          onChanged: (v) => setState((){}),
        ),
        if (_confirmPasswordController.text.isNotEmpty && _passwordController.text != _confirmPasswordController.text)
          const Padding(
            padding: EdgeInsets.only(top: 4),
            child: Text('Password tidak cocok', style: TextStyle(fontSize: 10, color: AppColors.red500, fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.w600)),
          ),
        
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.gray50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.gray200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Syarat password kuat:', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.gray600)),
              const SizedBox(height: 6),
              _buildReqRow('Minimal 8 karakter', _passwordController.text.length >= 8),
              _buildReqRow('Huruf kapital (A-Z)', _passwordController.text.contains(RegExp(r'[A-Z]'))),
              _buildReqRow('Angka (0-9)', _passwordController.text.contains(RegExp(r'[0-9]'))),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReqRow(String text, bool isMet) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Row(
        children: [
          Text(isMet ? '✓' : '○', style: TextStyle(fontSize: 10, color: isMet ? AppColors.green500 : AppColors.gray400)),
          const SizedBox(width: 5),
          Text(text, style: TextStyle(fontSize: 10, color: isMet ? AppColors.green500 : AppColors.gray400)),
        ],
      ),
    );
  }

  Widget _buildPwStrength(String pw) {
    bool hasLen = pw.length >= 8;
    bool hasUpper = pw.contains(RegExp(r'[A-Z]'));
    bool hasNum = pw.contains(RegExp(r'[0-9]'));
    int score = [hasLen, hasUpper, hasNum].where((e) => e).length;
    
    double factor = score / 3.0;
    Color color = AppColors.red500;
    String label = 'Lemah';
    if (score == 2) { color = AppColors.yellow500; label = 'Sedang'; }
    if (score == 3) { color = AppColors.green500; label = 'Kuat'; }

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 4, width: double.infinity,
            decoration: BoxDecoration(color: AppColors.gray100, borderRadius: BorderRadius.circular(100)),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: factor,
              child: Container(
                decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(100)),
              ),
            ),
          ),
          const SizedBox(height: 3),
          Text(label, style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 10, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }

  Widget _buildStep3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Hampir selesai!', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.gray800)),
        const SizedBox(height: 2),
        const Text('Periksa data kamu sebelum mendaftar', style: TextStyle(fontSize: 11, color: AppColors.gray400, height: 1.5)),
        const SizedBox(height: 16),

        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 3, offset: const Offset(0, 1))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('RINGKASAN AKUN', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.gray400, letterSpacing: 0.8)),
              const SizedBox(height: 8),
              _buildSummaryRow('Nama', _nameController.text),
              const Divider(color: AppColors.gray100, height: 10),
              _buildSummaryRow('Email', _emailController.text),
              const Divider(color: AppColors.gray100, height: 10),
              _buildSummaryRow('No. HP', _phoneController.text),
            ],
          ),
        ),
        const SizedBox(height: 16),

        GestureDetector(
          onTap: () => setState(() => _termsChecked = !_termsChecked),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 18, height: 18,
                margin: const EdgeInsets.only(top: 1),
                decoration: BoxDecoration(
                  color: _termsChecked ? AppColors.blue500 : Colors.transparent,
                  border: Border.all(color: _termsChecked ? AppColors.blue500 : AppColors.gray300, width: 2),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: _termsChecked ? const Icon(Icons.check, size: 12, color: Colors.white) : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: RichText(
                  text: const TextSpan(
                    style: TextStyle(fontSize: 11, color: AppColors.gray600, fontFamily: 'DM Sans', height: 1.5),
                    children: [
                      TextSpan(text: 'Saya menyetujui '),
                      TextSpan(text: 'Syarat & Ketentuan', style: TextStyle(color: AppColors.blue500, fontWeight: FontWeight.w600)),
                      TextSpan(text: ' dan '),
                      TextSpan(text: 'Kebijakan Privasi', style: TextStyle(color: AppColors.blue500, fontWeight: FontWeight.w600)),
                      TextSpan(text: ' ListrikApp'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.green50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.green100),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.check_circle_outline, color: AppColors.green500, size: 14),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Akun kamu gratis selamanya. Biaya hanya dikenakan saat kamu menggunakan layanan sertifikasi.',
                  style: TextStyle(fontSize: 10, color: AppColors.green700, height: 1.5),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 10, color: AppColors.gray400)),
          Text(value, style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.gray800)),
        ],
      ),
    );
  }

  Widget _buildSuccess() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 80, height: 80,
              decoration: BoxDecoration(color: AppColors.green100, borderRadius: BorderRadius.circular(26)),
              child: const Icon(Icons.check, size: 38, color: AppColors.green500),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Akun Berhasil Dibuat! 🎉',
            textAlign: TextAlign.center,
            style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.gray800),
          ),
          const SizedBox(height: 12),
          const Text(
            'Cek email kamu untuk verifikasi akun. Setelah verifikasi, kamu bisa langsung masuk.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: AppColors.gray400, height: 1.6),
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () => context.go('/login'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
            ),
            child: const Text('Masuk ke Akun →'),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Plus Jakarta Sans',
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.gray600,
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, {TextInputType type = TextInputType.text}) {
    return TextField(
      controller: controller,
      keyboardType: type,
      decoration: InputDecoration(
        fillColor: Colors.white,
        hintText: hint,
        suffixIcon: Icon(icon, color: AppColors.gray400, size: 18),
      ),
    );
  }
}
