import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oasis_eclat/data/models/customer_model.dart';
import 'package:oasis_eclat/data/services/database_service.dart';
import 'package:oasis_eclat/data/services/notification_service.dart';

class HomeController extends GetxController {
  final DatabaseService _databaseService = DatabaseService.instance;
  final NotificationService _notificationService = NotificationService.instance;

  // Observable lists
  var customers = <Customer>[].obs;
  var filteredCustomersList = <Customer>[].obs;

  // Loading states
  var isLoadingCustomers = false.obs;
  var isAddingCustomer = false.obs;
  var isUpdatingCustomer = false.obs;
  var isDeletingCustomer = false.obs;
  var isLoadingStats = false.obs;

  // Filter states
  var selectedCustomerFilter = 'All'.obs;
  var selectedServiceFilter = 'All'.obs;
  var searchQuery = ''.obs;

  // Statistics
  var customerStats = <String, dynamic>{}.obs;

  @override
  void onInit() {
    super.onInit();
    loadCustomers();
    loadCustomerStatistics();
    _initializeNotifications();

    // Listen to search query changes
    debounce(searchQuery, (_) => _performSearch(), time: const Duration(milliseconds: 500));
  }

  // Initialize notification service
  Future<void> _initializeNotifications() async {
    try {
      await _notificationService.initialize();
    } catch (e) {
      print('Failed to initialize notifications: $e'.tr);
    }
  }

  // ==================== CUSTOMER METHODS ====================

  /// Load all customers from database
  Future<void> loadCustomers() async {
    try {
      isLoadingCustomers.value = true;
      final allCustomers = await _databaseService.getAllCustomers();
      customers.value = allCustomers;
      _applyFilters();
    } catch (e) {
      _showErrorSnackbar('Failed to load customers: $e'.tr);
    } finally {
      isLoadingCustomers.value = false;
    }
  }

  /// Add a new customer
  Future<void> addCustomer({
    required String customerName,
    required String service,
    required String address,
    required String phone,
    required String dateTime,
    required double amountToBePaid,
    required bool isCleaned,
  }) async {
    try {
      isAddingCustomer.value = true;

      final newCustomer = Customer(
        customerName: customerName,
        service: service,
        address: address,
        phone: phone,
        dateTime: dateTime,
        amountToBePaid: amountToBePaid,
        isCleaned: isCleaned,
      );

      final id = await _databaseService.addCustomer(newCustomer);

      if (id > 0) {
        // Create customer with ID for notification scheduling
        final customerWithId = newCustomer.copyWith(id: id);

        // Schedule notification for the new customer
        await _notificationService.scheduleServiceReminder(customerWithId);

        await loadCustomers(); // Refresh the list
        await loadCustomerStatistics(); // Refresh statistics

        _showSuccessSnackbar('Customer added successfully!'.tr);
      }
    } catch (e) {
      _showErrorSnackbar('Failed to add customer: $e'.tr);
    } finally {
      isAddingCustomer.value = false;
    }
  }

  /// Update an existing customer
  Future<void> updateCustomer(Customer customer) async {
    try {
      isUpdatingCustomer.value = true;
      final rowsUpdated = await _databaseService.updateCustomer(customer);

      if (rowsUpdated > 0) {
        // Cancel existing notifications and schedule new ones
        await _notificationService.cancelCustomerNotifications(customer.id!);
        await _notificationService.scheduleServiceReminder(customer);

        await loadCustomers(); // Refresh the list
        await loadCustomerStatistics(); // Refresh statistics

        _showSuccessSnackbar('Customer updated successfully!'.tr);
      }
    } catch (e) {
      _showErrorSnackbar('Failed to update customer: $e'.tr);
    } finally {
      isUpdatingCustomer.value = false;
    }
  }

  /// Toggle customer payment status
  Future<void> toggleCustomerPaymentStatus(int customerId) async {
    try {
      isUpdatingCustomer.value = true;
      final rowsUpdated = await _databaseService.togglePaymentStatus(customerId);

      if (rowsUpdated > 0) {
        // Update the local customer list immediately
        final customerIndex = customers.indexWhere((customer) => customer.id == customerId);
        if (customerIndex != -1) {
          customers[customerIndex] = customers[customerIndex].copyWith(
            isCleaned: !customers[customerIndex].isCleaned,
          );
          customers.refresh();
          _applyFilters();
        }

        await loadCustomerStatistics(); // Refresh statistics

        final customer = customers.firstWhere((c) => c.id == customerId);
        _showSuccessSnackbar(
          customer.isCleaned ? 'Service marked as cleaned!'.tr : 'Service marked as not Cleaned!'.tr,
          backgroundColor: customer.isCleaned ? Colors.green.shade100 : Colors.orange.shade100,
          textColor: customer.isCleaned ? Colors.green.shade800 : Colors.orange.shade800,
        );
      }
    } catch (e) {
      _showErrorSnackbar('Failed to update cleaning status: $e'.tr);
    } finally {
      isUpdatingCustomer.value = false;
    }
  }

  /// Toggle payment status (alias for consistency)
  Future<void> togglePaymentStatus(int customerId) async {
    await toggleCustomerPaymentStatus(customerId);
  }

  /// Delete a customer
  Future<void> deleteCustomer(int customerId) async {
    try {
      // Show confirmation dialog
      final bool? confirmed = await Get.dialog<bool>(
        AlertDialog(
          title:  Text('Delete Customer'.tr),
          content:  Text('Are you sure you want to delete this customer? This action cannot be undone.'.tr),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child:  Text('Cancel'.tr),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child:  Text('Delete'.tr),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        isDeletingCustomer.value = true;

        // Cancel notifications for this customer
        await _notificationService.cancelCustomerNotifications(customerId);

        final rowsDeleted = await _databaseService.deleteCustomer(customerId);

        if (rowsDeleted > 0) {
          await loadCustomers(); // Refresh the list
          await loadCustomerStatistics(); // Refresh statistics

          _showSuccessSnackbar('Customer deleted successfully!'.tr);
        }
      }
    } catch (e) {
      _showErrorSnackbar('Failed to delete customer: $e'.tr);
    } finally {
      isDeletingCustomer.value = false;
    }
  }

  // ==================== STATISTICS METHODS ====================

  /// Load customer statistics
  Future<void> loadCustomerStatistics() async {
    try {
      isLoadingStats.value = true;

      final totalCount = await _databaseService.getCustomersCount();
      final cleanedCount = await _databaseService.getCleanedCustomersCount();
      final totalRevenue = await _databaseService.getTotalRevenue();
      final pendingAmount = await _databaseService.getTotalPendingAmount();

      // Get service type distribution
      final allCustomers = await _databaseService.getAllCustomers();
      final serviceDistribution = <String, int>{};
      for (final customer in allCustomers) {
        serviceDistribution[customer.service] = (serviceDistribution[customer.service] ?? 0) + 1;
      }

      // Get monthly revenue (current month)
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfMonth = DateTime(now.year, now.month + 1, 0);
      final monthlyCustomers = await _databaseService.getCustomersByDateRange(
        startOfMonth.toIso8601String(),
        endOfMonth.toIso8601String(),
      );
      final monthlyCleaned = monthlyCustomers
          .where((c) => c.isCleaned)
          .fold(0.0, (sum, c) => sum + c.amountToBePaid);

      customerStats.value = {
        'totalCustomers': totalCount,
        'cleanedCustomers': cleanedCount,
        'uncleanedCustomers': totalCount - cleanedCount,
        'totalRevenue': totalRevenue,
        'pendingAmount': pendingAmount,
        'monthlyCleaned': monthlyCleaned,
        'serviceDistribution': serviceDistribution,
        'paymentRate': totalCount > 0 ? (cleanedCount / totalCount * 100).round() : 0,
        'averageServiceValue': totalCount > 0 ? (totalRevenue + pendingAmount) / totalCount : 0.0,
      };
    } catch (e) {
      print('Failed to load statistics: $e'.tr);
      customerStats.value = {
        'totalCustomers': 0,
        'cleanedCustomers': 0,
        'uncleanedCustomers': 0,
        'totalRevenue': 0.0,
        'pendingAmount': 0.0,
        'monthlyCleaned': 0.0,
        'serviceDistribution': <String, int>{},
        'paymentRate': 0,
        'averageServiceValue': 0.0,
      };
    } finally {
      isLoadingStats.value = false;
    }
  }

  // ==================== FILTER AND SEARCH METHODS ====================

  /// Apply current filters to customer list
  void _applyFilters() {
    var filtered = customers.toList();

    // Apply payment status filter
    switch (selectedCustomerFilter.value) {
      case 'Nettoyer':
        filtered = filtered.where((customer) => customer.isCleaned).toList();
        break;
      case 'En Attente':
        filtered = filtered.where((customer) => !customer.isCleaned).toList();
        break;
    }

    // Apply service filter
    if (selectedServiceFilter.value != 'All') {
      filtered = filtered.where((customer) => customer.service == selectedServiceFilter.value).toList();
    }

    // Apply search filter
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      filtered = filtered.where((customer) =>
      customer.customerName.toLowerCase().contains(query) ||
          customer.service.toLowerCase().contains(query) ||
          customer.phone.contains(query) ||
          customer.address.toLowerCase().contains(query)
      ).toList();
    }

    filteredCustomersList.value = filtered;
  }

  /// Set customer payment filter
  void setCustomerFilter(String filter) {
    selectedCustomerFilter.value = filter;
    _applyFilters();
  }

  /// Set service type filter
  void setServiceFilter(String filter) {
    selectedServiceFilter.value = filter;
    _applyFilters();
  }

  /// Update search query
  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  /// Perform search with debouncing
  void _performSearch() {
    _applyFilters();
  }

  /// Get unique service types from customers
  List<String> get availableServices {
    final services = customers.map((c) => c.service).toSet().toList();
    services.sort();
    return ['All', ...services];
  }

  // ==================== UTILITY METHODS ====================

  /// Get filtered customers based on current filters
  List<Customer> get filteredCustomers => filteredCustomersList.toList();

  /// Reset all customer payment statuses to unpaid
  Future<void> resetAllPaymentStatuses() async {
    try {
      final bool? confirmed = await Get.dialog<bool>(
        AlertDialog(
          title:  Text('Reset All Services'.tr),
          content:  Text('Are you sure you want to mark all customers as NotCleaned? This action cannot be undone.'.tr),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child:  Text('Cancel'.tr),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              style: TextButton.styleFrom(foregroundColor: Colors.orange),
              child:  Text('Reset'.tr),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        await _databaseService.resetAllPaymentStatus();
        await loadCustomers();
        await loadCustomerStatistics();

        _showSuccessSnackbar('All payments reset to notCleaned!'.tr);
      }
    } catch (e) {
      _showErrorSnackbar('Failed to reset payment statuses: $e'.tr);
    }
  }

  /// Export customer data (placeholder for future implementation)
  Future<void> exportCustomerData() async {
    try {
      // TODO: Implement CSV export functionality
      _showInfoSnackbar('Export functionality coming soon!'.tr);
    } catch (e) {
      _showErrorSnackbar('Failed to export data: $e'.tr);
    }
  }

  // ==================== NOTIFICATION METHODS ====================

  /// Test notification for a specific customer
  Future<void> testCustomerNotification(Customer customer) async {
    try {
      await _notificationService.showTestCustomerNotification(customer);
      _showInfoSnackbar('Test notification sent for ${customer.customerName}!'.tr);
    } catch (e) {
      _showErrorSnackbar('Failed to send test notification: $e'.tr);
    }
  }

  /// Schedule notifications for all customers
  Future<void> scheduleAllNotifications() async {
    try {
      for (final customer in customers) {
        if (customer.id != null) {
          await _notificationService.scheduleServiceReminder(customer);
        }
      }
      _showSuccessSnackbar('Notifications scheduled for all customers!'.tr);
    } catch (e) {
      _showErrorSnackbar('Failed to schedule notifications: $e'.tr);
    }
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    try {
      await _notificationService.cancelAllNotifications();
      _showSuccessSnackbar('All notifications cancelled!'.tr);
    } catch (e) {
      _showErrorSnackbar('Failed to cancel notifications: $e'.tr);
    }
  }

  /// Get pending notifications count
  Future<int> getPendingNotificationsCount() async {
    try {
      final notifications = await _notificationService.getPendingNotifications();
      return notifications.length;
    } catch (e) {
      return 0;
    }
  }

  // ==================== HELPER METHODS ====================

  void _showSuccessSnackbar(String message, {Color? backgroundColor, Color? textColor}) {
    Get.snackbar(
      'Success'.tr,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: backgroundColor ?? Colors.green.shade100,
      colorText: textColor ?? Colors.green.shade800,
      duration: const Duration(seconds: 3),
    );
  }

  void _showErrorSnackbar(String message) {
    Get.snackbar(
      'Error'.tr,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.shade100,
      colorText: Colors.red.shade800,
      duration: const Duration(seconds: 4),
    );
  }

  void _showInfoSnackbar(String message) {
    Get.snackbar(
      'Info'.tr,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue.shade100,
      colorText: Colors.blue.shade800,
      duration: const Duration(seconds: 3),
    );
  }

  @override
  void onClose() {
    // Clean up resources if needed
    super.onClose();
  }
}