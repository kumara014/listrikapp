import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/partner_model.dart';
import '../services/api_service.dart';
import 'auth_provider.dart';

final partnerProvider = StateNotifierProvider<PartnerNotifier, PartnerState>((ref) {
  return PartnerNotifier(ref.watch(apiServiceProvider));
});

class PartnerState {
  final List<PartnerModel> partners;
  final Map<String, dynamic>? profile;
  final bool isLoading;

  PartnerState({
    this.partners = const [],
    this.profile,
    this.isLoading = false,
  });

  PartnerState copyWith({
    List<PartnerModel>? partners,
    Map<String, dynamic>? profile,
    bool? isLoading,
  }) {
    return PartnerState(
      partners: partners ?? this.partners,
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class PartnerNotifier extends StateNotifier<PartnerState> {
  final ApiService _apiService;

  PartnerNotifier(this._apiService) : super(PartnerState());

  Future<void> fetchPartners({String? type}) async {
    try {
      final queryParams = type != null ? {'type': type} : null;
      final response = await _apiService.get('/partners', queryParams: queryParams);
      
      final List<dynamic> data = response is Map ? response['data'] : response;
      state = state.copyWith(
        partners: data.map((item) => PartnerModel.fromJson(item)).toList()
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> fetchProfile() async {
    state = state.copyWith(isLoading: true);
    try {
      final response = await _apiService.get('/partner/profile');
      state = state.copyWith(profile: response['data'], isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  Future<void> requestWithdrawal(double amount) async {
    try {
      await _apiService.post('/partner/withdrawals', {'amount': amount});
      await fetchProfile(); // Refresh balance
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    try {
      await _apiService.put('/partner/profile', data);
      await fetchProfile(); // Refresh local profile data
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateWorkOrderStatus(int orderId, String newStatus) async {
    try {
      await _apiService.post('/partner/orders/$orderId/status', {'status': newStatus});
    } catch (e) {
      rethrow;
    }
  }
}
