import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oasis_eclat/core/app/constants.dart';
import 'package:oasis_eclat/features/app/controllers/homeController.dart';

class CustomerStatsCard extends StatelessWidget {
  CustomerStatsCard({super.key});
  final HomeController homeController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Obx(() => Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Constants.colorPrimary, Constants.colorPrimary.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Constants.colorPrimary.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatsItem(
                'Total',
                homeController.customerStats['totalCustomers'].toString(),
                Icons.people,
              ),
              Container(
                height: 40,
                width: 1,
                color: Colors.white.withOpacity(0.3),
              ),
              _StatsItem(
                'Nettoyer',
                homeController.customerStats['cleanedCustomers'].toString(),
                Icons.cleaning_services_outlined,
              ),
              Container(
                height: 40,
                width: 1,
                color: Colors.white.withOpacity(0.3),
              ),
              _StatsItem(
                'En Attente',
                homeController.customerStats['uncleanedCustomers'].toString(),
                Icons.remove_done_outlined,
              ),
            ],
          ),
          const SizedBox(height: 15),
          // // Revenue Progress Bar
          // Column(
          //   children: [
          //     Row(
          //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //       children: [
          //         const Text(
          //           'Monthly Cleanings',
          //           style: TextStyle(
          //             color: Colors.white,
          //             fontWeight: FontWeight.w500,
          //           ),
          //         ),
          //         Text(
          //           '${homeController.customerStats['monthlyRevenue'].toStringAsFixed(2)}',
          //           style: const TextStyle(
          //             color: Colors.white,
          //             fontWeight: FontWeight.bold,
          //           ),
          //         ),
          //       ],
          //     ),
          //     const SizedBox(height: 8),
          //     LinearProgressIndicator(
          //       value: _getRevenueProgressValue(),
          //       backgroundColor: Colors.white.withOpacity(0.3),
          //       valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
          //       minHeight: 6,
          //     ),
          //     const SizedBox(height: 8),
          //     Row(
          //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //       children: [
          //         Text(
          //           'Pending: \$${homeController.customerStats['pendingAmount'].toStringAsFixed(2)}',
          //           style: TextStyle(
          //             color: Colors.white.withOpacity(0.9),
          //           ),
          //         ),
          //         Text(
          //           'Collected: \$${homeController.customerStats['totalRevenue'].toStringAsFixed(2)}',
          //           style: TextStyle(
          //             color: Colors.white.withOpacity(0.9),
          //           ),
          //         ),
          //       ],
          //     ),
          //   ],
          // ),
        ],
      ),
    ));
  }

  double _getRevenueProgressValue() {
    final total = (homeController.customerStats['totalRevenue'] as double) +
        (homeController.customerStats['pendingAmount'] as double);
    if (total <= 0) return 0;
    return (homeController.customerStats['totalRevenue'] as double) / total;
  }

  Widget _StatsItem(String title, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 30),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          title,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}