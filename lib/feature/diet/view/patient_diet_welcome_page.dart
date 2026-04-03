import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nutri_guide/core/constant/asset.dart';
import 'package:nutri_guide/core/constant/theme/colors.dart';
import 'package:nutri_guide/core/routes/app_route.dart';
import 'package:nutri_guide/core/shared/widgets/drawer.dart';
import 'package:nutri_guide/feature/home/controller/home_controller.dart';

class PatientDietWelcomePage extends GetView<HomeController> {
  const PatientDietWelcomePage({super.key});

  static const Color _accentPurple = AppColor.primary;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        drawer: HomeDrawer(controller: controller),
        appBar: AppBar(
          backgroundColor: AppColor.primary.withOpacity(0.08),
          elevation: 0,
          leading: Builder(
            builder: (ctx) {
              return IconButton(
                icon: Icon(Icons.menu, color: AppColor.primary, size: 26),
                onPressed: () => Scaffold.of(ctx).openDrawer(),
              );
            },
          ),
          title: Text(
            "myDiet".tr,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColor.primary,
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColor.shadowColor.withOpacity(0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Image.asset(ImageAssets.logo, fit: BoxFit.contain),
                  ),
                ),
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 24),
                // Illustration
                Image.asset(
                  ImageAssets.patientWelcome,
                  height: 200,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
                  decoration: BoxDecoration(
                    color: AppColor.customGrey,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(25),
                      bottomRight: Radius.circular(25),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColor.shadowColor.withOpacity(0.1),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        "welcome".tr,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: _accentPurple,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        controller.subscribedDoctorName.isNotEmpty
                            ? "welcomeToDoctorVirtualClinic".trParams({
                                "name": controller.subscribedDoctorName,
                              })
                            : "welcomeToClinicSub".tr,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColor.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
