import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constant/theme/colors.dart';
import '../../../core/shared/widgets/app_bar.dart';
import '../../../core/shared/widgets/drawer.dart';
import '../../../core/routes/app_route.dart';
import '../../../core/class/status_request.dart';
import '../controller/diet_controller.dart';
import '../model/diet_model.dart';

class PatientDietsListPage extends GetView<DietController> {
  const PatientDietsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>;
    final patient = args['patient'];
    final patientName = args['patient_name'] ?? patient?.fullname ?? "";
    final patientId = args['patient_id'] ?? patient?.id;

    final isAr = Get.locale?.languageCode == 'ar';

    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: GetBuilder<DietController>(
        initState: (_) {
          final args = Get.arguments as Map<String, dynamic>?;
          final pId = args?['patient_id'] ?? args?['patient']?.id;
          controller.loadAllDiets(patientId: pId);
        },
        builder: (c) => Scaffold(
          drawer: HomeDrawer(controller: c),
          backgroundColor: Colors.grey.shade100,
          appBar: CustomAppBar(
            title: "${"dietHistory".tr}: $patientName",
            showBackButton: true,
            leading: Builder(
              builder: (ctx) => IconButton(
                icon: Icon(Icons.menu, color: AppColor.primary, size: 26),
                onPressed: () => Scaffold.of(ctx).openDrawer(),
              ),
            ),
          ),
          body: _buildBody(c, patientId, args),
        ),
      ),
    );
  }

  Widget _buildBody(DietController c, dynamic patientId, Map<String, dynamic> args) {
    if (c.doctorDietsStatus == StatusRequest.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final filteredDiets = c.allDiets.where((d) => d.patientId == patientId).toList();

    if (filteredDiets.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.restaurant_menu_rounded, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              "noDiet".tr,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredDiets.length,
      itemBuilder: (context, index) {
        final diet = filteredDiets[index];
        return _DietRowCard(
          diet: diet,
          onEdit: () => Get.toNamed(AppRoute.patientDetails, arguments: {
            ...args,
            'isEditDiet': true,
            'diet_id': diet.id,
            'diet_title': diet.title,
            'diet_calories': diet.dailyCalories,
          }),
          onDelete: () => _confirmDelete(context, c, diet),
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, DietController c, DietModel diet) {
    Get.defaultDialog(
      title: "delete".tr,
      middleText: "${"deleteConfirm".tr}\n${diet.title}",
      textCancel: "cancel".tr,
      textConfirm: "delete".tr,
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () async {
        Get.back();
        final success = await c.deleteDiet(diet.id, isPlan: diet.isDietPlan);
        if (success) {
          final args = Get.arguments as Map<String, dynamic>?;
          final pId = args?['patient_id'] ?? args?['patient']?.id;
          c.loadAllDiets(patientId: pId);
        }
      },
    );
  }
}

class _DietRowCard extends StatelessWidget {
  final DietModel diet;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _DietRowCard({
    required this.diet,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    diet.title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${diet.dailyCalories} kcal | ${diet.durationDays} ${"day".tr}",
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),
                  Text(
                    "${diet.startDate} - ${diet.endDate}",
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                  onPressed: onEdit,
                  tooltip: "edit".tr,
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                  onPressed: onDelete,
                  tooltip: "delete".tr,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
