import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constant/theme/colors.dart';
import '../../../core/service/diet_calculator_service.dart';
import '../../../core/shared/widgets/app_bar.dart';
import '../controller/diet_targets_controller.dart';
import '../model/exchange_model.dart';

class DietTargetsPage extends GetView<DietTargetsController> {
  const DietTargetsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DietTargetsController>(
      builder: (c) => SafeArea(
        child: Scaffold(
          backgroundColor: Colors.grey.shade100,
          appBar: CustomAppBar(
            title: "dietTargets".tr,
            subtitle: c.patientName.isNotEmpty ? c.patientName : null,
            showBackButton: true,
            showLogo: true,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (c.patientName.isNotEmpty)
                  _SectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Patient: ${c.patientName}",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColor.primary,
                          ),
                        ),
                        if (!c.hasValidPatientData)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              "fillPatientProfile".tr,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.orange.shade700,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),
                if (c.targetsResult != null) ...[
                  _SectionCard(
                    title: "targetCalories".tr,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _CalcRow("bmr".tr, c.targetsResult!.bmr.toStringAsFixed(0)),
                        _CalcRow("tdee".tr, c.targetsResult!.tdee.toStringAsFixed(0)),
                        _CalcRow("targetCalories".tr,
                            c.targetsResult!.targetCalories.toStringAsFixed(0)),
                        _CalcRow("carbohydrates".tr,
                            "${c.targetsResult!.macros.carbsG.toStringAsFixed(1)} g"),
                        _CalcRow("protein".tr,
                            "${c.targetsResult!.macros.proteinG.toStringAsFixed(1)} g"),
                        _CalcRow("fats".tr,
                            "${c.targetsResult!.macros.fatG.toStringAsFixed(1)} g"),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _SectionCard(
                    title: "goal".tr,
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _GoalChip(
                          label: "maintain".tr,
                          selected: c.goal == DietGoal.maintain,
                          onTap: () => c.setGoal(DietGoal.maintain),
                        ),
                        _GoalChip(
                          label: "weightLoss".tr,
                          selected: c.goal == DietGoal.weightLoss,
                          onTap: () => c.setGoal(DietGoal.weightLoss),
                        ),
                        _GoalChip(
                          label: "weightGain".tr,
                          selected: c.goal == DietGoal.weightGain,
                          onTap: () => c.setGoal(DietGoal.weightGain),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _SectionCard(
                    title: "milk".tr,
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _GoalChip(
                          label: "milkSkim".tr,
                          selected: c.milkType == MilkType.skim,
                          onTap: () => c.setMilkType(MilkType.skim),
                        ),
                        _GoalChip(
                          label: "milkLowFat".tr,
                          selected: c.milkType == MilkType.lowFat,
                          onTap: () => c.setMilkType(MilkType.lowFat),
                        ),
                        _GoalChip(
                          label: "milkWhole".tr,
                          selected: c.milkType == MilkType.whole,
                          onTap: () => c.setMilkType(MilkType.whole),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _SectionCard(
                    title: "meat".tr,
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _GoalChip(
                          label: "meatVeryLean".tr,
                          selected: c.meatType == MeatType.veryLean,
                          onTap: () => c.setMeatType(MeatType.veryLean),
                        ),
                        _GoalChip(
                          label: "meatLean".tr,
                          selected: c.meatType == MeatType.lean,
                          onTap: () => c.setMeatType(MeatType.lean),
                        ),
                        _GoalChip(
                          label: "meatMediumFat".tr,
                          selected: c.meatType == MeatType.mediumFat,
                          onTap: () => c.setMeatType(MeatType.mediumFat),
                        ),
                        _GoalChip(
                          label: "meatHighFat".tr,
                          selected: c.meatType == MeatType.highFat,
                          onTap: () => c.setMeatType(MeatType.highFat),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (c.exchangePlan != null)
                    _SectionCard(
                      title: "servingsPerDay".tr,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _ExchangeRow("starch".tr, c.exchangePlan!.starch),
                          _ExchangeRow("fruit".tr, c.exchangePlan!.fruit),
                          _ExchangeRow("vegetables".tr, c.exchangePlan!.vegetables),
                          _ExchangeRow("milk".tr, c.exchangePlan!.milk),
                          _ExchangeRow("meat".tr, c.exchangePlan!.meat),
                          _ExchangeRow("fat".tr, c.exchangePlan!.fat),
                        ],
                      ),
                    ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: c.hasValidPatientData ? c.goToDistribution : null,
                      icon: const Icon(Icons.arrow_forward, size: 22),
                      label: Text("nextStep".tr),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ] else if (c.hasValidPatientData)
                  const Center(child: CircularProgressIndicator()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String? title;
  final Widget child;

  const _SectionCard({this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
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
          if (title != null) ...[
            Text(
              title!,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColor.primary,
              ),
            ),
            const SizedBox(height: 12),
          ],
          child,
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 14, color: Colors.grey.shade700)),
          Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey.shade900)),
        ],
      ),
    );
  }
}

class _ExchangeRow extends StatelessWidget {
  final String label;
  final double servings;

  const _ExchangeRow(this.label, this.servings);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 14, color: Colors.grey.shade700)),
          Text(servings.toStringAsFixed(1), style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey.shade900)),
        ],
      ),
    );
  }
}

class _GoalChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _GoalChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: AppColor.primary.withOpacity(0.15),
      checkmarkColor: AppColor.primary,
      labelStyle: TextStyle(color: selected ? AppColor.primary : Colors.grey.shade700),
      backgroundColor: Colors.grey.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }
}
