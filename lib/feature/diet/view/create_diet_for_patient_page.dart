import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/shared/widgets/drawer.dart';
import '../../../core/class/status_request.dart';
import '../../../core/constant/theme/colors.dart';
import '../../../core/routes/app_route.dart';
import '../../../core/service/diet_calculator_service.dart';
import '../../../core/shared/widgets/app_bar.dart';
import '../../../doctorApp/feature/home/model/patient_model.dart';
import '../controller/diet_controller.dart';
import '../model/exchange_model.dart';
import '../service/diet_payload_builder.dart';

/// Doctor-only: create diet plan for a specific patient.
/// When opened from wizard (distribution, targets, exchange_plan in args),
/// auto-fills and builds meals from exchange distribution.
class CreateDietForPatientPage extends GetView<DietController> {
  const CreateDietForPatientPage({super.key});

  /// If your backend expects patient's user_id (users.id) instead of patient.id (patients table),
  /// set this to true and ensure GET /api/doctor/patients returns user_id.
  static const bool _useUserIdForPatientId = false;

  @override
  Widget build(BuildContext context) {
    final args = (Get.arguments as Map?) ?? {};
    final patient = args["patient"];
    int patientId = (args["patient_id"] is int)
        ? args["patient_id"] as int
        : int.tryParse("${args["patient_id"]}") ?? 0;
    // Use patient from PatientDetailsController - effectivePatientId prefers patient_id from API
    if (patient is PatientModel) {
      patientId = patient.effectivePatientId;
      if (_useUserIdForPatientId && patient.userId > 0) {
        patientId = patient.userId;
      }
      debugPrint("[CreateDiet] patient.id=${patient.id} effectivePatientId=${patient.effectivePatientId} -> sending patient_id=$patientId");
    }
    final patientName = (args["patient_name"] ?? "").toString();
    final doctorId = (args["doctor_id"] is int)
        ? args["doctor_id"] as int
        : int.tryParse("${args["doctor_id"]}") ?? 0;
    final periodsRaw = args["periods"];
    final periods = periodsRaw is List
        ? (periodsRaw).map((e) => Map<String, dynamic>.from(e as Map)).toList()
        : <Map<String, dynamic>>[];
    final distributionRaw = args["distribution"];
    Map<String, Map<String, double>> distribution = {};
    if (distributionRaw is Map) {
      for (final e in (distributionRaw as Map).entries) {
        final k = e.key.toString();
        final v = e.value;
        if (v is Map) {
          final inner = <String, double>{};
          for (final ie in (v as Map).entries) {
            inner[ie.key.toString()] = (ie.value is num) ? (ie.value as num).toDouble() : 0.0;
          }
          distribution[k] = inner;
        }
      }
    }
    final targets = args["targets"] as DietTargetsResult?;
    DailyExchangePlan? exchangePlan;
    if (args["exchange_plan"] is DailyExchangePlan) {
      exchangePlan = args["exchange_plan"] as DailyExchangePlan;
    } else if (args["exchange_plan_json"] is Map) {
      exchangePlan = DailyExchangePlan.fromJson(
        Map<String, dynamic>.from(args["exchange_plan_json"] as Map),
      );
    }
    Map<String, List<String>> mealItems = {};
    if (args["meal_items"] is Map) {
      for (final e in (args["meal_items"] as Map).entries) {
        final k = e.key.toString();
        final v = e.value;
        if (v is List) {
          mealItems[k] = v.map((x) => x.toString()).toList();
        }
      }
    }
    List<String> doctorNotes = [];
    if (args["doctor_notes"] is List) {
      doctorNotes = (args["doctor_notes"] as List)
          .map((x) => x.toString())
          .where((x) => x.isNotEmpty)
          .toList();
    }

    final fromWizard = distribution.isNotEmpty &&
        periods.isNotEmpty &&
        targets != null &&
        exchangePlan != null;

    return GetBuilder<DietController>(
      builder: (c) {
        if (patientId > 0) {
          c.patientIdController.text = patientId.toString();
        }
        if (patientName.isNotEmpty && c.titleController.text.isEmpty) {
          c.titleController.text = "dietPlanFor".trParams({"name": patientName});
        }
        if (fromWizard) {
          if (c.dailyCaloriesController.text.isEmpty) {
            c.dailyCaloriesController.text =
                targets.targetCalories.round().toString();
          }
          if (c.durationDaysController.text.isEmpty) {
            c.durationDaysController.text = "30";
          }
          if (c.startDateController.text.isEmpty) {
            final start = DateTime.now();
            c.startDateController.text =
                "${start.year}-${start.month.toString().padLeft(2, '0')}-${start.day.toString().padLeft(2, '0')}";
          }
          if (c.endDateController.text.isEmpty) {
            final days = int.tryParse(c.durationDaysController.text) ?? 30;
            final end = DateTime.now().add(Duration(days: days));
            c.endDateController.text =
                "${end.year}-${end.month.toString().padLeft(2, '0')}-${end.day.toString().padLeft(2, '0')}";
          }
        }

        final isAr = Get.locale?.languageCode == 'ar';
        final textDir = isAr ? TextDirection.rtl : TextDirection.ltr;
        return Directionality(
          textDirection: textDir,
          child: SafeArea(
            child: Scaffold(
              drawer: HomeDrawer(controller: c),
              backgroundColor: Colors.grey.shade100,
              appBar: CustomAppBar(
                title: "createDietPlan".tr,
                subtitle: patientName.isNotEmpty ? patientName : null,
                showBackButton: true,
                showLogo: true,
                leading: Builder(
                  builder: (ctx) => IconButton(
                    icon: Icon(Icons.menu, color: AppColor.primary, size: 26),
                    onPressed: () => Scaffold.of(ctx).openDrawer(),
                  ),
                ),
              ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (periods.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _SectionCard(
                        title: "savedMealTimes".tr,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: periods.map((p) {
                            final customName = p["custom_name"]?.toString();
                            final type = customName != null &&
                                    customName.isNotEmpty
                                ? customName
                                : (p["meal_type"]?.toString() ?? "");
                            final h = p["hour"] ?? 0;
                            final m = p["minute"] ?? 0;
                            final timeStr =
                                "${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}";
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    type,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey.shade800,
                                    ),
                                  ),
                                  Text(
                                    timeStr,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppColor.primary,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  if (fromWizard && targets != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _SectionCard(
                        title: "targetCalories".tr,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${targets.targetCalories.round()} kcal",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: AppColor.primary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                _MacroChip(
                                  label: "carbohydrates".tr,
                                  value: "${targets.macros.carbsG.toStringAsFixed(1)}g",
                                ),
                                const SizedBox(width: 8),
                                _MacroChip(
                                  label: "protein".tr,
                                  value: "${targets.macros.proteinG.toStringAsFixed(1)}g",
                                ),
                                const SizedBox(width: 8),
                                _MacroChip(
                                  label: "fats".tr,
                                  value: "${targets.macros.fatG.toStringAsFixed(1)}g",
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  _SectionCard(
                    title: "patientName".tr,
                    child: Text(
                      patientName.isNotEmpty ? patientName : "-",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: c.titleController,
                    decoration: InputDecoration(
                      labelText: "dietPlanTitle".tr,
                      hintText: "dietPlanTitleHint".tr,
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: c.dailyCaloriesController,
                    decoration: InputDecoration(
                      labelText: "dailyCalories".tr,
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: c.durationDaysController,
                    decoration: InputDecoration(
                      labelText: "durationDays".tr,
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: c.startDateController,
                    decoration: InputDecoration(
                      labelText: "startDate".tr,
                      hintText: "startDateHint".tr,
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: c.endDateController,
                    decoration: InputDecoration(
                      labelText: "endDate".tr,
                      hintText: "endDateHint".tr,
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: c.createStatus == StatusRequest.loading
                          ? null
                          : () => _onCreate(
                                c,
                                patientId,
                                doctorId,
                                periods,
                                distribution,
                                exchangePlan,
                                mealItems,
                                doctorNotes,
                              ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: c.createStatus == StatusRequest.loading
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text("create".tr),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        );
      },
    );
  }

  void _onCreate(
    DietController c,
    int patientId,
    int doctorId,
    List<Map<String, dynamic>> periods,
    Map<String, Map<String, double>> distribution,
    DailyExchangePlan? exchangePlan,
    Map<String, List<String>> mealItems,
    List<String> doctorNotes,
  ) {
    final dailyCalories = int.tryParse(c.dailyCaloriesController.text);
    final durationDays = int.tryParse(c.durationDaysController.text);
    if (patientId <= 0 ||
        doctorId == 0 ||
        c.titleController.text.isEmpty ||
        dailyCalories == null ||
        durationDays == null ||
        c.startDateController.text.isEmpty ||
        c.endDateController.text.isEmpty) {
      Get.snackbar("error".tr, "fillFields".tr);
      return;
    }

    List<Map<String, dynamic>>? meals;
    List<Map<String, dynamic>>? mealPeriods;

    if (distribution.isNotEmpty &&
        periods.isNotEmpty &&
        exchangePlan != null) {
      meals = DietPayloadBuilder.buildMeals(
        distribution: distribution,
        periods: periods,
        exchangePlan: exchangePlan,
        mealItems: mealItems.isNotEmpty ? mealItems : null,
      );
      mealPeriods = DietPayloadBuilder.buildMealPeriods(periods);
    }

    c.createDietPlan(
      patientId: patientId,
      doctorId: doctorId,
      title: c.titleController.text,
      dailyCalories: dailyCalories,
      durationDays: durationDays,
      startDate: c.startDateController.text,
      endDate: c.endDateController.text,
      meals: meals,
      mealPeriods: mealPeriods,
      doctorNotes: doctorNotes.isNotEmpty ? doctorNotes : null,
      onSuccess: () {
        Get.until((route) => route.settings.name == AppRoute.patientDetails);
      },
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColor.shadowColor.withOpacity(0.12),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

class _MacroChip extends StatelessWidget {
  final String label;
  final String value;

  const _MacroChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColor.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColor.primary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade700,
            ),
          ),
          Text(
            value,
            style:  TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColor.primary,
            ),
          ),
        ],
      ),
    );
  }
}
