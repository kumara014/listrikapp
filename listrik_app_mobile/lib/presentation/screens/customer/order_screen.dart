import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../widgets/app_snackbar.dart';
import '../../../data/providers/order_provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'map_picker_screen.dart';

class OrderScreen extends ConsumerStatefulWidget {
  final String? serviceType;
  const OrderScreen({super.key, this.serviceType});

  @override
  ConsumerState<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends ConsumerState<OrderScreen> {
  int _currentStep = 0;
  
  // Form States
  late String _selectedType;
  String _selectedPower = '2.200 Watt';
  String _installationType = 'Instalasi Baru';
  final _notesController = TextEditingController();
  final _addressController = TextEditingController();
  
  String _latitude = '-6.200000';
  String _longitude = '106.816666';
  bool _isLocating = false;
  
  int? _selectedPartner;
  int? _selectedLit;

  final Map<String, int> _basePrices = {
    'nidi': 500000,
    'slo': 350000,
    'nidi_slo': 800000,
    'full_package': 1200000,
  };

  final Map<String, String> _serviceNames = {
    'nidi': 'NIDI',
    'slo': 'SLO',
    'nidi_slo': 'NIDI & SLO',
    'full_package': 'Paket Lengkap',
  };

  @override
  void initState() {
    super.initState();
    _selectedType = widget.serviceType ?? 'nidi_slo';
  }

  int get _totalPrice {
    int base = _basePrices[_selectedType] ?? 0;
    int extra = 0;
    if (_selectedPower == '3.500 Watt') extra = 50000;
    else if (_selectedPower == '5.500 Watt+') extra = 100000;
    return base + extra;
  }

  String _formatPrice(int price) {
    return 'Rp ${price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLocating = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw 'Location services are disabled.';
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw 'Location permissions are denied';
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        throw 'Location permissions are permanently denied';
      }

      Position position = await Geolocator.getCurrentPosition();
      
      setState(() {
        _latitude = position.latitude.toString();
        _longitude = position.longitude.toString();
      });

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String address = "${place.street}, ${place.subLocality}, ${place.locality}, ${place.subAdministrativeArea}, ${place.administrativeArea}";
        setState(() {
          _addressController.text = address;
        });
      }

      if (mounted) AppSnackbar.showSuccess(context, '📍 Lokasi berhasil didapatkan!');
    } catch (e) {
      if (mounted) AppSnackbar.showError(context, 'Gagal mengambil lokasi: $e');
    } finally {
      if (mounted) setState(() => _isLocating = false);
    }
  }

  void _nextStep() async {
    if (_currentStep < 4) {
      setState(() => _currentStep++);
    } else {
      try {
        final powerString = _selectedPower.replaceAll(RegExp(r'[^0-9]'), '');
        final powerInt = int.tryParse(powerString) ?? 0;
        
        await ref.read(orderProvider.notifier).createOrder({
          'service_type': _selectedType,
          'partner_id': _selectedPartner,
          'lit_id': _selectedLit,
          'address': _addressController.text.isEmpty ? 'Jl. Sudirman No.12' : _addressController.text,
          'latitude': _latitude,
          'longitude': _longitude,
          'installation_type': _installationType,
          'power_capacity': powerInt,
          'notes': _notesController.text,
        });

        if (mounted) {
          AppSnackbar.showSuccess(context, '✅ Pesanan berhasil dibuat!');
          context.go('/home');
        }
      } catch (e) {
        if (mounted) {
          AppSnackbar.showError(context, 'Gagal membuat pesanan: $e');
        }
      }
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    } else {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray50,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildStepBar(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: _buildStepContent(),
            ),
          ),
          _buildBottomButton(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(color: AppColors.gray100, borderRadius: BorderRadius.circular(10)),
          child: const Icon(Icons.arrow_back_ios_new, size: 14, color: AppColors.gray800),
        ),
        onPressed: _prevStep,
      ),
      title: const Text(
        'Buat Pesanan',
        style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.gray800),
      ),
    );
  }

  Widget _buildStepBar() {
    final List<String> labels = ['Layanan', 'Detail', 'Lokasi', 'Mitra', 'Konfirm'];
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        children: [
          Row(
            children: List.generate(5, (index) {
              bool isDone = index < _currentStep;
              bool isActive = index == _currentStep;
              bool isFuture = index > _currentStep;

              return Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: isDone ? AppColors.green500 : (isActive ? AppColors.blue500 : AppColors.gray200),
                        shape: BoxShape.circle,
                        boxShadow: isActive ? [BoxShadow(color: AppColors.blue500.withOpacity(0.18), spreadRadius: 4)] : null,
                      ),
                      child: Center(
                        child: isDone 
                          ? const Icon(Icons.check, color: Colors.white, size: 12)
                          : Text('${index + 1}', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 10, fontWeight: FontWeight.w800, color: isFuture ? AppColors.gray400 : Colors.white)),
                      ),
                    ),
                    if (index < 4)
                      Expanded(
                        child: Container(
                          height: 2,
                          color: index < _currentStep ? AppColors.green500 : AppColors.gray200,
                        ),
                      ),
                  ],
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(5, (index) {
              bool isActive = index == _currentStep;
              bool isDone = index < _currentStep;
              return SizedBox(
                width: 46,
                child: Text(
                  labels[index],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 8,
                    fontWeight: FontWeight.w600,
                    color: isActive ? AppColors.blue500 : (isDone ? AppColors.green500 : AppColors.gray400),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0: return _buildStep0();
      case 1: return _buildStep1();
      case 2: return _buildStep2();
      case 3: return _buildStep3();
      case 4: return _buildStep4();
      default: return const SizedBox();
    }
  }

  // --- STEP 0: DETAIL LAYANAN ---
  Widget _buildStep0() {
    return Column(
      children: [
        _buildServiceSelectedBanner(),
        const SizedBox(height: 16),
        _buildSectionCard(
          title: 'Detail Instalasi',
          child: Column(
            children: [
              _buildDropdown(
                label: _selectedPower,
                onTap: () => _showPowerPicker(),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildToggleBtn('Instalasi Baru', _installationType == 'Instalasi Baru'),
                  const SizedBox(width: 8),
                  _buildToggleBtn('Supervisi', _installationType == 'Supervisi'),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildSectionCard(
          title: 'Catatan (opsional)',
          child: TextField(
            controller: _notesController,
            maxLines: 2,
            style: const TextStyle(fontSize: 12),
            decoration: InputDecoration(
              hintText: 'Tambahkan catatan untuk mitra...',
              filled: true,
              fillColor: AppColors.gray50,
              contentPadding: const EdgeInsets.all(12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(11), borderSide: const BorderSide(color: AppColors.gray200)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(11), borderSide: const BorderSide(color: AppColors.gray200)),
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildPriceSummary(),
      ],
    );
  }

  // --- STEP 1: LOKASI ---
  Future<void> _openMapPicker() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => MapPickerScreen(
          initialLat: double.tryParse(_latitude) ?? -6.200000,
          initialLng: double.tryParse(_longitude) ?? 106.816666,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _latitude = result['lat'].toString();
        _longitude = result['lng'].toString();
        _addressController.text = result['address'];
      });
    }
  }

  Widget _buildStep1() {
    return Column(
      children: [
        _buildSectionCard(
          title: 'Alamat Lengkap',
          child: TextField(
            controller: _addressController,
            style: const TextStyle(fontSize: 12),
            decoration: InputDecoration(
              hintText: 'Contoh: Jl. Sudirman No.12, Jakarta',
              hintStyle: const TextStyle(color: AppColors.gray400),
              suffixIcon: IconButton(
                icon: const Icon(Icons.my_location, color: AppColors.blue500),
                onPressed: _getCurrentLocation,
              ),
              filled: true,
              fillColor: AppColors.gray50,
              contentPadding: const EdgeInsets.all(12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(11), borderSide: const BorderSide(color: AppColors.gray200)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(11), borderSide: const BorderSide(color: AppColors.gray200)),
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildSectionCard(
          title: 'Pin Lokasi di Peta',
          child: Column(
            children: [
              if (_isLocating)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                )
              else
                GestureDetector(
                  onTap: _openMapPicker,
                  child: Container(
                    height: 140,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFFE8F5E9), Color(0xFFBBDEFB)]),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.gray200),
                    ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Simple map placeholder pattern
                      Positioned.fill(
                        child: Opacity(
                          opacity: 0.1,
                          child: GridView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 10),
                            itemBuilder: (context, index) => Container(decoration: BoxDecoration(border: Border.all(color: AppColors.blue500))),
                          ),
                        ),
                      ),
                      const Icon(Icons.location_on, color: AppColors.red500, size: 36),
                      Positioned(
                        bottom: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), borderRadius: BorderRadius.circular(100)),
                          child: const Text('Tap untuk pindah pin', style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: AppColors.blue50, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.blue100)),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline, color: AppColors.blue500, size: 16),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Pastikan pin lokasi tepat di alamat pemasangan instalasi listrik kamu.',
                  style: TextStyle(fontSize: 10, color: AppColors.blue900, height: 1.4),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- STEP 2: MITRA ---
  Widget _buildStep2() {
    final partners = [
      {'id': 1, 'name': 'PT Listrik Maju', 'meta': '⭐ 4.9 · 128 pekerjaan', 'bg': AppColors.blue50, 'fg': AppColors.blue500, 'init': 'LM'},
      {'id': 2, 'name': 'CV Daya Elektrik', 'meta': '⭐ 4.7 · 94 pekerjaan', 'bg': AppColors.orange50, 'fg': AppColors.orange500, 'init': 'DE'},
      {'id': 3, 'name': 'PT Surya Listrik', 'meta': '⭐ 4.8 · 67 pekerjaan', 'bg': AppColors.green50, 'fg': AppColors.green500, 'init': 'SL'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Pilih Badan Usaha', style: TextStyle(fontSize: 11, color: AppColors.gray600)),
        const SizedBox(height: 12),
        ...partners.map((p) => _buildSelectionCard(
          isSelected: _selectedPartner == p['id'],
          onTap: () => setState(() => _selectedPartner = p['id'] as int),
          title: p['name'] as String,
          subtitle: p['meta'] as String,
          init: p['init'] as String,
          bg: p['bg'] as Color,
          fg: p['fg'] as Color,
        )),
      ],
    );
  }

  // --- STEP 3: LIT-TR ---
  Widget _buildStep3() {
    final lits = [
      {'id': 1, 'name': 'PT PPILN', 'meta': '⭐ 4.9 · 342 sertifikasi', 'bg': AppColors.purple50, 'fg': AppColors.purple500, 'init': 'PP'},
      {'id': 2, 'name': 'PT Konsuil Prima', 'meta': '⭐ 4.8 · 215 sertifikasi', 'bg': AppColors.blue50, 'fg': AppColors.blue500, 'init': 'KP'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Pilih Lembaga Inspeksi Teknik (LIT-TR)', style: TextStyle(fontSize: 11, color: AppColors.gray600)),
        const SizedBox(height: 12),
        ...lits.map((p) => _buildSelectionCard(
          isSelected: _selectedLit == p['id'],
          onTap: () => setState(() => _selectedLit = p['id'] as int),
          title: p['name'] as String,
          subtitle: p['meta'] as String,
          init: p['init'] as String,
          bg: p['bg'] as Color,
          fg: p['fg'] as Color,
        )),
      ],
    );
  }

  // --- STEP 4: KONFIRMASI ---
  Widget _buildStep4() {
    final agenda = 'LSK-20260306-00${(10 + (_currentStep * 7))}';
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [AppColors.blue900, AppColors.blue700]),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              const Text('NOMOR AGENDA', style: TextStyle(fontSize: 9, color: Colors.white60, letterSpacing: 1, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(agenda, style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 0.5)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildSectionCard(
          title: 'Ringkasan Pesanan',
          child: Column(
            children: [
              _buildSummaryRow('Layanan', _serviceNames[_selectedType] ?? ''),
              _buildSummaryRow('Daya', _selectedPower),
              _buildSummaryRow('Jenis', _installationType),
              _buildSummaryRow('Alamat', _addressController.text.isEmpty ? 'Jl. Sudirman No.12' : _addressController.text),
              _buildSummaryRow('Mitra', _selectedPartner == 1 ? 'PT Listrik Maju' : 'Belum dipilih'),
              const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Divider(height: 1, color: AppColors.gray100)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Bayar', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.gray800)),
                  Text(_formatPrice(_totalPrice), style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.blue500)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: AppColors.green50, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.green100)),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.check_circle_outline, color: AppColors.green500, size: 16),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Pesanan akan diproses setelah pembayaran berhasil dikonfirmasi.',
                  style: TextStyle(fontSize: 10, color: AppColors.green700, height: 1.4),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- SUB WIDGETS ---

  Widget _buildServiceSelectedBanner() {
    final colors = {
      'nidi': AppColors.blue500,
      'slo': AppColors.green500,
      'nidi_slo': AppColors.orange500,
      'full_package': AppColors.purple500,
    };
    final color = colors[_selectedType] ?? AppColors.blue500;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [color.withOpacity(0.8), color]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withOpacity(0.2))),
            child: const Icon(Icons.flash_on, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_serviceNames[_selectedType] ?? '', style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white)),
                const Text('Layanan dipilih', style: TextStyle(fontSize: 11, color: Colors.white70)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(_formatPrice(_basePrices[_selectedType] ?? 0), style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white)),
              const Text('base price', style: TextStyle(fontSize: 9, color: Colors.white60)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.gray100)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.gray800)),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildDropdown({required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(color: AppColors.gray50, borderRadius: BorderRadius.circular(11), border: Border.all(color: AppColors.gray200)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.gray800)),
            const Icon(Icons.keyboard_arrow_down, size: 16, color: AppColors.gray400),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleBtn(String label, bool isSelected) {
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _installationType = label),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.blue500 : Colors.white,
            borderRadius: BorderRadius.circular(11),
            border: Border.all(color: isSelected ? AppColors.blue500 : AppColors.gray200, width: 1.5),
            boxShadow: isSelected ? [BoxShadow(color: AppColors.blue500.withOpacity(0.25), blurRadius: 10, offset: const Offset(0, 3))] : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 11, fontWeight: FontWeight.w700, color: isSelected ? Colors.white : AppColors.gray400),
          ),
        ),
      ),
    );
  }

  Widget _buildPriceSummary() {
    int extra = _selectedPower == '3.500 Watt' ? 50000 : (_selectedPower == '5.500 Watt+' ? 100000 : 0);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.blue50, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.blue100)),
      child: Column(
        children: [
          _buildPriceItem(_serviceNames[_selectedType] ?? '', _formatPrice(_basePrices[_selectedType] ?? 0)),
          const SizedBox(height: 6),
          _buildPriceItem('Tambahan daya', '+ ${_formatPrice(extra)}'),
          const Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Divider(height: 1, color: Color(0xFFBFDBFE), thickness: 1)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.gray800)),
              Text(_formatPrice(_totalPrice), style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.blue500)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceItem(String label, String price) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.gray600)),
        Text(price, style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.gray800)),
      ],
    );
  }

  Widget _buildSelectionCard({required bool isSelected, required VoidCallback onTap, required String title, required String subtitle, required String init, required Color bg, required Color fg}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isSelected ? AppColors.blue500 : AppColors.gray100, width: isSelected ? 2 : 1),
          boxShadow: isSelected ? [BoxShadow(color: AppColors.blue500.withOpacity(0.1), blurRadius: 10)] : null,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
              child: Center(child: Text(init, style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 14, fontWeight: FontWeight.w800, color: fg))),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.gray800)),
                  Text(subtitle, style: const TextStyle(fontSize: 10, color: AppColors.gray400)),
                ],
              ),
            ),
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.blue500 : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: isSelected ? AppColors.blue500 : AppColors.gray200, width: 2),
              ),
              child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 12) : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String lbl, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(lbl, style: const TextStyle(fontSize: 11, color: AppColors.gray400)),
          Text(val, style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.gray800)),
        ],
      ),
    );
  }

  void _showPowerPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.gray200, borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 20),
            const Text('Pilih Daya Listrik', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 15, fontWeight: FontWeight.w800)),
            const SizedBox(height: 20),
            ...['450 Watt', '900 Watt', '1.300 Watt', '2.200 Watt', '3.500 Watt', '5.500 Watt+'].map((d) => ListTile(
              title: Text(d, style: TextStyle(fontSize: 13, fontWeight: d == _selectedPower ? FontWeight.w800 : FontWeight.w500, color: d == _selectedPower ? AppColors.blue500 : AppColors.gray800)),
              trailing: d == _selectedPower ? const Icon(Icons.check_circle, color: AppColors.blue500) : null,
              onTap: () {
                setState(() => _selectedPower = d);
                context.pop();
              },
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomButton() {
    String label = 'Selanjutnya → Lokasi';
    if (_currentStep == 1) {
      label = 'Selanjutnya → Pilih Mitra';
    } else if (_currentStep == 2) {
      label = 'Selanjutnya → Pilih LIT-TR';
    } else if (_currentStep == 3) {
      label = 'Selanjutnya → Konfirmasi';
    } else if (_currentStep == 4) {
      label = '💳 Lanjut ke Pembayaran';
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: ElevatedButton(
        onPressed: _nextStep,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.blue500,
          minimumSize: const Size(double.infinity, 54),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          shadowColor: AppColors.blue500.withOpacity(0.35),
          elevation: 8,
        ),
        child: Text(
          label,
          style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white),
        ),
      ),
    );
  }
}
