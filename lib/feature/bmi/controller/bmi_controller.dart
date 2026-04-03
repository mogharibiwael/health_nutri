// bmi_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dartz/dartz.dart';

import '../../../core/class/status_request.dart';
import '../../../core/service/serviecs.dart';
import '../../calculations/data/calculations_data.dart';
import '../../chat/data/patient_profile_data.dart';

class BmiController extends GetxController {
  final CalculationsData calculationsData = CalculationsData(Get.find());
  final MyServices myServices = Get.find();
  final PatientProfileData patientProfileData = PatientProfileData(Get.find());

  final TextEditingController heightController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController ageController = TextEditingController();

  String gender = "male";
  String activityLevel = "sedentary";

  double? bmi;
  double? bmr;
  double? physicalActivityEnergy; // الناتج بعد ضرب BMR في معامل النشاط
  double? tef;                   // التأثير الحراري للطعام (10%)
  double? totalKcal;             // المجموع النهائي (النشاط الداخلي)

  String bmiStatus = "";
  StatusRequest saveStatus = StatusRequest.success;
  StatusRequest calcStatus = StatusRequest.success;
  String goal = "maintain"; // maintain | lose | gain

  String _apiActivityLevel() {
    // UI values: sedentary, low, active, very, extra
    // API expects: sedentary, low, moderate, active, very_active
    switch (activityLevel) {
      case "sedentary":
        return "sedentary";
      case "low":
        return "low";
      case "active":
        return "moderate";
      case "very":
        return "active";
      case "extra":
        return "very_active";
      default:
        return "moderate";
    }
  }

  Future<void> calculate() async {
    final hStr = heightController.text.trim();
    final wStr = weightController.text.trim();
    final aStr = ageController.text.trim();

    if (hStr.isEmpty || wStr.isEmpty || aStr.isEmpty) {
      Get.snackbar(
        "permissionRequired".tr, // Or a better "warning" title
        "fillFields".tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.amber.shade100,
        colorText: Colors.amber.shade900,
      );
      return;
    }

    final double weight = double.tryParse(wStr) ?? 0;
    final double heightCm = double.tryParse(hStr) ?? 0;
    final int age = int.tryParse(aStr) ?? 0;
    if (weight <= 0 || heightCm <= 0 || age <= 0) {
      Get.snackbar(
        "error".tr,
        "fillFields".tr,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    calcStatus = StatusRequest.loading;
    update();

    final res = await calculationsData.nutrition(
      weight: weight,
      height: heightCm,
      age: age,
      gender: gender,
      activityLevel: _apiActivityLevel(),
      goal: goal,
      save: false,
      token: myServices.token,
    );

    res.fold((l) {
      calcStatus = l;
      update();
      Get.snackbar("error".tr, "serverError".tr);
    }, (r) {
      calcStatus = StatusRequest.success;
      // Accept both {data:{...}} and flat responses
      final data = (r["data"] is Map) ? Map<String, dynamic>.from(r["data"]) : r;
      double? toDouble(dynamic v) {
        if (v == null) return null;
        if (v is num) return v.toDouble();
        return double.tryParse(v.toString());
      }

      bmi = toDouble(data["bmi"]);
      bmr = toDouble(data["bmr"]);
      physicalActivityEnergy = toDouble(data["pae"] ?? data["physical_activity_energy"] ?? data["tdee"]);
      tef = toDouble(data["tef"]);
      totalKcal = toDouble(
          data["total_kcal"] ?? data["totalKcal"] ?? data["tdee"] ?? data["total_calories"]);
      bmiStatus = (data["bmi_status"] ?? data["bmiStatus"] ?? "").toString();

      // fallback if backend doesn't send bmi_status
      if (bmiStatus.isEmpty && bmi != null) {
        bmiStatus = _getBmiStatus(bmi!);
      }
      update();
    });
  }

  String _getBmiStatus(double v) {
    // تصنيفات الـ BMI المكتوبة في الجدول بالصورة
    if (v < 18.5) return "Underweight (نقص وزن)";
    if (v >= 18.5 && v <= 24.9) return "Normal (وزن مثالي)";
    if (v >= 25 && v <= 29.9) return "Overweight (زيادة وزن)";
    if (v >= 30 && v <= 34.9) return "Obesity I (سمنة درجة 1)";
    if (v >= 35 && v <= 39.9) return "Obesity II (سمنة درجة 2)";
    return "Obesity III (سمنة مفرطة)";
  }

  /// Save calculation via POST /api/calculations/nutrition with save:true.
  Future<void> saveCalculation() async {
    if (bmi == null || bmr == null) return;

    saveStatus = StatusRequest.loading;
    update();

    final weight = double.tryParse(weightController.text.trim()) ?? 0.0;
    final height = double.tryParse(heightController.text.trim()) ?? 0.0;
    final age = int.tryParse(ageController.text.trim()) ?? 0;

    final res = await calculationsData.nutrition(
      weight: weight,
      height: height,
      age: age,
      gender: gender,
      activityLevel: _apiActivityLevel(),
      goal: goal,
      save: true,
      token: myServices.token,
    );

    res.fold((l) {
      saveStatus = StatusRequest.failure;
      update();
      Get.snackbar("error".tr, "serverError".tr);
    }, (r) {
      saveStatus = StatusRequest.success;
      // Keep patient profile in sync with the latest body inputs so doctor app sees the latest info.
      _syncPatientProfileFromInputs();
      update();
      Get.snackbar("success".tr, r["message"]?.toString() ?? "saveCalculation".tr);
    });
  }

  Future<void> _syncPatientProfileFromInputs() async {
    final token = myServices.token;
    if (token == null || token.trim().isEmpty) return;

    final h = double.tryParse(heightController.text.trim());
    final w = double.tryParse(weightController.text.trim());
    final dob = ""; // unknown here (we only have age). We won't overwrite DOB.
    final activity = _apiActivityLevel();

    final body = <String, dynamic>{
      "gender": gender,
      if (h != null && h > 0) "height": h,
      if (w != null && w > 0) "current_weight": w,
      "physical_activity": activity,
      // Do NOT send date_of_birth here because we only have age.
    };

    try {
      final res = await patientProfileData.updateProfile(body, token: token);
      await res.fold((_) async {}, (response) async {
        final d = response["data"];
        final profile = d is Map ? Map<String, dynamic>.from(d) : null;
        if (profile == null) return;
        final u = myServices.user ?? <String, dynamic>{};
        final merged = <String, dynamic>{...u, "patient_profile": profile};
        await myServices.saveSession(
          token: token,
          type: myServices.type ?? "user",
          user: merged,
        );
      });
    } catch (_) {}
  }
}