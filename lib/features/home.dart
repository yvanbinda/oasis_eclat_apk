import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oasis_eclat/core/app/constants.dart';
import 'package:oasis_eclat/features/Tasks/presentation/pages/add_Customer.dart';
import 'package:oasis_eclat/features/Tasks/presentation/widgets/Task.dart';
import 'package:oasis_eclat/features/Tasks/presentation/widgets/statistics_Card.dart';
import 'package:oasis_eclat/features/app/controllers/homeController.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class HomePage extends StatelessWidget {
  final HomeController homeController = Get.find();

  HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Constants.colorPrimary,
        foregroundColor: Colors.white,
        title: Text(
          "Oasis Eclat Inc",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (String value) {
              switch (value) {
                case 'reset_all':
                  homeController.resetAllPaymentStatuses();
                  break;
                // case 'delete_all':
                //   homeController.delete();
                //   break;
                case 'schedule_notifications':
                  homeController.scheduleAllNotifications();
                  break;

                // case 'delete_all':
                //   homeController.deleteCustomer();
                //   break;
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(
                value: 'reset_all',
                child: Row(
                  children: [
                    Icon(Icons.refresh, color: Colors.orange),
                    SizedBox(width: 8),
                    Text('Reset All Payments'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete_all',
                child: Row(
                  children: [
                    Icon(Icons.delete_forever, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Delete All Customers'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'schedule_notifications',
                child: Row(
                  children: [
                    Icon(Icons.notifications_active, color: Colors.blue),
                    SizedBox(width: 8),
                    Text('Schedule All Reminders'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Obx(() {
        if (homeController.isLoadingCustomers.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return RefreshIndicator(
          onRefresh: homeController.loadCustomers,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Statistics Card
                CustomerStatsCard(),

                // // Quick Actions
                // Padding(
                //   padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                //   child: Row(
                //     children: [
                //       Expanded(
                //         child: _buildQuickActionCard(
                //           'Pending Cleanings',
                //           homeController.customerStats['uncleanedCustomers'].toString(),
                //           Icons.remove_done,
                //           Colors.orange,
                //               () => homeController.setCustomerFilter('UnCleaned'),
                //         ),
                //       ),
                //       SizedBox(width: 12),
                //       Expanded(
                //         child: _buildQuickActionCard(
                //           'Cleaned',
                //           homeController.customerStats['cleanedCustomers'].toString(),
                //           Icons.cleaning_services,
                //           Colors.green,
                //               () => homeController.setCustomerFilter('Cleaned'),
                //         ),
                //       ),
                //     ],
                //   ),
                // ),

                SizedBox(height: 16),

                // Search and Filter Section
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      TextField(
                        decoration: InputDecoration(
                          hintText: 'Search customers...',
                          prefixIcon: Icon(Icons.search),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: EdgeInsets.symmetric(vertical: 4),
                        ),
                        onChanged: homeController.updateSearchQuery,
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: homeController.selectedServiceFilter.value,
                              items: homeController.availableServices
                                  .map((service) => DropdownMenuItem(
                                value: service,
                                child: Text(service),
                              ))
                                  .toList(),
                              onChanged: (value) =>
                                  homeController.setServiceFilter(value!),
                              decoration: InputDecoration(
                                labelText: 'Service Type',
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 4),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 16),

                // Customers List Header
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Upcoming Services",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 18.sp,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      Text(
                        "${homeController.filteredCustomers.length} customers",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),

                // Customers List
                if (homeController.filteredCustomers.isEmpty)
                  _buildEmptyState()
                else
                  ...homeController.filteredCustomers
                      .where((customer) => customer.dateTime != null)
                      .toList()
                      .map((customer) => CustomerCard(customer: customer, task: null,))
                      .toList(),

                SizedBox(height: 100),
              ],
            ),
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.to(() => AddCustomer()),
        backgroundColor: Constants.colorPrimary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildQuickActionCard(String title, String count, IconData icon,
      Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 30),
            SizedBox(height: 8),
            Text(
              count,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.all(32.0),
      child: Column(
        children: [
          Icon(
            Icons.cleaning_services_outlined,
            size: 80,
            color: Colors.orange.shade400,
          ),
          SizedBox(height: 16),
          Text(
            'No customers found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Try adjusting your filters or add a new customer',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}