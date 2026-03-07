import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../../core/constants/api_constants.dart';

final apiServiceProvider = Provider((ref) => ApiService());

final authProvider = StateNotifierProvider<AuthNotifier, UserModel?>(
  (ref) => AuthNotifier(ref.watch(apiServiceProvider)),
);

class AuthNotifier extends StateNotifier<UserModel?> {
  final ApiService _apiService;

  AuthNotifier(this._apiService) : super(null);

  bool get isLoggedIn => state != null;

  Future<void> login(String email, String password) async {
    try {
      final response = await _apiService.post(ApiConstants.login, {
        'email': email,
        'password': password,
      });

      final token = response['access_token'];
      final user = UserModel.fromJson(response['user']);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);

      state = user;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> loginWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email'],
        serverClientId:
            '958887878345-3msmraoo2m6kpn6859nt8gqmr4vvr7er.apps.googleusercontent.com', // <-- Tambahkan baris ini
      );

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception("Google Sign In was cancelled");
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        throw Exception("Failed to get Google ID Token");
      }

      // Send to backend
      final response = await _apiService.post(ApiConstants.googleLogin, {
        'id_token': idToken,
        'role': 'customer', // Default role for Google login
      });

      final token = response['access_token'];
      final user = UserModel.fromJson(response['user']);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);

      state = user;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> register(
    String name,
    String email,
    String password,
    String phone,
  ) async {
    try {
      final response = await _apiService.post(ApiConstants.register, {
        'name': name,
        'email': email,
        'password': password,
        'phone': phone,
      });

      final token = response['access_token'];
      final user = UserModel.fromJson(response['user']);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);

      state = user;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await _apiService.post(ApiConstants.logout, {});
    } finally {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      state = null;
    }
  }

  Future<void> getCurrentUser() async {
    try {
      final response = await _apiService.get(ApiConstants.me);
      state = UserModel.fromJson(response);
    } catch (e) {
      state = null;
      rethrow;
    }
  }
}
