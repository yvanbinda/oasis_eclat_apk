import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:oasis_eclat/data/models/customer_model.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final NotificationService instance = NotificationService._constructor();
  static FlutterLocalNotificationsPlugin? _notificationsPlugin;

  NotificationService._constructor();

  // Initialize the notification service
  Future<void> initialize() async {
    tz.initializeTimeZones();
    _notificationsPlugin = FlutterLocalNotificationsPlugin();

    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@drawable/ic_launcher');

    const DarwinInitializationSettings iosSettings =
    DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin!.initialize(initSettings);

    // Request permissions for Android 13+
    await _notificationsPlugin!
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  // Schedule automatic notifications for a customer service (24hrs and 1hr before)
  Future<void> scheduleServiceReminder(Customer customer) async {
    if (customer.id == null) return;

    // Cancel existing notifications for this customer first
    await cancelCustomerNotifications(customer.id!);

    try {
      // Parse the customer's dateTime (expecting format: "2024-12-25 14:30:00" or "2024-12-25T14:30:00")
      DateTime serviceDateTime;
      if (customer.dateTime.contains('T')) {
        serviceDateTime = DateTime.parse(customer.dateTime);
      } else {
        serviceDateTime = DateTime.parse(customer.dateTime.replaceFirst(' ', 'T'));
      }

      final now = DateTime.now();

      // Convert to timezone-aware datetime
      final tz.TZDateTime serviceTime = tz.TZDateTime.from(serviceDateTime, tz.local);

      // Only schedule notifications if service is in the future
      if (serviceTime.isAfter(tz.TZDateTime.now(tz.local))) {
        // Schedule 24-hour reminder
        await _schedule24HourReminder(customer, serviceTime);

        // Schedule 1-hour reminder
        await _schedule1HourReminder(customer, serviceTime);
      }
    } catch (e) {
      print('Error scheduling service reminder for ${customer.customerName}: $e'.tr);
    }
  }

  // Schedule 24-hour reminder
  Future<void> _schedule24HourReminder(Customer customer, tz.TZDateTime serviceTime) async {
    final reminderTime = serviceTime.subtract(const Duration(hours: 24));
    final now = tz.TZDateTime.now(tz.local);

    // Only schedule if reminder time is in the future
    if (reminderTime.isAfter(now)) {
       AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'service_reminders_24h'.tr,
        '24-Hour Service Reminders',
        channelDescription: '24-hour advance reminders for cleaning services'.tr,
        importance: Importance.high,
        priority: Priority.high,
        icon: '@drawable/ic_launcher',
        playSound: true,
        enableVibration: true,
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        sound: 'default',
      );

       NotificationDetails platformDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      // Use customer ID * 100 + 24 for unique notification ID
      final notificationId = (customer.id! * 100) + 24;

      await _notificationsPlugin!.zonedSchedule(
        notificationId,
        '🧹 Service Reminder - Tomorrow'.tr,
        'Hi ${customer.customerName}! Your ${customer.service} service is scheduled for tomorrow at ${_formatTime(serviceTime)}.\nLocation: ${customer.address}'.tr,
        reminderTime,
        platformDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    }
  }

  // Schedule 1-hour reminder
  Future<void> _schedule1HourReminder(Customer customer, tz.TZDateTime serviceTime) async {
    final reminderTime = serviceTime.subtract(const Duration(hours: 1));
    final now = tz.TZDateTime.now(tz.local);

    // Only schedule if reminder time is in the future
    if (reminderTime.isAfter(now)) {
       AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'service_reminders_1h'.tr,
        '1-Hour Service Reminders'.tr,
        channelDescription: '1-hour advance reminders for cleaning services'.tr,
        importance: Importance.max,
        priority: Priority.max,
        icon: '@drawable/ic_launcher',
        playSound: true,
        enableVibration: true,
        fullScreenIntent: true, // Make it more prominent
      );

       DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        sound: 'default',
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

       NotificationDetails platformDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      // Use customer ID * 100 + 1 for unique notification ID
      final notificationId = (customer.id! * 100) + 1;

      await _notificationsPlugin!.zonedSchedule(
        notificationId,
        '🧹 Service Alert - 1 Hour!'.tr,
        'Hi ${customer.customerName}! Your ${customer.service} service starts in 1 hour.\nLocation: ${customer.address}\nAmount: \$${customer.amountToBePaid.toStringAsFixed(2)}'.tr,
        reminderTime,
        platformDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    }
  }

  // Format time for display (e.g., "2:30 PM")
  String _formatTime(tz.TZDateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute;
    final period = hour >= 12 ? 'PM': 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    final displayMinute = minute.toString().padLeft(2, '0');
    return '$displayHour:$displayMinute $period';
  }

  // Cancel notifications for a specific customer
  Future<void> cancelCustomerNotifications(int customerId) async {
    // Cancel both 24-hour and 1-hour reminders
    await _notificationsPlugin!.cancel((customerId * 100) + 24); // 24-hour reminder
    await _notificationsPlugin!.cancel((customerId * 100) + 1);  // 1-hour reminder
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin!.cancelAll();
  }

  // Show immediate test notification
  Future<void> showTestNotification() async {
     AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'test'.tr,
      'Test Notifications'.tr,
      importance: Importance.high,
      priority: Priority.high,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

     NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin!.show(
      0,
      'Test Notification'.tr,
      'Your notifications are working!'.tr,
      platformDetails,
    );
  }

  // Show immediate test notification for a specific customer
  Future<void> showTestCustomerNotification(Customer customer) async {
     AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'test_customer'.tr,
      'Test Customer Notifications'.tr,
      channelDescription: 'Test notifications for specific customers'.tr,
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      sound: 'default',
    );

     NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Use a unique ID for test notifications (customer.id + 10000 to avoid conflicts)
    final testNotificationId = (customer.id ?? 0) + 10000;

    await _notificationsPlugin!.show(
      testNotificationId,
      '🧹 Service Reminder (Test)'.tr,
      'Hi ${customer.customerName}! Your ${customer.service} service is scheduled.\nLocation: ${customer.address}\nAmount: \$${customer.amountToBePaid.toStringAsFixed(2)}'.tr,
      platformDetails,
    );
  }

  // Schedule a custom reminder (for manual use if needed)
  Future<void> scheduleCustomReminder({
    required int customerId,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
     AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'custom_reminders'.tr,
      'Custom Service Reminders',
      channelDescription: 'Custom reminders for cleaning services'.tr,
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      sound: 'default',
    );

     NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final tz.TZDateTime tzScheduledTime = tz.TZDateTime.from(scheduledTime, tz.local);

    // Use customer ID * 100 + 99 for custom reminders
    final notificationId = (customerId * 100) + 99;

    await _notificationsPlugin!.zonedSchedule(
      notificationId,
      title,
      body,
      tzScheduledTime,
      platformDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  // Request exact alarm permission (for Android 12+)
  Future<bool> requestExactAlarmPermission() async {
    final androidImplementation = _notificationsPlugin!
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      return await androidImplementation.requestExactAlarmsPermission() ?? false;
    }
    return false;
  }

  // Check if exact alarm permission is granted
  Future<bool> isExactAlarmPermissionGranted() async {
    final androidImplementation = _notificationsPlugin!
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      return await androidImplementation.areNotificationsEnabled() ?? false;
    }
    return false;
  }

  // Get all pending notifications (for debugging)
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notificationsPlugin!.pendingNotificationRequests();
  }

  // Show immediate service reminder (for testing or manual trigger)
  Future<void> showImmediateServiceReminder(Customer customer) async {
     AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'immediate_service'.tr,
      'Immediate Service Reminders',
      channelDescription: 'Immediate reminders for cleaning services'.tr,
      importance: Importance.max,
      priority: Priority.max,
      playSound: true,
      enableVibration: true,
      fullScreenIntent: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      sound: 'default',
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

     NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin!.show(
      (customer.id ?? 0) + 50000, // Use high ID to avoid conflicts
      '🧹 Service Time!'.tr,
      'Hi ${customer.customerName}! Your ${customer.service} service is now.\nLocation: ${customer.address}'.tr,
      platformDetails,
    );
  }
}