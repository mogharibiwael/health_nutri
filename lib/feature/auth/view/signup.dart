import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constant/theme/colors.dart';
import 'package:nutri_guide/feature/auth/controller/signup_controller.dart';

import '../../../core/class/status_request.dart';
import '../../../core/constant/asset.dart';
import '../../../core/constant/theme/colors.dart';
import '../../../core/routes/app_route.dart';

class Signup extends GetView<SignupController> {
  const Signup({super.key});

  static const Color _lightLavender = AppColor.mutedPurple;
  static const Color _darkPurple = AppColor.deepPurple;
  static const Color _accentGreen = AppColor.primary; // match welcome screen purple

  @override
  Widget build(BuildContext context) {
    final isAr = Get.locale?.languageCode == 'ar';
    return GetBuilder<SignupController>(
      builder: (c) => Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            children: [
              const SizedBox(height: 24),
                // ─── Logo ───
                Image.asset(
                  ImageAssets.logo,
                  height: 180,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 28),
                // ─── Segmented control: Create Account (active) | Login ───
                _buildSegmentedControl(),
                const SizedBox(height: 28),
                // ─── Role selection: As User | As Doctor ───
                _buildRoleSelection(c),
                const SizedBox(height: 24),
                // ─── Input fields ───
                _buildSignupField(
                  controller: c.nameController,
                  hint: "enterNameShort".tr,
                  icon: Icons.person_outline,
                  keyboardType: TextInputType.name,
                  obscureText: false,
                ),
                const SizedBox(height: 16),
                _buildSignupField(
                  controller: c.emailController,
                  hint: "enterPersonalEmail".tr,
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  obscureText: false,
                ),
                const SizedBox(height: 16),
                _buildSignupField(
                  controller: c.passwordController,
                  hint: "hintPassword".tr,
                  icon: Icons.lock_outline,
                  keyboardType: TextInputType.visiblePassword,
                  obscureText: c.isPasswordHidden,
                  suffixIcon: IconButton(
                    icon: Icon(
                      c.isPasswordHidden ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      size: 22,
                      color: AppColor.textColor,
                    ),
                    onPressed: c.statusRequest == StatusRequest.loading ? null : c.togglePassword,
                  ),
                ),
                const SizedBox(height: 16),
                _buildSignupField(
                  controller: c.confirmPasswordController,
                  hint: "confirmPasswordAction".tr,
                  icon: Icons.lock_outline,
                  keyboardType: TextInputType.visiblePassword,
                  obscureText: c.isConfirmPasswordHidden,
                  suffixIcon: IconButton(
                    icon: Icon(
                      c.isConfirmPasswordHidden ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      size: 22,
                      color: AppColor.textColor,
                    ),
                    onPressed: c.statusRequest == StatusRequest.loading ? null : c.toggleConfirmPassword,
                  ),
                ),
                // ─── Doctor-only fields ───
                if (c.selectedRole == 'doctor') ...[
                  const SizedBox(height: 16),
                  _buildSignupField(
                    controller: c.phoneController,
                    hint: "enterPhone".tr,
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    obscureText: false,
                  ),
                  const SizedBox(height: 16),
                  _buildSignupField(
                    controller: c.dietPriceController,
                    hint: "enterDietPrice".tr,
                    icon: Icons.receipt_long_outlined,
                    keyboardType: TextInputType.number,
                    obscureText: false,
                  ),
                  const SizedBox(height: 16),
                  _buildSignupField(
                    controller: c.bankAccountController,
                    hint: "enterBankAccount".tr,
                    icon: Icons.account_balance_outlined,
                    keyboardType: TextInputType.text,
                    obscureText: false,
                  ),
                  const SizedBox(height: 20),
                  _buildGenderSelection(c),
                  const SizedBox(height: 20),
                  _buildFileUploadSection(c),
                ],
                const SizedBox(height: 24),
                // ─── Create Account button ───
                _buildCreateAccountButton(c),
                const SizedBox(height: 20),
                // ─── Login link ───
                _buildLoginLink(),
                const SizedBox(height: 24),
                Align(
                  alignment: isAr ? Alignment.centerLeft : Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Icon(Icons.arrow_back, color: Colors.grey.shade700, size: 28),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }





  Widget _buildSegmentedControl() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Login (inactive)
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
        // Create Account (active)
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

  Widget _buildRoleSelection(SignupController c) {
    final isUserSelected = c.selectedRole == 'patient';
    final isDoctorSelected = c.selectedRole == 'doctor';
    return Column(
      children: [
        _buildRoleButton(
          label: "asUser".tr,
          isSelected: isUserSelected,
          onTap: c.statusRequest == StatusRequest.loading
              ? null
              : () {
                  c.selectedRole = 'patient';
                  c.selectedType = 'user';
                  c.update();
                },
        ),
        const SizedBox(height: 12),
        _buildRoleButton(
          label: "asDoctor".tr,
          isSelected: isDoctorSelected,
          onTap: c.statusRequest == StatusRequest.loading
              ? null
              : () {
                  c.selectedRole = 'doctor';
                  c.selectedType = 'doctor';
                  c.update();
                },
        ),
      ],
    );
  }

  Widget _buildRoleButton({
    required String label,
    required bool isSelected,
    required VoidCallback? onTap,
  }) {
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
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: isSelected ? Border.all(color: Colors.white, width: 2) : null,
            ),
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

  Widget _buildSignupField({
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
          hintStyle: TextStyle(color: Colors.grey.shade600, fontSize: 15),
          prefixIcon: Icon(icon, color: AppColor.textColor, size: 22),
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

  Widget _buildGenderSelection(SignupController c) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildGenderOption(c, 'male', "male".tr),
        const SizedBox(width: 24),
        _buildGenderOption(c, 'female', "female".tr),
      ],
    );
  }

  Widget _buildGenderOption(SignupController c, String value, String label) {
    final isSelected = c.selectedGender == value;
    return GestureDetector(
      onTap: c.statusRequest == StatusRequest.loading
          ? null
          : () {
              c.selectedGender = value;
              c.update();
            },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
            color: isSelected ? AppColor.primary : Colors.grey,
            size: 24,
          ),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(color: Colors.grey.shade800, fontSize: 15)),
        ],
      ),
    );
  }

  Widget _buildFileUploadSection(SignupController c) {
    return Row(
      children: [
        Expanded(
          child: _buildFileUploadCard(
            label: "academicDegree".tr,
            onTap: () => c.pickDegreeFile(),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildFileUploadCard(
            label: "cvBio".tr,
            onTap: () => c.pickCvFile(),
          ),
        ),
      ],
    );
  }

  Widget _buildFileUploadCard({required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _lightLavender,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColor.textColor.withOpacity(0.06),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(Icons.add_photo_alternate_outlined, size: 40, color: Colors.grey.shade600),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateAccountButton(SignupController c) {
    final isLoading = c.statusRequest == StatusRequest.loading;
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: AppColor.primary,
        borderRadius: BorderRadius.circular(24),
        elevation: 2,
        shadowColor: AppColor.textColor.withOpacity(0.15),
        child: InkWell(
          onTap: isLoading ? null : c.register,
          borderRadius: BorderRadius.circular(24),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            alignment: Alignment.center,
            child: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : Text(
                    "signup".tr,
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

  Widget _buildLoginLink() {
    return GestureDetector(
      onTap: () => controller.goToLogin(),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: TextStyle(fontSize: 15, color: Colors.grey.shade700),
          children: [
            TextSpan(text: "alreadyHaveAccountQuestion".tr),
            TextSpan(
              text: "loginAction".tr,
              style: const TextStyle(color: _accentGreen, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
