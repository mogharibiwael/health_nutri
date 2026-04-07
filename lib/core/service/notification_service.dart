import 'dart:convert';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'web_audio_stub.dart' if (dart.library.html) 'web_audio_web.dart';
import 'package:flutter/material.dart';

/// Service for scheduling reminder notifications.
class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;

  NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  /// Use v5 to force channel recreation with sound (Android channel settings are immutable)
  static const String _channelId = 'reminders_channel_v5';
  static const String _channelName = 'Reminders';

  /// Custom sound for notifications (Android: res/raw/notification_sound.wav)
  static const RawResourceAndroidNotificationSound _sound = RawResourceAndroidNotificationSound('notification_sound');

  Future<void> initialize() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();
    await requestPermission();
    try {
      final String tzName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(tzName));
    } catch (e) {
      debugPrint("NotificationService: Timezone detection failed ($e), falling back to Asia/Riyadh or UTC");
      try {
        tz.setLocalLocation(tz.getLocation('Asia/Riyadh'));
      } catch (_) {
        tz.setLocalLocation(tz.getLocation('UTC'));
      }
    }

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
    );
    const initSettings = InitializationSettings(android: android, iOS: ios);

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    const androidChannel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: 'Reminder notifications',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
      sound: _sound,
      audioAttributesUsage: AudioAttributesUsage.alarm,
    );
    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);

    _initialized = true;
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Optional: handle tap (e.g. navigate to reminders page)
  }

  /// Request notification permission (Android 13+, iOS)
  Future<bool> requestPermission() async {
    final android = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      final bool? granted = await android.requestNotificationsPermission();
      // On Android 13+, also check for exact alarm permission if needed
      await android.requestExactAlarmsPermission(); 
      return granted ?? false;
    }
    final ios = _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    if (ios != null) {
      return await ios.requestPermissions(alert: true, badge: true, sound: true) ?? false;
    }
    return true;
  }

  /// Check if the app can schedule exact notifications (Android 12+)
  Future<bool> canScheduleExactNotifications() async {
    final android = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (android == null) return true;
    return await android.canScheduleExactNotifications() ?? false;
  }

  /// Schedule a daily reminder notification.
  /// [id] must be unique (use reminder id hash or numeric).
  /// [title] is the notification title.
  /// [body] is the notification body.
  /// [hour] and [minute] are in 24h format.
  Future<void> scheduleReminder({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    if (!_initialized) await initialize();

    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: 'Reminder notifications',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      sound: _sound,
      enableVibration: true,
      audioAttributesUsage: AudioAttributesUsage.alarm,
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'notification_sound.wav',
    );
    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// Cancel a scheduled reminder.
  Future<void> cancelReminder(int id) async {
    await _plugin.cancel(id);
  }

  /// Cancel all reminders.
  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  /// Show an immediate notification (e.g. confirmation when reminder is set).
  Future<void> showNow({required int id, required String title, required String body}) async {
    if (!_initialized) await initialize();
    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: 'Reminder notifications',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      sound: _sound,
      enableVibration: true,
      audioAttributesUsage: AudioAttributesUsage.alarm,
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'notification_sound.wav',
    );
    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);
    
    if (kIsWeb) {
      Get.snackbar(
        title,
        body,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.white.withOpacity(0.9),
        colorText: const Color(0xFF67025F), // deepPurple
        duration: const Duration(seconds: 4),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        icon: const Icon(Icons.chat_bubble_outline, color: Color(0xFF67025F)),
        boxShadows: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      );
      
      // Web Sound Playback via conditional import
      playWebNotificationSound('assets/assets/sounds/notification_sound.wav');
    } else {
      await _plugin.show(id, title, body, details);
    }
  }

  /// Reschedule all stored reminders (call on app start and after boot).
  static const String _storageKey = "user_reminders";

  Future<void> rescheduleStoredReminders() async {
    if (!_initialized) await initialize();
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString(_storageKey);
      if (json == null) return;
      final list = jsonDecode(json) as List;
      for (final e in list) {
        final m = Map<String, dynamic>.from(e as Map);
        final id = m["id"]?.toString() ?? "";
        final title = m["title"]?.toString() ?? "";
        final hour = int.tryParse(m["hour"]?.toString() ?? "0") ?? 0;
        final minute = int.tryParse(m["minute"]?.toString() ?? "0") ?? 0;
        if (id.isEmpty) continue;
        await scheduleReminder(id: NotificationService.idToInt(id), title: "Nutri Guide", body: title, hour: hour, minute: minute);
      }
    } catch (_) {}
  }

  /// Convert reminder id string to a stable int for notification id.
  static int idToInt(String id) {
    return id.hashCode.abs() % 2147483647;
  }
}
