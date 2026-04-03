import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/class/status_request.dart';
import '../../../core/function/show_dialog.dart';
import '../../../core/routes/app_route.dart';
import '../data/verify_email_data.dart';

class VerifyEmailController extends GetxController {
  late TextEditingController codeController;
  late TextEditingController emailController;

  final VerifyEmailData data = VerifyEmailData(Get.find());

  StatusRequest statusRequest = StatusRequest.success;

  bool get hasEmailArgument =>
      Get.arguments is Map && Get.arguments['email'] != null;

  String get email {
    if (hasEmailArgument) return Get.arguments['email'].toString();
    return emailController.text.trim();
  }

  /// Virtual/mock verification until real API is provided. Accepts any non-empty code.
  Future<void> verify() async {
    final code = codeController.text.trim();

    if (code.isEmpty) {
      showAwesomeDialog(
        type: DialogType.warning,
        title: "Validation",
        desc: "verifyCodeRequired".tr,
      );
      return;
    }

    if (email.isEmpty) {
      showAwesomeDialog(
        type: DialogType.warning,
        title: "Validation",
        desc: "Email is required",
      );
      return;
    }

    statusRequest = StatusRequest.loading;
    update();

    // TODO: Replace with real API when available. For now, virtual/mock success.
    await Future.delayed(const Duration(milliseconds: 500));

    statusRequest = StatusRequest.success;
    update();
    showAwesomeDialog(
      type: DialogType.success,
      title: "success".tr,
      desc: "emailVerified".tr,
      dismissOnTouchOutside: false,
      onOk: () => Get.offAllNamed(AppRoute.login),
    );
  }

  void goBack() => Get.back();

  bool _codeSent = false;

  /// Virtual/mock - no API call until real API is provided.
  Future<void> sendCodeToEmail() async {
    if (email.isEmpty) return;
    if (_codeSent) return;
    _codeSent = true;
    // TODO: Call real API when available. For now, simulate code sent.
    update();
  }

  /// Virtual/mock - no API call until real API is provided.
  Future<void> resendCode() async {
    if (email.isEmpty) return;
    statusRequest = StatusRequest.loading;
    update();
    // TODO: Call real API when available. For now, simulate success.
    await Future.delayed(const Duration(milliseconds: 400));
    statusRequest = StatusRequest.success;
    _codeSent = true;
    update();
    showAwesomeDialog(
      type: DialogType.success,
      title: "success".tr,
      desc: "verificationCodeResent".tr,
    );
  }

  @override
  void onInit() {
    codeController = TextEditingController();
    emailController = TextEditingController(
      text: Get.arguments is Map ? (Get.arguments['email']?.toString() ?? '') : '',
    );
    super.onInit();
    // Send code when we have email (e.g. after signup)
    if (hasEmailArgument && email.isNotEmpty) {
      sendCodeToEmail();
    }
  }

  @override
  void onClose() {
    codeController.dispose();
    emailController.dispose();
    super.onClose();
  }
}
