import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/shared/widgets/drawer.dart';
import '../../../core/class/status_request.dart';
import '../../../core/constant/theme/colors.dart';
import '../../../core/shared/widgets/drawer.dart';
import '../../../core/shared/widgets/app_bar.dart';
import '../controller/diet_controller.dart';
import '../model/diet_model.dart';

/// Doctor-only: Lists diets created by the doctor.
class DoctorDietsPage extends StatefulWidget {
  const DoctorDietsPage({super.key});

  @override
  State<DoctorDietsPage> createState() => _DoctorDietsPageState();
}

class _DoctorDietsPageState extends State<DoctorDietsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final c = Get.find<DietController>();
      if (c.isDoctor) c.loadAllDiets();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isAr = Get.locale?.languageCode == 'ar';
    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: GetBuilder<DietController>(
        builder: (c) => SafeArea(
          child: Scaffold(
            drawer: HomeDrawer(controller: c),
            appBar: CustomAppBar(
              title: "reports".tr,
              showBackButton: true,
              leading: Builder(
                builder: (ctx) => IconButton(
                  icon: Icon(Icons.menu, color: AppColor.primary, size: 26),
                  onPressed: () => Scaffold.of(ctx).openDrawer(),
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh, color: AppColor.deepPurple),
                  onPressed: () => c.loadAllDiets(),
                ),
              ],
            ),
            backgroundColor: Colors.grey.shade100,
            body: _buildBody(c),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(DietController c) {
    if (c.doctorDietsStatus == StatusRequest.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (c.doctorDietsStatus == StatusRequest.offlineFailure) {
      return _EmptyState(
        icon: Icons.wifi_off_rounded,
        title: "noInternet".tr,
        buttonText: "retry".tr,
        onRetry: () => c.loadAllDiets(),
      );
    }

    if (c.doctorDietsStatus == StatusRequest.serverFailure ||
        c.doctorDietsStatus == StatusRequest.failure) {
      return _EmptyState(
        icon: Icons.error_outline_rounded,
        title: "serverError".tr,
        buttonText: "retry".tr,
        onRetry: () => c.loadAllDiets(),
      );
    }

    if (c.allDiets.isEmpty) {
      return _EmptyState(
        icon: Icons.restaurant_menu_outlined,
        title: "noDiet".tr,
        buttonText: "refresh".tr,
        onRetry: () => c.loadAllDiets(),
      );
    }

    return RefreshIndicator(
      onRefresh: () => c.loadAllDiets(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: c.allDiets.length,
        itemBuilder: (context, index) {
          final diet = c.allDiets[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _DietCard(
              diet: diet,
              onTap: () => _showDietContents(context, c, diet),
            ),
          );
        },
      ),
    );
  }

  void _showDietContents(BuildContext context, DietController c, DietModel diet) async {
    DietModel? fullDiet = diet;
    if (diet.meals.isEmpty) {
      fullDiet = await c.loadDiet(diet.id);
    }
    if (!context.mounted) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _DietContentsSheet(diet: fullDiet ?? diet),
    );
  }
}

String _mealTypeTr(String mealType) {
  switch (mealType.toLowerCase()) {
    case "breakfast":
      return "breakfast".tr;
    case "lunch":
      return "lunch".tr;
    case "dinner":
      return "dinner".tr;
    case "firstsnack":
      return "firstSnack".tr;
    case "secondsnack":
      return "secondSnack".tr;
    case "thirdsnack":
      return "thirdSnack".tr;
    case "extrasnack":
    case "snack":
      return "extraSnack".tr;
    default:
      return mealType.isNotEmpty ? mealType : "extraSnack".tr;
  }
}

class _DietContentsSheet extends StatelessWidget {
  final DietModel diet;

  const _DietContentsSheet({required this.diet});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (_, scrollController) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                "dietContents".tr,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColor.deepPurple,
                ),
              ),
            ),
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                children: [
                  _InfoRow("dietPlanTitle".tr, diet.title),
                  if (diet.patientName != null)
                    _InfoRow("patientName".tr, diet.patientName!),
                  _InfoRow("dailyCalories".tr, "${diet.dailyCalories} kcal"),
                  _InfoRow("durationDays".tr, "${diet.durationDays} days"),
                  _InfoRow("startDate".tr, diet.startDate),
                  _InfoRow("endDate".tr, diet.endDate),
                  if (diet.notes != null && diet.notes!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text("notes".tr, style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(diet.notes!),
                  ],
                  const SizedBox(height: 20),
                  Text(
                    "dietMeals".tr,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColor.deepPurple,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (diet.meals.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: Text(
                          "noMealsInPlan".tr,
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ),
                    )
                  else
                    ...diet.meals.map((m) => _MealCard(meal: m)),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text("close".tr),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MealCard extends StatelessWidget {
  final DietMealModel meal;

  const _MealCard({required this.meal});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _mealTypeTr(meal.mealType),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                Text(
                  "${"day".tr} ${meal.dayNumber}",
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              meal.mealName,
              style: const TextStyle(fontSize: 14),
            ),
            if (meal.servingSummary != null && meal.servingSummary!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                meal.servingSummary!,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
            if (meal.description != null && meal.description!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                meal.description!,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _Chip(label: "${meal.calories} ${"calories".tr}"),
                if (meal.carbsG != null) _Chip(label: "${meal.carbsG}g ${"carbohydrates".tr}"),
                if (meal.proteinG != null) _Chip(label: "${meal.proteinG}g ${"protein".tr}"),
                if (meal.fatG != null) _Chip(label: "${meal.fatG}g ${"fats".tr}"),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;

  const _Chip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColor.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 12),
      ),
    );
  }
}

class _DietCard extends StatelessWidget {
  final DietModel diet;
  final VoidCallback onTap;

  const _DietCard({required this.diet, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      diet.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColor.deepPurple,
                      ),
                    ),
                  ),
                  Icon(
                    Get.locale?.languageCode == 'ar' ? Icons.keyboard_arrow_left : Icons.keyboard_arrow_right,
                    size: 24,
                    color: Colors.grey.shade600,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "tapToViewDiet".tr,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColor.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                    onPressed: () => _confirmDelete(context, Get.find<DietController>(), diet),
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, DietController c, DietModel diet) {
    Get.defaultDialog(
      title: "deleteDiet".tr,
      middleText: "confirmDeleteDiet".tr,
      textConfirm: "delete".tr,
      textCancel: "cancel".tr,
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () async {
        Get.back();
        final success = await c.deleteDiet(diet.id, isPlan: diet.isDietPlan);
        if (success) {
          c.loadAllDiets();
        }
      },
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String buttonText;
  final VoidCallback onRetry;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.buttonText,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(buttonText),
            ),
          ],
        ),
      ),
    );
  }
}
