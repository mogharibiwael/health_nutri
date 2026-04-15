import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/shared/widgets/drawer.dart';

import '../../../core/class/status_request.dart';
import '../../../core/constant/theme/colors.dart';
import '../../../core/routes/app_route.dart';
import '../../../core/shared/widgets/app_bar.dart';
import '../../../doctorApp/feature/home/model/patient_model.dart';
import '../controller/doctor_patient_calculations_controller.dart';
import '../model/calculation_model.dart';

class DoctorPatientCalculationsPage extends GetView<DoctorPatientCalculationsController> {
  const DoctorPatientCalculationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DoctorPatientCalculationsController>(
      builder: (c) => SafeArea(
          child: Scaffold(
            drawer: HomeDrawer(controller: c),
            appBar: CustomAppBar(
              title: c.patientName.isNotEmpty ? c.patientName : "bodyCalculations".tr,
              showBackButton: true,
              leading: Builder(
                builder: (ctx) => IconButton(
                  icon: Icon(Icons.menu, color: AppColor.primary, size: 26),
                  onPressed: () => Scaffold.of(ctx).openDrawer(),
                ),
              ),
              actions: [
              IconButton(
                onPressed: c.refreshHistory,
                icon: const Icon(Icons.refresh, color: AppColor.deepPurple),
              ),
            ],
          ),
          backgroundColor: Colors.grey.shade100,
          body: _buildBody(c),
        ),
      ),
    );
  }

  Widget _buildBody(DoctorPatientCalculationsController c) {
    if (c.statusRequest == StatusRequest.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (c.statusRequest == StatusRequest.offlineFailure) {
      return _EmptyState(
        icon: Icons.wifi_off_rounded,
        title: "noInternet".tr,
        onRetry: c.refreshHistory,
      );
    }
    if (c.statusRequest == StatusRequest.serverFailure ||
        c.statusRequest == StatusRequest.failure) {
      return _EmptyState(
        icon: Icons.error_outline_rounded,
        title: "serverError".tr,
        onRetry: c.refreshHistory,
      );
    }

    if (c.calculations.isEmpty) {
      return _EmptyState(
        icon: Icons.calculate_outlined,
        title: "noCalculationsYet".tr,
        onRetry: c.refreshHistory,
      );
    }

    return RefreshIndicator(
      onRefresh: c.refreshHistory,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: c.calculations.length,
        itemBuilder: (_, i) => _DoctorCalculationCard(
          calculation: c.calculations[i],
          patient: c.patient,
        ),
      ),
    );
  }
}

class _DoctorCalculationCard extends StatelessWidget {
  final CalculationModel calculation;
  final PatientModel patient;

  const _DoctorCalculationCard({required this.calculation, required this.patient});

  @override
  Widget build(BuildContext context) {
    final date = calculation.createdAt;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColor.primary.withOpacity(0.18)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (date != null && date.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(
                  date,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ),
            Wrap(
              spacing: 10,
              runSpacing: 8,
              children: [
                _pill("BMI", _fmt(calculation.bmi, 2)),
                _pill("BMR", _fmt(calculation.bmr, 1)),
                _pill("kcal", _fmt(calculation.calories, 0)),
                _pill("carb", _fmt(calculation.carbs, 1)),
                _pill("protein", _fmt(calculation.protein, 1)),
                _pill("fat", _fmt(calculation.fat, 1)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Get.toNamed(AppRoute.patientDetails, arguments: patient);
                    },
                    icon: const Icon(Icons.restaurant_menu_outlined),
                    label: Text("createDiet".tr),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColor.primary,
                      side: BorderSide(color: AppColor.primary),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Get.toNamed(AppRoute.doctorDiets),
                    icon: const Icon(Icons.assessment_outlined),
                    label: Text("diets".tr),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _pill(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Text(
        "$label: $value",
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }

  String _fmt(double? v, int digits) {
    if (v == null) return "-";
    return v.toStringAsFixed(digits);
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onRetry;

  const _EmptyState({required this.icon, required this.title, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(title, style: TextStyle(color: Colors.grey.shade700)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(backgroundColor: AppColor.primary, foregroundColor: Colors.white),
              child: Text("retry".tr),
            ),
          ],
        ),
      ),
    );
  }
}

