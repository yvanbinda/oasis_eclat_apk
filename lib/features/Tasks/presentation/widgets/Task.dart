import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oasis_eclat/core/app/constants.dart';
import 'package:oasis_eclat/data/models/customer_model.dart';
import 'package:oasis_eclat/features/Tasks/presentation/widgets/EditTask.dart';
import 'package:oasis_eclat/features/app/controllers/homeController.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class CustomerCard extends StatelessWidget {
  final Customer customer;
  final VoidCallback? onTap;
  final bool showActions;
  final bool isCompact;

  const CustomerCard({
    super.key,
    required this.customer,
    this.onTap,
    this.showActions = true,
    this.isCompact = false, required task,
  });

  @override
  Widget build(BuildContext context) {
    final HomeController homeController = Get.find();

    return GetBuilder<HomeController>(
      builder: (controller) => AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: EdgeInsets.symmetric(
          horizontal: isCompact ? 8.0 : 16.0,
          vertical: isCompact ? 4.0 : 6.0,
        ),
        decoration: BoxDecoration(
          color: _getCardColor(),
          borderRadius: BorderRadius.circular(isCompact ? 8 : 12),
          border: Border.all(
            color: _getBorderColor(),
            width: customer.isCleaned ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: isCompact ? 3 : 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: InkWell(
          onTap: onTap ?? () => _showCustomerDetails(customer, homeController),
          borderRadius: BorderRadius.circular(isCompact ? 8 : 12),
          child: Padding(
            padding: EdgeInsets.all(isCompact ? 12.0 : 16.0),
            child: Row(
              children: [
                // Leading Icon
                _buildLeadingIcon(),

                SizedBox(width: isCompact ? 12 : 16),

                // Customer Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Customer Name
                      Text(
                        customer.customerName,
                        style: TextStyle(
                          fontSize: isCompact ? 14.sp : 16.sp,
                          fontWeight: FontWeight.w600,
                          color: customer.isCleaned ? Colors.grey.shade600 : Colors.grey.shade800,
                          decoration: customer.isCleaned ? TextDecoration.lineThrough : null,
                        ),
                        maxLines: isCompact ? 1 : 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      if (!isCompact) ...[
                        const SizedBox(height: 4),
                        // Service
                        _buildInfoRow(Icons.cleaning_services, customer.service),
                        const SizedBox(height: 2),
                        // Phone and Address
                        _buildInfoRow(Icons.phone, '${customer.phone} • ${customer.address}'),
                      ],
                    ],
                  ),
                ),

                // Actions
                if (showActions) ...[
                  const SizedBox(width: 8),
                  _buildActions(homeController),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLeadingIcon() {
    return Container(
      width: isCompact ? 40 : 50,
      height: isCompact ? 40 : 50,
      decoration: BoxDecoration(
        color: customer.isCleaned
            ? Colors.green.shade100
            : Constants.colorPrimary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(isCompact ? 20 : 25),
        border: customer.isCleaned
            ? Border.all(color: Colors.green.shade300, width: 2)
            : null,
      ),
      child: Icon(
        customer.isCleaned ? Icons.cleaning_services : Icons.person,
        color: customer.isCleaned ? Colors.green : Constants.colorPrimary,
        size: isCompact ? 20 : 28,
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey.shade600),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 13,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildActions(HomeController homeController) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Quick Payment Toggle
        Obx(() => GestureDetector(
          onTap: homeController.isUpdatingCustomer.value
              ? null
              : () => homeController.togglePaymentStatus(customer.id!),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: customer.isCleaned ? Colors.green : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: customer.isCleaned ? Colors.green.shade700 : Colors.grey.shade400,
                width: 2,
              ),
            ),
            child: customer.isCleaned
                ? const Icon(Icons.check, color: Colors.white, size: 16)
                : null,
          ),
        )),

        if (!isCompact) ...[
          const SizedBox(width: 8),
          // More Options Menu
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert,
              color: Colors.grey.shade600,
              size: 20,
            ),
            offset: const Offset(0, 40),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            itemBuilder: (context) => [
              _buildPopupMenuItem(
                'edit',
                Icons.edit,
                'Edit Customer',
                Colors.blue,
              ),
              _buildPopupMenuItem(
                'notify',
                Icons.notifications_outlined,
                'Test Notification',
                Colors.orange,
              ),
              const PopupMenuDivider(),
              _buildPopupMenuItem(
                'delete',
                Icons.delete_outline,
                'Delete Customer',
                Colors.red,
              ),
            ],
            onSelected: (value) => _handleMenuAction(value, homeController),
          ),
        ],
      ],
    );
  }

  PopupMenuItem<String> _buildPopupMenuItem(
      String value,
      IconData icon,
      String text,
      Color color,
      ) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
              color: Colors.grey.shade800,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  void _handleMenuAction(String action, HomeController homeController) {
    switch (action) {
      case 'edit':
        _editCustomer(customer, homeController);
        break;
      case 'notify':
        homeController.testCustomerNotification(customer);
        break;
      case 'delete':
        _deleteCustomer(customer, homeController);
        break;
    }
  }

  Color _getCardColor() {
    if (customer.isCleaned) {
      return Colors.green.shade50;
    }
    return Colors.white;
  }

  Color _getBorderColor() {
    if (customer.isCleaned) {
      return Colors.green.shade200;
    }
    return Colors.grey.shade200;
  }

  void _showCustomerDetails(Customer customer, HomeController homeController) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: customer.isCleaned
                              ? Colors.green.shade100
                              : Constants.colorPrimary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(30),
                          border: customer.isCleaned
                              ? Border.all(color: Colors.green.shade300, width: 2)
                              : null,
                        ),
                        child: Icon(
                          customer.isCleaned ? Icons.cleaning_services : Icons.person,
                          color: customer.isCleaned ? Colors.green : Constants.colorPrimary,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              customer.customerName,
                              style: TextStyle(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: customer.isCleaned
                                    ? Colors.green.shade100
                                    : Colors.orange.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                customer.isCleaned ? 'Nettoyer' : 'En Attente',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w500,
                                  color: customer.isCleaned
                                      ? Colors.green.shade700
                                      : Colors.orange.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Details Section
                  _buildDetailRow(Icons.cleaning_services, 'Service', customer.service),
                  const SizedBox(height: 16),
                  _buildDetailRow(Icons.phone, 'Phone', customer.phone),
                  const SizedBox(height: 16),
                  _buildDetailRow(Icons.location_on, 'Address', customer.address),
                  const SizedBox(height: 16),
                  _buildDetailRow(Icons.access_time, 'Date & Time', _formatDateTime(customer.dateTime)),
                  const SizedBox(height: 16),
                  _buildDetailRow(Icons.payment, 'Amount', '\$${customer.amountToBePaid.toStringAsFixed(2)}'),

                  const SizedBox(height: 24),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Get.back();
                            _editCustomer(customer, homeController);
                          },
                          icon: const Icon(Icons.edit, size: 18),
                          label: const Text('Edit'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      // const SizedBox(width: 8),
                      // Expanded(
                      //   child: OutlinedButton.icon(
                      //     onPressed: () {
                      //       Get.back();
                      //       homeController.testCustomerNotification(customer);
                      //     },
                      //     icon: const Icon(Icons.notifications, size: 18),
                      //     label: const Text('Notify'),
                      //     style: OutlinedButton.styleFrom(
                      //       foregroundColor: Colors.orange,
                      //       side: const BorderSide(color: Colors.orange),
                      //       padding: const EdgeInsets.symmetric(vertical: 12),
                      //       shape: RoundedRectangleBorder(
                      //         borderRadius: BorderRadius.circular(8),
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Obx(() => ElevatedButton.icon(
                          onPressed: homeController.isUpdatingCustomer.value
                              ? null
                              : () {
                            homeController.togglePaymentStatus(customer.id!);
                            Get.back();
                          },
                          icon: Icon(
                            customer.isCleaned ? Icons.cleaning_services_outlined : Icons.cleaning_services,
                            size: 18,
                          ),
                          label: Text(customer.isCleaned ? 'En Attente' : 'Nettoyer'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: customer.isCleaned ? Colors.orange : Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        )),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Constants.colorPrimary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            icon,
            color: Constants.colorPrimary,
            size: 20,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey.shade800,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _editCustomer(Customer customer, HomeController homeController) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: EditCustForm(customer: customer),
      ),
    );
  }

  void _deleteCustomer(Customer customer, HomeController homeController) {
    homeController.deleteCustomer(customer.id!);
  }

  String _formatDateTime(String dateTimeString) {
    try {
      final dateTime = DateTime.parse(dateTimeString);
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateTimeString;
    }
  }
}