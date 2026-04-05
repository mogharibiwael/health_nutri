import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constant/theme/colors.dart';
import '../../../core/service/notification_service.dart';

class ReminderModel {
  final String id;
  final String title;
  final TimeOfDay time;

  ReminderModel({required this.id, required this.title, required this.time});

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "hour": time.hour,
        "minute": time.minute,
      };

  factory ReminderModel.fromJson(Map<String, dynamic> json) {
    return ReminderModel(
      id: json["id"]?.toString() ?? "",
      title: json["title"]?.toString() ?? "",
      time: TimeOfDay(
        hour: int.tryParse(json["hour"]?.toString() ?? "0") ?? 0,
        minute: int.tryParse(json["minute"]?.toString() ?? "0") ?? 0,
      ),
    );
  }

  String get timeFormatted {
    final h = time.hour;
    final period = h >= 12 ? "PM" : "AM";
    final displayHour = h == 0 ? 12 : (h > 12 ? h - 12 : h);
    final m = time.minute.toString().padLeft(2, '0');
    return "$period $displayHour:$m";
  }
}

class RemindersController extends GetxController {
  static const String _storageKey = "user_reminders";

  final RxList<ReminderModel> reminders = <ReminderModel>[].obs;

  /// Web timers for scheduled reminders
  final Map<String, Timer> _webTimers = {};

  @override
  void onInit() {
    super.onInit();
    _loadReminders();
  }

  @override
  void onClose() {
    // Cancel all web timers
    for (final t in _webTimers.values) {
      t.cancel();
    }
    _webTimers.clear();
    super.onClose();
  }

  Future<void> _loadReminders() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_storageKey);
    if (json == null) return;
    try {
      final list = jsonDecode(json) as List;
      reminders.assignAll(
        list.map((e) => ReminderModel.fromJson(Map<String, dynamic>.from(e as Map))).toList(),
      );
      _rescheduleAllNotifications();
    } catch (_) {}
  }

  Future<void> _rescheduleAllNotifications() async {
    for (final r in reminders) {
      await _scheduleNotification(r.id, r.title, r.time);
    }
  }

  Future<void> _saveReminders() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _storageKey,
      jsonEncode(reminders.map((e) => e.toJson()).toList()),
    );
  }

  Future<void> addReminder(String title, TimeOfDay time) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    reminders.add(ReminderModel(id: id, title: title, time: time));
    await _saveReminders();
    await _scheduleNotification(id, title, time);
    await _showConfirmationNotification(id, title, time);
  }

  Future<void> updateReminder(String id, String title, TimeOfDay time) async {
    final i = reminders.indexWhere((r) => r.id == id);
    if (i >= 0) {
      reminders[i] = ReminderModel(id: id, title: title, time: time);
      await _saveReminders();
      await _cancelNotification(id);
      await _scheduleNotification(id, title, time);
      await _showConfirmationNotification(id, title, time);
    }
  }

  Future<void> deleteReminder(String id) async {
    reminders.removeWhere((r) => r.id == id);
    await _saveReminders();
    await _cancelNotification(id);
  }

  Future<void> _scheduleNotification(String id, String title, TimeOfDay time) async {
    try {
      if (kIsWeb) {
        // Web: use Timer to show snackbar at the scheduled time
        _webTimers[id]?.cancel();
        final now = DateTime.now();
        var scheduledDate = DateTime(now.year, now.month, now.day, time.hour, time.minute);
        if (scheduledDate.isBefore(now)) {
          scheduledDate = scheduledDate.add(const Duration(days: 1));
        }
        final duration = scheduledDate.difference(now);
        _webTimers[id] = Timer(duration, () {
          Get.snackbar(
            "⏰ Nutri Guide",
            title,
            snackPosition: SnackPosition.TOP,
            backgroundColor: AppColor.primary.withOpacity(0.95),
            colorText: Colors.white,
            duration: const Duration(seconds: 10),
            margin: const EdgeInsets.all(16),
            borderRadius: 12,
            icon: const Icon(Icons.alarm, color: Colors.white, size: 28),
          );
          // Reschedule for next day
          _scheduleNotification(id, title, time);
        });
      } else {
        final notifId = NotificationService.idToInt(id);
        await NotificationService().scheduleReminder(
          id: notifId,
          title: "Nutri Guide",
          body: title,
          hour: time.hour,
          minute: time.minute,
        );
      }
    } catch (e) {
      debugPrint("RemindersController: schedule error for $id: $e");
    }
  }

  Future<void> _checkExactAlarmPermission() async {
    if (kIsWeb) return;
    try {
      final can = await NotificationService().canScheduleExactNotifications();
      if (!can) {
        Get.snackbar(
          "permissionRequired".tr,
          "exactAlarmPermissionDescription".tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange.shade100,
          mainButton: TextButton(
            onPressed: () async {
              await NotificationService().requestPermission();
            },
            child: Text("settings".tr),
          ),
        );
      }
    } catch (_) {}
  }

  Future<void> _cancelNotification(String id) async {
    try {
      if (kIsWeb) {
        _webTimers[id]?.cancel();
        _webTimers.remove(id);
      } else {
        await NotificationService().cancelReminder(NotificationService.idToInt(id));
      }
    } catch (e) {
      debugPrint("Reminder notification cancel error: $e");
    }
  }

  Future<void> _showConfirmationNotification(String id, String title, TimeOfDay time) async {
    try {
      final h = time.hour;
      final ph = h == 0 ? 12 : (h > 12 ? h - 12 : h);
      final m = time.minute.toString().padLeft(2, '0');
      final timeStr = "${h >= 12 ? "PM" : "AM"} $ph:$m";

      if (kIsWeb) {
        Get.snackbar(
          "✅ Nutri Guide",
          "Reminder set: $title at $timeStr",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.white.withOpacity(0.95),
          colorText: AppColor.deepPurple,
          duration: const Duration(seconds: 3),
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
          icon: const Icon(Icons.check_circle, color: AppColor.deepPurple),
        );
      } else {
        await NotificationService().showNow(
          id: NotificationService.idToInt(id) + 1000000,
          title: "Nutri Guide",
          body: "Reminder set: $title at $timeStr",
        );
      }
    } catch (e) {
      debugPrint("Confirmation notification error: $e");
    }
  }

  void showAddDialog() => _showReminderDialog();
  void showEditDialog(ReminderModel r) => _showReminderDialog(reminder: r);

  void _showReminderDialog({ReminderModel? reminder}) {
    final titleController = TextEditingController(text: reminder?.title ?? "");
    var selectedTime = reminder?.time ?? TimeOfDay.now();

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          reminder == null ? "addReminder".tr : "edit".tr,
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColor.deepPurple),
        ),
        content: StatefulBuilder(
          builder: (context, setState) {
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: "Reminder",
                      hintText: "e.g. Drink water",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    title: Text("reminderTime".tr),
                    subtitle: Text(
                      () {
                        final h = selectedTime.hour;
                        final ph = h == 0 ? 12 : (h > 12 ? h - 12 : h);
                        final m = selectedTime.minute.toString().padLeft(2, '0');
                        return "${h >= 12 ? "PM" : "AM"} $ph:$m";
                      }(),
                    ),
                    trailing: const Icon(Icons.access_time),
                    onTap: () async {
                      final t = await showTimePicker(
                        context: context,
                        initialTime: selectedTime,
                      );
                      if (t != null) {
                        setState(() => selectedTime = t);
                      }
                    },
                  ),
                  const SizedBox(height: 24),
                  // ─── Save Button (inside content for visibility) ───
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final title = titleController.text.trim();
                        if (title.isEmpty) return;
                        if (!kIsWeb) {
                          await NotificationService().requestPermission();
                          await _checkExactAlarmPermission();
                        }
                        if (reminder != null) {
                          await updateReminder(reminder.id, title, selectedTime);
                        } else {
                          await addReminder(title, selectedTime);
                        }
                        Get.back();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        "save".tr,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // ─── Close Button ───
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () => Get.back(),
                      child: Text(
                        "close".tr,
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

