import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../data/models/order_model.dart';
import 'package:go_router/go_router.dart';

class WorkOrderCard extends StatelessWidget {
  final OrderModel order;
  const WorkOrderCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    bool isNew = order.status == 'verified' || order.status == 'pending';
    bool isProgress = order.status == 'in_progress';
    bool isGenerate = order.status == 'generate';
    
    Color leftBorderColor = isNew ? AppColors.blue500 : (isProgress ? AppColors.orange500 : (isGenerate ? AppColors.purple500 : AppColors.gray200));

    return GestureDetector(
      onTap: () => context.push('/partner/orders/${order.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2))],
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(
                width: 4,
                decoration: BoxDecoration(
                  color: leftBorderColor,
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(14), bottomLeft: Radius.circular(14)),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(order.agendaNumber, style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.gray800)),
                              const SizedBox(height: 2),
                              Text('👤 Customer #${order.customerId}', style: const TextStyle(fontSize: 10, color: AppColors.gray600, fontWeight: FontWeight.w500)),
                            ],
                          ),
                          _buildBadge(order.status),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 10, color: AppColors.gray400),
                          const SizedBox(width: 4),
                          Expanded(child: Text(order.address, style: const TextStyle(fontSize: 9, color: AppColors.gray400, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Divider(height: 1, color: AppColors.gray50),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(color: AppColors.blue50, borderRadius: BorderRadius.circular(100)),
                            child: Text(order.serviceTypeLabel, style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.blue700)),
                          ),
                          Row(
                            children: [
                              const Text('5 menit lalu', style: TextStyle(fontSize: 9, color: AppColors.gray400, fontWeight: FontWeight.w500)),
                              const SizedBox(width: 10),
                              Text(order.formattedPrice, style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.green500)),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(String status) {
    Color bg = AppColors.gray100;
    Color fg = AppColors.gray400;
    String label = status.toUpperCase();

    if (status == 'verified' || status == 'pending') {
      bg = AppColors.blue100;
      fg = AppColors.blue700;
      label = 'BARU';
    } else if (status == 'in_progress') {
      bg = AppColors.orange100;
      fg = AppColors.orange500;
      label = 'DIKERJAKAN';
    } else if (status == 'generate') {
      bg = AppColors.purple100;
      fg = AppColors.purple500;
      label = 'GENERATE';
    } else if (status == 'completed') {
      bg = AppColors.green100;
      fg = AppColors.green500;
      label = 'SELESAI';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(100)),
      child: Text(label, style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 9, fontWeight: FontWeight.w800, color: fg)),
    );
  }
}
