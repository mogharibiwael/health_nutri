import 'package:get/get.dart';

class SettingsController extends GetxController {
  void goPersonalAccount() => Get.toNamed("/edit-profile");
  void goRemindersAlerts() => Get.toNamed("/reminders");
  void goTeam() => Get.toNamed("/team");
}
