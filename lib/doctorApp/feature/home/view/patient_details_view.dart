import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/shared/widgets/drawer.dart';
import 'package:nutri_guide/core/class/status_request.dart';
import 'package:nutri_guide/core/constant/theme/colors.dart';
import 'package:nutri_guide/core/routes/app_route.dart';
import 'package:nutri_guide/core/shared/widgets/app_bar.dart';
import '../controller/patient_details_controller.dart';

/// Primary color for collapsible card buttons

class PatientDetailsPage extends GetView<PatientDetailsController> {
  const PatientDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PatientDetailsController>(
      builder: (c) => SafeArea(
          child: Scaffold(
            drawer: HomeDrawer(controller: c),
            backgroundColor: Colors.grey.shade100,
            appBar: CustomAppBar(
              title: c.patient.fullname.trim().isNotEmpty && c.patient.fullname != "-"
                  ? c.patient.fullname
                  : "patientInformation".tr,
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
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _CollapsibleSection(
                  label: "patientInformation".tr,
                  isExpanded: c.isSectionExpanded(1),
                  onTap: () => c.toggleSection(1),
                  child: _PatientInfoSection(controller: c),
                ),
                const SizedBox(height: 14),
                _CollapsibleSection(
                  label: "nutritionalCalculations".tr,
                  isExpanded: c.isSectionExpanded(2),
                  onTap: () => c.toggleSection(2),
                  child: _NutritionalCalcSection(controller: c),
                ),
                const SizedBox(height: 14),
                _CollapsibleSection(
                  label: "proteinFatCarbs".tr,
                  isExpanded: c.isSectionExpanded(3),
                  onTap: () => c.toggleSection(3),
                  child: _MacrosSection(controller: c),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CollapsibleSection extends StatelessWidget {
  final String label;
  final bool isExpanded;
  final VoidCallback onTap;
  final Widget child;

  const _CollapsibleSection({
    required this.label,
    required this.isExpanded,
    required this.onTap,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Material(
          color: AppColor.primary,
          borderRadius: BorderRadius.circular(16),
          elevation: 2,
          shadowColor: const Color(0x422A0126),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  Icon(
                    isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: Colors.white,
                    size: 28,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (isExpanded) ...[
          const SizedBox(height: 12),
          child,
        ],
      ],
    );
  }
}

class _PatientInfoSection extends StatelessWidget {
  final PatientDetailsController controller;

  const _PatientInfoSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    final c = controller;
    final genderTr = _genderLabel(c.patient.gender);
    print("genderTr---------------");
    print(genderTr);
    print("genderTr---------------");
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColor.shadowColor.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InfoRowWithIcon(
            label: "patientName".tr,
            value: c.patient.fullname,
            icon: Icons.person_outline,
          ),
          _InfoRowWithIcon(
            label: "patientAge".tr,
            value: c.patientAge != null ? c.patientAge.toString() : "-",
            icon: Icons.calendar_today_outlined,
          ),
          _InfoRowWithIcon(
            label: "patientGender".tr,
            value: genderTr,
            icon: Icons.wc_outlined,
          ),
          _InfoRowWithIcon(
            label: "patientPhone".tr,
            value: c.patient.phoneNumber ?? "-",
            icon: Icons.phone_outlined,
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => Get.toNamed(
              AppRoute.medicalTests,
              arguments: {
                "user_id": c.patient.userId,
                "patient_name": c.patient.fullname,
              },
            ),
            icon: const Icon(Icons.medical_services_outlined, size: 20),
            label: Text("medicalExaminations".tr),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColor.primary,
              side: BorderSide(color: AppColor.primary),
            ),
          ),
        ],
      ),
    );
  }

  String _genderLabel(String? g) {
    if (g == null || g.isEmpty) return "-";
    final lower = g.toLowerCase();
    if (lower.contains('f') || lower.contains('انثى')) return "female".tr;
    if (lower.contains('m') || lower.contains('ذكر')) return "male".tr;
    return g;
  }
}

class _InfoRowWithIcon extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _InfoRowWithIcon({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "$label : $value",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NutritionalCalcSection extends StatelessWidget {
  final PatientDetailsController controller;

  const _NutritionalCalcSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    final c = controller;
    final w = c.patient.weight;
    final h = c.patient.height;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColor.shadowColor.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CalcRow("weightKg".tr, w?.toStringAsFixed(0) ?? "-"),
          _CalcRow("heightCm".tr, h != null ? h.toStringAsFixed(0) : "-"),
          _CalcRow("bmiResult".tr, c.bmi?.toStringAsFixed(2) ?? "-"),
          _CalcRow("bmr".tr, c.bmr?.toStringAsFixed(2) ?? "-"),
          _CalcRow("calories".tr, c.dailyCalories?.toStringAsFixed(2) ?? "-"),
          _CalcRow("physicalActivityLevel".tr, c.activityMultiplier.toStringAsFixed(1)),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () => Get.toNamed("/bmi"),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColor.primary,
              side: BorderSide(color: AppColor.primary),
            ),
            child: Text("bmiCalc".tr),
          ),
        ],
      ),
    );
  }
}

class _CalcRow extends StatelessWidget {
  final String label;
  final String value;

  const _CalcRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "$label :",
            style: TextStyle(fontSize: 14, color: Colors.grey.shade800),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
        ],
      ),
    );
  }
}

class _MacrosSection extends StatelessWidget {
  final PatientDetailsController controller;

  const _MacrosSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    final c = controller;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColor.shadowColor.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CalcRow("totalCalories".tr, c.dailyCalories?.toStringAsFixed(0) ?? "-"),
          const SizedBox(height: 12),
          Text(
            "macroSumMustBe100".tr,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 12),
          _MacroPercentStepper(
            label: "carbohydrates".tr,
            value: c.carbsPercent,
            calculatedGrams: c.calculatedCarbsGrams,
            rangeText: "50-65%",
            onIncrement: c.incrementCarbs,
            onDecrement: c.decrementCarbs,
          ),
          const SizedBox(height: 12),
          _MacroPercentStepper(
            label: "protein".tr,
            value: c.proteinPercent,
            calculatedGrams: c.calculatedProteinGrams,
            rangeText: "15-25%",
            onIncrement: c.incrementProtein,
            onDecrement: c.decrementProtein,
          ),
          const SizedBox(height: 12),
          _MacroPercentStepper(
            label: "fats".tr,
            value: c.fatPercent,
            calculatedGrams: c.calculatedFatGrams,
            rangeText: "25-35%",
            onIncrement: c.incrementFats,
            onDecrement: c.decrementFats,
          ),
          if (!c.macroSumValid)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                "macroSumMustBe100".tr,
                style: TextStyle(fontSize: 12, color: Colors.orange.shade700),
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              "Sum: ${c.macroSum}%",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: c.macroSumValid ? AppColor.primary : Colors.orange,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: c.saveMacrosStatus == StatusRequest.loading ? null : c.saveMacros,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: c.saveMacrosStatus == StatusRequest.loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text("saveChanges".tr),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: c.openCreateDiet,
                  icon: const Icon(Icons.restaurant_menu_outlined, size: 20),
                  label: Text(
                    Get.arguments is Map && Get.arguments['isEditDiet'] == true
                        ? "editDietChoice".tr
                        : "createDietForPatient".tr,
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColor.primary,
                    side: BorderSide(color: AppColor.primary),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MacroPercentStepper extends StatelessWidget {
  final String label;
  final int value;
  final double? calculatedGrams;
  final String rangeText;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const _MacroPercentStepper({
    required this.label,
    required this.value,
    this.calculatedGrams,
    required this.rangeText,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
            if (calculatedGrams != null && calculatedGrams! > 0)
              Text(
                "(${calculatedGrams!.toStringAsFixed(1)}g)",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColor.primary,
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          "${"macroPercent".tr}: $rangeText",
          style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton.filled(
              onPressed: onDecrement,
              icon: const Icon(Icons.remove, size: 20),
              style: IconButton.styleFrom(
                backgroundColor: Colors.grey.shade300,
                foregroundColor: Colors.grey.shade800,
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 60,
              child: Text(
                "$value%",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
            ),
            const SizedBox(width: 12),
            IconButton.filled(
              onPressed: onIncrement,
              icon: const Icon(Icons.add, size: 20),
              style: IconButton.styleFrom(
                backgroundColor: Colors.grey.shade300,
                foregroundColor: Colors.grey.shade800,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
