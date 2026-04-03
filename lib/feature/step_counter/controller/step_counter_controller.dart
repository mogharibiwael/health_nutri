import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pedometer_plus/pedometer_plus.dart';
import 'package:permission_handler/permission_handler.dart';

/// Step counter using phone sensors. Starts when user presses "Start Counting".
class StepCounterController extends GetxController {
  final RxInt steps = 0.obs;
  final RxBool isCounting = false.obs;
  final RxString errorMessage = ''.obs;

  StreamSubscription<int>? _stepSubscription;
  int _baselineSteps = 0;

  @override
  void onClose() {
    _stepSubscription?.cancel();
    super.onClose();
  }

  Future<void> startCounting() async {
    errorMessage.value = '';

    if (GetPlatform.isAndroid) {
      final status = await Permission.activityRecognition.request();
      if (!status.isGranted) {
        errorMessage.value = 'stepCounterPermissionDenied'.tr;
        Get.snackbar(
          "stepCounter".tr,
          errorMessage.value,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange.shade100,
        );
        return;
      }
    }

    if (GetPlatform.isIOS) {
      final status = await Permission.sensors.request();
      if (!status.isGranted) {
        errorMessage.value = 'stepCounterPermissionDenied'.tr;
        Get.snackbar(
          "stepCounter".tr,
          errorMessage.value,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange.shade100,
        );
        return;
      }
    }

    try {
      _stepSubscription?.cancel();
      steps.value = 0;
      _baselineSteps = 0;
      isCounting.value = true;

      _stepSubscription = Pedometer().stepCountStream().listen(
        _onStepCount,
        onError: _onStepError,
      );
    } catch (e) {
      errorMessage.value = e.toString();
      isCounting.value = false;
      Get.snackbar(
        "stepCounter".tr,
        "comingSoon".tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void _onStepCount(int eventSteps) {
    if (_baselineSteps == 0) {
      _baselineSteps = eventSteps;
    }
    steps.value = (eventSteps - _baselineSteps).clamp(0, 999999999);
  }

  void _onStepError(dynamic error) {
    debugPrint("Step counter error: $error");
    errorMessage.value = error.toString();
    isCounting.value = false;
  }

  void stopCounting() {
    _stepSubscription?.cancel();
    _stepSubscription = null;
    isCounting.value = false;
  }

  String get stepLabel => steps.value == 1 ? "step".tr : "steps".tr;
}
