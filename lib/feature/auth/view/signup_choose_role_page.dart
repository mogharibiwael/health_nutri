import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constant/asset.dart';
import '../../../core/constant/theme/colors.dart';
import '../../../core/routes/app_route.dart';

/// Page 1: User chooses to sign up as User (patient) or Doctor.
class SignupChooseRolePage extends StatelessWidget {
  const SignupChooseRolePage({super.key});

  static const Color _lightLavender = Color(0xffe4e0ec);
  static const Color _darkPurple = AppColor.deepPurple;

  @override
  Widget build(BuildContext context) {
    final isAr = Get.locale?.languageCode == 'ar';
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 24),
                Image.asset(
                  ImageAssets.logo,
                  height: 180,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 28),
                _buildSegmentedControl(),
                const SizedBox(height: 36),
                _buildRoleButton(
                  label: "asUser".tr,
                  onTap: () => Get.toNamed(AppRoute.signUpUser, arguments: {'role': 'patient'}),
                ),
                const SizedBox(height: 12),
                _buildRoleButton(
                  label: "asDoctor".tr,
                  onTap: () => Get.toNamed(AppRoute.signUpDoctor, arguments: {'role': 'doctor'}),
                ),
                const SizedBox(height: 48),
                Align(
                  alignment: isAr ? Alignment.centerLeft : Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: GestureDetector(
                      onTap: () => Get.offNamed(AppRoute.welcome),
                      child: Icon(Icons.arrow_back, color: Colors.grey.shade700, size: 28),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildSegmentedControl() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () => Get.offNamed(AppRoute.login),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Text(
              "login".tr,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: _darkPurple,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: _lightLavender,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColor.textColor.withOpacity(0.06),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            "signup".tr,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: _darkPurple,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRoleButton({required String label, required VoidCallback onTap}) {
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: AppColor.primary,
        borderRadius: BorderRadius.circular(24),
        elevation: 2,
        shadowColor: AppColor.textColor.withOpacity(0.15),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            alignment: Alignment.center,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
