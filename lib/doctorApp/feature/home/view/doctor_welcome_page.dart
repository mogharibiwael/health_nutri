import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constant/theme/colors.dart';
import 'package:nutri_guide/core/constant/asset.dart';
import 'package:nutri_guide/core/routes/app_route.dart';
import 'package:nutri_guide/core/shared/widgets/drawer.dart';

import '../controller/home_doctor_controller.dart';

/// Doctor welcome screen after login: "Your Private Clinic"
class DoctorWelcomePage extends GetView<DoctorHomeController> {
  const DoctorWelcomePage({super.key});

  static const Color _accentPurple = AppColor.primary;

  @override
  Widget build(BuildContext context) {
    final isAr = Get.locale?.languageCode == 'ar';

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        drawer: HomeDrawer(controller: controller),
        appBar: AppBar(
          backgroundColor: AppColor.primary.withOpacity(0.08),
          elevation: 0,
          leading:Builder(
              builder: (ctx)  {
              return IconButton(
                icon: Icon(Icons.menu, color: AppColor.primary, size: 26),
                onPressed: () => Scaffold.of(ctx).openDrawer(),
              );
            }
          ),
          title: Text(
            "yourPrivateClinic".tr,
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
            )

          ],
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 24),
              // Illustration
              Image.asset(
                ImageAssets.doctorWelcome,
                height: 200,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 24),
              // Welcome card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
                decoration: BoxDecoration(
                  color: AppColor.customGrey,
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(25), bottomRight: Radius.circular(25)),
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
                      "welcomeToClinic".tr,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: _accentPurple,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "welcomeToClinicSub".tr,
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
              Spacer(),
              // Logout button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: controller.logout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 2,
                    shadowColor: AppColor.shadowColor.withOpacity(0.3),
                  ),
                  child: Text(
                    "logout".tr,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
