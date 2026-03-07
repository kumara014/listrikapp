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
      id: json['id'],
      agendaNumber: json['agenda_number'],
      customerId: json['customer_id'],
      partnerId: json['partner_id'],
      litId: json['lit_id'],
      serviceType: json['service_type'],
      status: json['status'],
      address: json['address'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      installationType: json['installation_type'],
      powerCapacity: json['power_capacity'] is String 
          ? int.parse(json['power_capacity']) 
          : json['power_capacity'],
      totalPrice: double.parse(json['total_price'].toString()),
      notes: json['notes'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
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
