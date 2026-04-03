import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/function/show_dialog.dart';
import '../../../core/service/serviecs.dart';

class EditProfileController extends GetxController {
  final MyServices myServices = Get.find();

  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController passwordController;
  late TextEditingController confirmPasswordController;

  bool isPasswordHidden = true;
  bool isConfirmPasswordHidden = true;

  @override
  void onInit() {
    super.onInit();
    final u = myServices.user;
    nameController = TextEditingController(text: u?["name"]?.toString() ?? "");
    emailController = TextEditingController(text: u?["email"]?.toString() ?? "");
    passwordController = TextEditingController();
    confirmPasswordController = TextEditingController();
  }

  void togglePassword() {
    isPasswordHidden = !isPasswordHidden;
    update();
  }

  void toggleConfirmPassword() {
    isConfirmPasswordHidden = !isConfirmPasswordHidden;
    update();
  }

  Future<void> save() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final pass = passwordController.text.trim();
    final confirm = confirmPasswordController.text.trim();

    if (name.isEmpty) {
      showAwesomeDialog(
        type: DialogType.warning,
        title: "Validation",
        desc: "enterName".tr,
      );
      return;
    }
    if (email.isEmpty) {
      showAwesomeDialog(
        type: DialogType.warning,
        title: "Validation",
        desc: "enterPersonalEmail".tr,
      );
      return;
    }
    if (pass.isNotEmpty && pass.length < 8) {
      showAwesomeDialog(
        type: DialogType.warning,
        title: "Validation",
        desc: "passwordHint".tr,
      );
      return;
    }
    if (pass != confirm) {
      showAwesomeDialog(
        type: DialogType.warning,
        title: "Validation",
        desc: "confirmPasswordHint".tr,
      );
      return;
    }

    // TODO: Call update profile API when available
    showAwesomeDialog(
      type: DialogType.success,
      title: "success".tr,
      desc: "Profile updated (API pending)",
      onOk: () => Get.back(),
    );
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
