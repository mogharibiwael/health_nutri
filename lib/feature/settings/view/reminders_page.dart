import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constant/theme/colors.dart';
import '../../../core/shared/widgets/app_bar.dart';
import '../controller/reminders_controller.dart';

const Color _textPurple = AppColor.deepPurple;
const Color _textPurpleLight = AppColor.mutedPurple;

class RemindersPage extends GetView<RemindersController> {
  const RemindersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isAr = Get.locale?.languageCode == 'ar';

    return SafeArea(
      child: Scaffold(
        appBar: CustomAppBar(
          title: "remindersAlerts".tr,
          showBackButton: true,
          showLogo: true,
        ),
        backgroundColor: Colors.white,
        body: Column(
          children: [
            Expanded(
              child: Obx(() {
                if (controller.reminders.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        "noReminders".tr,
                        style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  itemCount: controller.reminders.length,
                  itemBuilder: (context, i) {
                    final r = controller.reminders[i];
                    return Padding(
                      padding: EdgeInsets.only(bottom: i < controller.reminders.length - 1 ? 14 : 0),
                      child: _ReminderCard(
                        reminder: r,
                        onEdit: () => controller.showEditDialog(r),
                        onDelete: () => controller.deleteReminder(r.id),
                        isAr: isAr,
                      ),
                    );
                  },
                );
              }),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: controller.showAddDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: Text("addReminder".tr, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReminderCard extends StatelessWidget {
  final ReminderModel reminder;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool isAr;

  const _ReminderCard({
    required this.reminder,
    required this.onEdit,
    required this.onDelete,
    required this.isAr,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColor.shadowColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (!isAr) ...[
            IconButton(icon: const Icon(Icons.delete_outline, color: const Color(0x8A2A0126)), onPressed: onDelete),
            IconButton(icon: const Icon(Icons.edit_outlined, color: const Color(0x8A2A0126)), onPressed: onEdit),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: isAr ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Text(
                  reminder.title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: _textPurple),
                  textAlign: isAr ? TextAlign.right : TextAlign.left,
                ),
                const SizedBox(height: 4),
                Text(
                  reminder.timeFormatted,
                  style: const TextStyle(fontSize: 14, color: _textPurpleLight),
                  textAlign: isAr ? TextAlign.right : TextAlign.left,
                ),
              ],
            ),
          ),
          if (isAr) ...[
            const SizedBox(width: 8),
            IconButton(icon: const Icon(Icons.edit_outlined, color: const Color(0x8A2A0126)), onPressed: onEdit),
            IconButton(icon: const Icon(Icons.delete_outline, color: const Color(0x8A2A0126)), onPressed: onDelete),
          ],
        ],
      ),
    );
  }
}
