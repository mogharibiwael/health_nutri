import 'package:flutter/foundation.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:nutri_guide/core/constant/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void showAwesomeDialog({
  required DialogType type,
  required String title,
  required String desc,
  VoidCallback? onOk,
  bool dismissOnTouchOutside = true,
}) {
  final context = Get.context;
  if (context == null) return;

  if (kIsWeb) {
    Get.defaultDialog(
      title: title,
      middleText: desc,
      backgroundColor: Colors.white,
      titleStyle: TextStyle(color: AppColor.textColor, fontWeight: FontWeight.bold),
      middleTextStyle: TextStyle(color: AppColor.textColor.withOpacity(0.85)),
      radius: 16,
      textConfirm: "OK",
      confirmTextColor: Colors.white,
      buttonColor: AppColor.primary,
      onConfirm: () {
        Get.back();
        if (onOk != null) onOk();
      },
    );
    return;
  }

  AwesomeDialog(
    context: context,
    dialogType: type,
    animType: AnimType.scale,
    title: title,
    desc: desc,
    dismissOnTouchOutside: dismissOnTouchOutside,
    btnOkOnPress: onOk ?? () {},
  ).show();
}
