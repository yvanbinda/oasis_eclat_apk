import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oasis_eclat/data/models/customer_model.dart';
import 'package:oasis_eclat/features/app/controllers/homeController.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class EditCustForm extends StatefulWidget {
  final Customer customer;

  const EditCustForm({super.key, required this.customer});

  @override
  State<EditCustForm> createState() => _EditCustFormState();
}

class _EditCustFormState extends State<EditCustForm> {
  final _formKey = GlobalKey<FormState>();
  final HomeController _homeController = Get.find<HomeController>();

  // Text editing controllers
  late TextEditingController _nameController;
  late TextEditingController _serviceController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _amountController;

  // Date and time
  late DateTime _selectedDateTime;
  late bool _isCleaned;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with customer data
    _nameController = TextEditingController(text: widget.customer.customerName);
    _serviceController = TextEditingController(text: widget.customer.service);
    _phoneController = TextEditingController(text: widget.customer.phone);
    _addressController = TextEditingController(text: widget.customer.address);
    _amountController = TextEditingController(
      text: widget.customer.amountToBePaid.toStringAsFixed(2),
    );

    // Parse the existing date time
    _selectedDateTime = DateTime.parse(widget.customer.dateTime);
    _isCleaned = widget.customer.isCleaned;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _serviceController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _selectDateTime() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
      );

      if (pickedTime != null) {
        setState(() {
          _selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final updatedCustomer = Customer(
        id: widget.customer.id,
        customerName: _nameController.text.trim(),
        service: _serviceController.text.trim(),
        address: _addressController.text.trim(),
        phone: _phoneController.text.trim(),
        dateTime: _selectedDateTime.toIso8601String(),
        amountToBePaid: double.tryParse(_amountController.text.trim()) ?? 0.0,
        isCleaned: _isCleaned,
      );

      await _homeController.updateCustomer(updatedCustomer);

      // Navigate back if successful
      if (!_homeController.isUpdatingCustomer.value) {
        Get.back();
        Get.snackbar(
          'Success'.tr,
          'Customer updated successfully'.tr,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  Text('Edit Customer'.tr),
        backgroundColor: Colors.teal.shade600,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 2.h),

                // Customer Name Field
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Customer Name'.tr,
                      hintText: 'Enter customer name'.tr,
                      prefixIcon: Icon(Icons.person, color: Colors.orange.shade600),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter the customer name'.tr;
                      }
                      if (value.trim().length < 2) {
                        return 'Customer name must be at least 2 characters'.tr;
                      }
                      return null;
                    },
                    textCapitalization: TextCapitalization.words,
                  ),
                ),

                SizedBox(height: 1.h),

                // Service Field
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextFormField(
                    controller: _serviceController,
                    decoration: InputDecoration(
                      labelText: 'Service'.tr,
                      hintText: 'e.g., Residential Cleaning'.tr,
                      prefixIcon: Icon(Icons.cleaning_services, color: Colors.orange.shade600),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter the service type'.tr;
                      }
                      return null;
                    },
                    textCapitalization: TextCapitalization.words,
                  ),
                ),

                SizedBox(height: 1.h),

                // Phone Field
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'Phone Number'.tr,
                      hintText: 'e.g., +1 234 567 8900',
                      prefixIcon: Icon(Icons.phone, color: Colors.orange.shade600),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter the phone number'.tr;
                      }
                      if (value.trim().length < 10) {
                        return 'Please enter a valid phone number'.tr;
                      }
                      return null;
                    },
                  ),
                ),

                SizedBox(height: 1.h),

                // Address Field
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextFormField(
                    controller: _addressController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: 'Address'.tr,
                      hintText: 'Enter service address'.tr,
                      prefixIcon: Icon(Icons.location_on, color: Colors.orange.shade600),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter the service address'.tr;
                      }
                      return null;
                    },
                    textCapitalization: TextCapitalization.words,
                  ),
                ),

                SizedBox(height: 1.h),

                // Amount Field
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextFormField(
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Amount to be Paid'.tr,
                      hintText: 'e.g., 150.00',
                      prefixIcon: Icon(Icons.attach_money, color: Colors.orange.shade600),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter the amount'.tr;
                      }
                      final amount = double.tryParse(value.trim());
                      if (amount == null) {
                        return 'Please enter a valid amount'.tr;
                      }
                      if (amount <= 0) {
                        return 'Amount must be greater than 0'.tr;
                      }
                      return null;
                    },
                  ),
                ),

                SizedBox(height: 1.h),

                // Date and Time Picker
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      leading: Icon(Icons.event, color: Colors.orange.shade600),
                      title:  Text('Service Date & Time'.tr),
                      subtitle: Text(_formatDateTime(_selectedDateTime)),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: _selectDateTime,
                    ),
                  ),
                ),

                SizedBox(height: 1.h),

                // Payment Status Switch
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: SwitchListTile(
                      secondary: Icon(Icons.cleaning_services, color: Colors.orange.shade600),
                      title:  Text('Payment Status'.tr),
                      subtitle: Text(_isCleaned ? 'Cleaned'.tr : 'UnCleaned'.tr),
                      value: _isCleaned,
                      onChanged: (bool value) {
                        setState(() {
                          _isCleaned = value;
                        });
                      },
                      activeColor: Colors.teal.shade600,
                    ),
                  ),
                ),

                SizedBox(height: 3.h),

                // Action Buttons
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Obx(() => ElevatedButton(
                          onPressed: _homeController.isUpdatingCustomer.value ? null : _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal.shade600,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _homeController.isUpdatingCustomer.value
                              ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                              : Text(
                            'Ajouter'.tr,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _homeController.isUpdatingCustomer.value ? null : () => Get.back(),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.grey.shade700,
                            side: BorderSide(color: Colors.grey.shade400),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child:  Text(
                            'Annuler'.tr,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}