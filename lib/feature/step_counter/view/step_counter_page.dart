import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nutri_guide/core/constant/theme/colors.dart';
import 'package:nutri_guide/core/shared/widgets/app_bar.dart';
import 'package:nutri_guide/feature/step_counter/controller/step_counter_controller.dart';

class StepCounterPage extends GetView<StepCounterController> {
  const StepCounterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: "stepCounter".tr,
        showBackButton: true,
        showLogo: true,
      ),
      body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 48),
              // Circular step display
              Expanded(
                child: Center(
                  child: Obx(() {
                    return Container(
                      width: 220,
                      height: 220,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.transparent,
                        border: Border.all(
                          color: AppColor.primary,
                          width: 12,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColor.shadowColor.withOpacity(0.2),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.directions_walk,
                            size: 48,
                            color: AppColor.primary,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '${controller.steps.value}',
                            style: const TextStyle(
                              fontSize: 42,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xDD2A0126),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            controller.stepLabel,
                            style: TextStyle(
                              fontSize: 16,
                              color: const Color(0x8A2A0126),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 32),
              // Start Counting button
              Obx(() {
                final isCounting = controller.isCounting.value;
                return SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: isCounting
                        ? () => controller.stopCounting()
                        : () => controller.startCounting(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isCounting ? Colors.red.shade400 : AppColor.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                      shadowColor: (isCounting ? Colors.red : AppColor.primary).withOpacity(0.4),
                    ),
                    child: Text(
                      isCounting ? "إيقاف العداد" : "startCounting".tr,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}

