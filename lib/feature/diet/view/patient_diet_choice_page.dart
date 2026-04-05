import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constant/theme/colors.dart';
import '../../../core/shared/widgets/app_bar.dart';
import '../../../core/shared/widgets/drawer.dart';
import '../../../core/routes/app_route.dart';
import '../controller/diet_controller.dart';

class PatientDietChoicePage extends GetView<DietController> {
  const PatientDietChoicePage({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>;
    final patient = args['patient'];
    final patientName = args['patient_name'] ?? patient?.fullname ?? "";
    final patientId = args['patient_id'] ?? patient?.id;

    final isAr = Get.locale?.languageCode == 'ar';

    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        drawer: HomeDrawer(controller: controller),
        backgroundColor: Colors.grey.shade100,
        appBar: CustomAppBar(
          title: patientName,
          showBackButton: true,
          leading: Builder(
            builder: (ctx) => IconButton(
              icon: Icon(Icons.menu, color: AppColor.primary, size: 26),
              onPressed: () => Scaffold.of(ctx).openDrawer(),
            ),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _ChoiceCard(
                  title: "viewDietChoice".tr,
                  icon: Icons.history_rounded,
                  color: AppColor.primary,
                  onTap: () => Get.toNamed(AppRoute.patientDietsList, arguments: args),
                ),
                const SizedBox(height: 24),
                _ChoiceCard(
                  title: "createDietChoice".tr,
                  icon: Icons.add_circle_outline_rounded,
                  color: AppColor.deepPurple,
                  onTap: () => Get.toNamed(AppRoute.patientDetails, arguments: {
                    ...args,
                    'isEditDiet': false,
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ChoiceCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ChoiceCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(color: color.withOpacity(0.2), width: 1.5),
        ),
        child: Column(
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
