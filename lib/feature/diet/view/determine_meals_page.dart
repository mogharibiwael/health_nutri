import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constant/theme/colors.dart';
import '../../../core/shared/widgets/app_bar.dart';
import '../controller/determine_meals_controller.dart';

class DetermineMealsPage extends GetView<DetermineMealsController> {
  const DetermineMealsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DetermineMealsController>(
      builder: (c) => SafeArea(
        child: Scaffold(
          backgroundColor: Colors.grey.shade100,
          appBar: CustomAppBar(
            subtitle: c.patientName.isNotEmpty ? c.patientName : null,
            title: "determineMeals".tr,
            showBackButton: true,
            showLogo: true,
          ),
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ...c.getMealKeys().map((mealKey) =>
                          _buildMealSection(c, mealKey)),
                      const SizedBox(height: 16),
                      TextField(
                        controller: c.notesController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: "enterNotesIfAny".tr,
                          hintText: "enterNotesIfAny".tr,
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: c.goToCreateDiet,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text("createDiet".tr),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMealSection(DetermineMealsController c, String mealKey) {
    final breakdown = c.getMealBreakdown(mealKey);
    final items = c.getMealItems(mealKey);
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Container(
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
              "${c.mealKeyToLabel(mealKey)}:",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColor.primary,
              ),
            ),
            if (breakdown.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                breakdown,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
            const SizedBox(height: 12),
            if (items.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (var i = 0; i < items.length; i++)
                    Chip(
                      label: Text(items[i], style: const TextStyle(fontSize: 12)),
                      deleteIcon: const Icon(Icons.close, size: 18),
                      onDeleted: () => c.removeMealItem(mealKey, i),
                      backgroundColor: AppColor.primary.withOpacity(0.15),
                    ),
                ],
              ),
            if (items.isNotEmpty) const SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(
                hintText: "${"enterMealsFor".tr} ${c.mealKeyToLabel(mealKey)}",
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onSubmitted: (v) => c.addMealItem(mealKey, v),
            ),
          ],
        ),
      ),
    );
  }
}
