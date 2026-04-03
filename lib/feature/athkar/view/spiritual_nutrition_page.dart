import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constant/theme/colors.dart';
import '../../../core/shared/widgets/app_bar.dart';
import '../controller/spiritual_nutrition_controller.dart';

const Color _buttonPurple = AppColor.deepPurple;

class SpiritualNutritionPage extends GetView<SpiritualNutritionController> {
  const SpiritualNutritionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: CustomAppBar(
          title: "spiritualNutrition".tr,
          showBackButton: true,
          showLogo: true,
        ),
        backgroundColor: Colors.white,
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              _AthkarButton(
                label: "morningAthkar".tr,
                onTap: controller.goMorningAthkar,
              ),
              const SizedBox(height: 20),
              _AthkarButton(
                label: "eveningAthkar".tr,
                onTap: controller.goEveningAthkar,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AthkarButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _AthkarButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _buttonPurple,
      borderRadius: BorderRadius.circular(20),
      elevation: 4,
      shadowColor: AppColor.shadowColor.withOpacity(0.35),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          alignment: Alignment.center,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
