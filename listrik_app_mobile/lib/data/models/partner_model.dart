import 'user_model.dart';

class PartnerModel {
  final int id;
  final String companyName;
  final String type;
  final String status;
  final double balance;
  final UserModel? user;

  PartnerModel({
    required this.id,
    required this.companyName,
    required this.type,
    required this.status,
    required this.balance,
    this.user,
  });

  factory PartnerModel.fromJson(Map<String, dynamic> json) {
    return PartnerModel(
      id: json['id'],
      companyName: json['company_name'],
      type: json['type'],
      status: json['status'],
      balance: (json['balance'] as num).toDouble(),
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
    );
  }
}
