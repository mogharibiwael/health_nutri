import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/class/status_request.dart';
import '../../../core/function/handel_data.dart';
import '../../../core/function/show_dialog.dart';
import '../data/forget_password_data.dart';

class ForgotPasswordController extends GetxController {
  late TextEditingController emailController;

  final ForgotPasswordData data = ForgotPasswordData(Get.find());

  StatusRequest statusRequest = StatusRequest.success;

  Future<void> send() async {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      showAwesomeDialog(
        type: DialogType.warning,
        title: "Validation",
        desc: "Please enter your email",
      );
      return;
    }

    statusRequest = StatusRequest.loading;
    update();

    final res = await data.sendResetLink(email);

    // If your Crud returns StatusRequest directly on failures
    if (res is StatusRequest) {
      statusRequest = res;
      final msg = res == StatusRequest.offlineFailure
          ? "No internet connection"
          : "Server error, try again later";
      showAwesomeDialog(
        type: DialogType.error,
        title: "Failed",
        desc: msg,
      );
      update();
      return;
    }

    statusRequest = handelData(res);
    update();

    if (statusRequest != StatusRequest.success) {
      showAwesomeDialog(
        type: DialogType.error,
        title: "Failed",
        desc: "Try again",
      );
      return;
    }

    // Backend returns: { "message": "Password reset link sent" }
    final message = (res is Map && res["message"] != null)
        ? res["message"].toString()
        : "Password reset link sent";

    showAwesomeDialog(
      type: DialogType.success,
      title: "Success",
      desc: message,
      dismissOnTouchOutside: false,
      onOk: () => Get.back(), // go back to login
    );
  }

  @override
  void onInit() {
    emailController = TextEditingController();
    super.onInit();
  }

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }
}
