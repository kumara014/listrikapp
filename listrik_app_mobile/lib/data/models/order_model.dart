import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OrderModel {
  final int id;
  final String agendaNumber;
  final int customerId;
  final int? partnerId;
  final int? litId;
  final String serviceType;
  final String status;
  final String address;
  final String? latitude;
  final String? longitude;
  final String installationType;
  final int powerCapacity;
  final double totalPrice;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  OrderModel({
    required this.id,
    required this.agendaNumber,
    required this.customerId,
    this.partnerId,
    this.litId,
    required this.serviceType,
    required this.status,
    required this.address,
    this.latitude,
    this.longitude,
    required this.installationType,
    required this.powerCapacity,
    required this.totalPrice,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as int,
      agendaNumber: json['agenda_number']?.toString() ?? '',
      customerId: json['customer_id'] as int,
      partnerId: (json['partner_id'] is String 
          ? int.tryParse(json['partner_id']) 
          : (json['partner_id'] as num?)?.toInt()),
      litId: (json['lit_id'] is String 
          ? int.tryParse(json['lit_id']) 
          : (json['lit_id'] as num?)?.toInt()),
      serviceType: json['service_type']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      address: json['address']?.toString() ?? '',
      latitude: json['latitude']?.toString(),
      longitude: json['longitude']?.toString(),
      installationType: json['installation_type']?.toString() ?? '',
      powerCapacity: (json['power_capacity'] is String 
          ? (int.tryParse(json['power_capacity']) ?? 0)
          : (json['power_capacity'] as num?)?.toInt() ?? 0),
      totalPrice: (json['total_price'] is String 
          ? (double.tryParse(json['total_price']) ?? 0.0)
          : (json['total_price'] as num?)?.toDouble() ?? 0.0),
      notes: json['notes']?.toString(),
      createdAt: json['created_at'] != null 
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updated_at'] != null 
          ? DateTime.tryParse(json['updated_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'agenda_number': agendaNumber,
      'customer_id': customerId,
      'partner_id': partnerId,
      'lit_id': litId,
      'service_type': serviceType,
      'status': status,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'installation_type': installationType,
      'power_capacity': powerCapacity,
      'total_price': totalPrice,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Color get statusColor {
    switch (status) {
      case 'pending':
        return Colors.grey;
      case 'verified':
        return Colors.blue;
      case 'in_progress':
        return Colors.orange;
      case 'generate':
        return Colors.purple;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String get statusLabel {
    switch (status) {
      case 'pending':
        return 'Menunggu';
      case 'verified':
        return 'Diverifikasi';
      case 'in_progress':
        return 'Progres';
      case 'generate':
        return 'Sertifikat';
      case 'completed':
        return 'Selesai';
      case 'cancelled':
        return 'Dibatalkan';
      default:
        return status;
    }
  }

  String get formattedPrice {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(totalPrice);
  }

  String get serviceTypeLabel {
    switch (serviceType) {
      case 'nidi':
        return "NIDI";
      case 'slo':
        return "SLO";
      case 'nidi_slo':
        return "NIDI & SLO";
      case 'full_package':
        return "Paket Lengkap";
      default:
        return serviceType.toUpperCase();
    }
  }
}
