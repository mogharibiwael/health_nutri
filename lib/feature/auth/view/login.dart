import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constant/theme/colors.dart';
import 'package:nutri_guide/feature/auth/controller/login_controller.dart';

import '../../../core/class/status_request.dart';
import '../../../core/constant/asset.dart';
import '../../../core/routes/app_route.dart';

class Login extends GetView<LoginController> {
  const Login({super.key});

  static const Color _lightLavender = AppColor.mutedPurple;
  static const Color _darkPurple = AppColor.deepPurple;
  static const Color _accentGreen = AppColor.primary; // match welcome screen purple

  @override
  Widget build(BuildContext context) {
    final isAr = Get.locale?.languageCode == 'ar';
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          children: [
            const SizedBox(height: 24),
            Image.asset(
              ImageAssets.logo,
              height: 180,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 28),
            _buildSegmentedControl(isAr),
            const SizedBox(height: 28),
            _buildLoginField(
              controller: controller.emailController,
              hint: "enterPersonalEmail".tr,
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              obscureText: false,
            ),
            const SizedBox(height: 16),
            GetBuilder<LoginController>(
              builder: (c) => _buildLoginField(
                controller: c.passwordController,
                hint: "hintPassword".tr,
                icon: Icons.lock_outline,
                keyboardType: TextInputType.visiblePassword,
                obscureText: !c.isPasswordVisible,
                suffixIcon: IconButton(
                  icon: Icon(
                    c.isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey.shade700,
                    size: 22,
                  ),
                  onPressed: c.togglePasswordVisibility,
                ),
              ),
            ),
            const SizedBox(height: 24),
            GetBuilder<LoginController>(
              builder: (_) => _buildLoginButton(),
            ),
            const SizedBox(height: 20),
            _buildCreateAccountLink(),
            const SizedBox(height: 24),
            Align(
              alignment: isAr ? Alignment.centerLeft : Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: GestureDetector(
                  onTap: () => Get.offNamed(AppRoute.welcome),
                  child: Icon(
                    Icons.arrow_back,
                    color: Colors.grey.shade700,
                    size: 28,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }


  Widget _buildSegmentedControl(bool isAr) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Create Account (inactive)
        GestureDetector(
          onTap: () => Get.toNamed(AppRoute.signUp),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Text(
              "signup".tr,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: _darkPurple,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Login (active)
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
            "login".tr,
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

  Widget _buildLoginField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required TextInputType keyboardType,
    required bool obscureText,
    Widget? suffixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _lightLavender,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
                color: AppColor.textColor.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        textAlign: Get.locale?.languageCode == 'ar' ? TextAlign.right : TextAlign.left,
        style: const TextStyle(color: _darkPurple),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 15,
          ),
          prefixIcon: Icon(
            icon,
            color: AppColor.textColor,
            size: 22,
          ),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    final isLoading = controller.statusRequest == StatusRequest.loading;
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: AppColor.primary,
        borderRadius: BorderRadius.circular(24),
        elevation: 2,
        shadowColor: AppColor.textColor.withOpacity(0.15),
        child: InkWell(
          onTap: isLoading ? null : () => controller.login(),
          borderRadius: BorderRadius.circular(24),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            alignment: Alignment.center,
            child: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    "login".tr,
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

  Widget _buildCreateAccountLink() {
    return GestureDetector(
      onTap: () => controller.goToSignup(),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: TextStyle(
            fontSize: 15,
            color: Colors.grey.shade700,
          ),
          children: [
            TextSpan(text: "dontHaveAccountQuestion".tr),
            TextSpan(
              text: "createAccountAction".tr,
              style: const TextStyle(
                color: _accentGreen,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
