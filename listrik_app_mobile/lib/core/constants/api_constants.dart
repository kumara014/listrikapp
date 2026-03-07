class ApiConstants {
  static const String baseUrl = 'http://10.0.2.2:8000/api';
  
  // Auth endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String googleLogin = '/auth/google';
  static const String logout = '/auth/logout';
  static const String me = '/auth/me';
  
  // Partner endpoints
  static const String partnerProfile = '/partner/profile';
  static const String partnerOrders = '/partner/orders';
  static const String partnerWithdrawals = '/partner/withdrawals';
}
