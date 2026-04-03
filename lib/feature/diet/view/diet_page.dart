import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/class/status_request.dart';
import '../../../core/constant/theme/colors.dart';
import '../../../core/shared/widgets/app_bar.dart';
import '../../../core/shared/widgets/drawer.dart';
import '../controller/diet_controller.dart';
import '../model/diet_model.dart';

class DietPage extends GetView<DietController> {
  const DietPage({super.key});

  @override
  Widget build(BuildContext context) {
    final scaffoldKey = GlobalKey<ScaffoldState>();
    return GetBuilder<DietController>(
      builder: (c) => SafeArea(
        child: Scaffold(
        key: scaffoldKey,
        drawer: HomeDrawer(controller: c),
        appBar: CustomAppBar(
          title: "myDiet".tr,
          leading: IconButton(
            onPressed: () => scaffoldKey.currentState?.openDrawer(),
            icon: const Icon(Icons.menu, color: AppColor.deepPurple, size: 26),
            padding: const EdgeInsets.all(4),
            constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: AppColor.deepPurple),
              onPressed: c.refreshDiet,
            ),
            if (c.canCreateDiet)
              IconButton(
                icon: const Icon(Icons.add, color: AppColor.deepPurple),
                onPressed: () => _showCreateDialog(context, c),
              ),
          ],
        ),
        backgroundColor: Colors.grey.shade100,
        body: _buildBody(c),
      ),
    ));
  }

  Widget _buildBody(DietController c) {
    if (c.statusRequest == StatusRequest.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (c.statusRequest == StatusRequest.offlineFailure) {
      return _EmptyState(
        icon: Icons.wifi_off_rounded,
        title: "noInternet".tr,
        buttonText: "retry".tr,
        onRetry: c.refreshDiet,
      );
    }

    if (c.statusRequest == StatusRequest.serverFailure ||
        c.statusRequest == StatusRequest.failure) {
      return _EmptyState(
        icon: Icons.error_outline_rounded,
        title: "serverError".tr,
        buttonText: "retry".tr,
        onRetry: c.refreshDiet,
      );
    }

    if (c.currentDiet == null) {
      return _EmptyState(
        icon: Icons.restaurant_menu_outlined,
        title: "noDiet".tr,
        buttonText: "refresh".tr,
        onRetry: c.refreshDiet,
      );
    }

    final diet = c.currentDiet!;

    return RefreshIndicator(
      onRefresh: c.refreshDiet,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _DietInfoCard(diet: diet),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () => Get.toNamed("/diet-meals"),
              icon: const Icon(Icons.restaurant_menu),
              label: Text("viewMeals".tr),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateDialog(BuildContext context, DietController c) {
    Get.dialog(
      Dialog(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "createDietPlan".tr,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: c.patientIdController,
                  decoration: InputDecoration(
                    labelText: "patientId".tr,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: c.titleController,
                  decoration: InputDecoration(
                    labelText: "title".tr,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: c.dailyCaloriesController,
                  decoration: InputDecoration(
                    labelText: "dailyCalories".tr,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: c.durationDaysController,
                  decoration: InputDecoration(
                    labelText: "durationDays".tr,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: c.startDateController,
                  decoration: InputDecoration(
                    labelText: "startDate".tr,
                    hintText: "2024-01-01",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: c.endDateController,
                  decoration: InputDecoration(
                    labelText: "endDate".tr,
                    hintText: "2024-01-31",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Get.back(),
                        child: Text("cancel".tr),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          final patientId = int.tryParse(c.patientIdController.text);
                          final doctorId = c.currentDoctorId ?? c.currentUserId;
                          final dailyCalories = int.tryParse(c.dailyCaloriesController.text);
                          final durationDays = int.tryParse(c.durationDaysController.text);

                          if (patientId == null ||
                              doctorId == null ||
                              c.titleController.text.isEmpty ||
                              dailyCalories == null ||
                              durationDays == null ||
                              c.startDateController.text.isEmpty ||
                              c.endDateController.text.isEmpty) {
                            Get.snackbar("error".tr, "fillFields".tr);
                            return;
                          }

                          c.createDietPlan(
                            patientId: patientId,
                            doctorId: doctorId,
                            title: c.titleController.text,
                            dailyCalories: dailyCalories,
                            durationDays: durationDays,
                            startDate: c.startDateController.text,
                            endDate: c.endDateController.text,
                          );
                          Get.back();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.primary,
                        ),
                        child: Text("create".tr),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DietInfoCard extends StatelessWidget {
  final DietModel diet;

  const _DietInfoCard({required this.diet});

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              diet.title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            if (diet.doctorName != null) ...[
              const SizedBox(height: 8),
              Text(
                "Doctor: ${diet.doctorName}",
                style: TextStyle(color: Colors.grey.shade700),
              ),
            ],
            const SizedBox(height: 12),
            _InfoRow("Daily Calories", "${diet.dailyCalories} kcal"),
            _InfoRow("Duration", "${diet.durationDays} days"),
            _InfoRow("Start Date", diet.startDate),
            _InfoRow("End Date", diet.endDate),
            if (diet.notes != null && diet.notes!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                diet.notes!,
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ],
          ],
        ),
      ),
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
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(color: Colors.grey.shade700),
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600),
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
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.primary,
              ),
              child: Text(buttonText),
            ),
          ],
        ),
      ),
    );
  }
}
