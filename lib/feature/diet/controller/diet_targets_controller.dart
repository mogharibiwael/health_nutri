import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/service/diet_calculator_service.dart';
import '../../../core/routes/app_route.dart';
import '../../../../doctorApp/feature/home/model/patient_model.dart';
import '../model/exchange_model.dart';
import '../service/exchange_calculator.dart';

class DietTargetsController extends GetxController {
  int? patientId;
  String patientName = "";
  int? doctorId;
  PatientModel? patient;
  List<Map<String, dynamic>> periods = [];

  DietGoal goal = DietGoal.weightLoss;
  MilkType milkType = MilkType.lowFat;
  MeatType meatType = MeatType.lean;

  DietTargetsResult? targetsResult;
  DailyExchangePlan? exchangePlan;

  @override
  void onInit() {
    super.onInit();
    final args = (Get.arguments as Map?) ?? {};
    patientId = args["patient_id"] is int
        ? args["patient_id"] as int
        : int.tryParse("${args["patient_id"]}") ?? 0;
    patientName = (args["patient_name"] ?? "").toString();
    doctorId = args["doctor_id"] is int
        ? args["doctor_id"] as int
        : int.tryParse("${args["doctor_id"]}") ?? 0;
    if (args["patient"] is PatientModel) {
      patient = args["patient"] as PatientModel;
      if (patientName.isEmpty && patient!.fullname.isNotEmpty) patientName = patient!.fullname;
    }
    if (args["periods"] is List) {
      periods = (args["periods"] as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    }
    recalculate();
  }

  void setGoal(DietGoal g) {
    goal = g;
    recalculate();
    update();
  }

  void setMilkType(MilkType t) {
    milkType = t;
    recalculate();
    update();
  }

  void setMeatType(MeatType t) {
    meatType = t;
    recalculate();
    update();
  }

  void recalculate() {
    final p = patient;
    if (p == null) return;

    final weight = p.weight ?? 0;
    final height = p.height ?? 0;
    final age = DietCalculatorService.ageFromDob(p.birthdate) ?? 25;
    final isFemale = (p.gender ?? '').toLowerCase().contains('f') ||
        (p.gender ?? '').contains('انث') ||
        (p.gender ?? '').contains('female');

    if (weight <= 0 || height <= 0) {
      targetsResult = null;
      exchangePlan = null;
      return;
    }

    double cRatio = 0.50, pRatio = 0.25, fRatio = 0.25;
    
    // Derive ratios from existing macro settings if available
    final totalGramsCal = (p.carbohydrates ?? 0) * 4 + (p.protein ?? 0) * 4 + (p.fats ?? 0) * 9;
    if (totalGramsCal > 0 && p.carbohydrates != null) {
      cRatio = (p.carbohydrates! * 4) / totalGramsCal;
      pRatio = (p.protein! * 4) / totalGramsCal;
      fRatio = (p.fats! * 9) / totalGramsCal;
    }

    // NEW: If patient already has set macros, respect them!
    if (p.carbohydrates != null && p.protein != null && p.fats != null) {
      final cal = (p.carbohydrates! * 4) + (p.protein! * 4) + (p.fats! * 9);
      targetsResult = DietTargetsResult(
        bmr: 0, // Not critical here
        tdee: cal,
        targetCalories: cal,
        macros: MacroTargets(
          carbsG: p.carbohydrates!,
          proteinG: p.protein!,
          fatG: p.fats!,
          calories: cal,
        ),
      );
    } else {
      targetsResult = DietCalculatorService.calculate(
        weightKg: weight,
        heightCm: height,
        age: age,
        isFemale: isFemale,
        physicalActivity: p.physicalActivity,
        goal: goal,
        carbsRatio: cRatio,
        proteinRatio: pRatio,
        fatRatio: fRatio,
      );
    }

    if (targetsResult != null) {
      exchangePlan = ExchangeCalculator.fromMacros(
        targetCarbsG: targetsResult!.macros.carbsG,
        targetProteinG: targetsResult!.macros.proteinG,
        targetFatG: targetsResult!.macros.fatG,
        milkType: milkType,
        meatType: meatType,
      );
    }
    update();
  }

  void goToDistribution() {
    if (patientId == null || doctorId == null) {
      Get.snackbar("error".tr, "fillFields".tr);
      return;
    }
    if (targetsResult == null || exchangePlan == null) {
      Get.snackbar("error".tr, "fillPatientProfile".tr);
      return;
    }
    Get.toNamed(
      AppRoute.dietPortionCategories,
      arguments: {
        "patient_id": patientId,
        "patient_name": patientName,
        "doctor_id": doctorId,
        "patient": patient,
        "periods": periods,
        "targets": targetsResult!,
        "exchange_plan": exchangePlan!,
        "exchange_plan_json": exchangePlan!.toJson(),
      },
    );
  }


  bool get hasValidPatientData {
    final p = patient;
    if (p == null) return false;
    final w = p.weight ?? 0;
    final h = p.height ?? 0;
    return w > 0 && h > 0;
  }
}
