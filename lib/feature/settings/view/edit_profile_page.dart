import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constant/asset.dart';
import '../../../core/constant/theme/colors.dart';
import '../../../core/shared/widgets/app_bar.dart';
import '../../../core/service/serviecs.dart' as nutri_guide_services;
import '../controller/edit_profile_controller.dart';

const Color _fieldBg = AppColor.customGrey;
const Color _textPurple = AppColor.deepPurple;

class EditProfilePage extends GetView<EditProfileController> {
  const EditProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final isAr = Get.locale?.languageCode == 'ar';

    return SafeArea(
      child: Scaffold(
        appBar: CustomAppBar(
          title: "editProfile".tr,
          showBackButton: true,
          showLogo: false,
        ),
        backgroundColor: Colors.white,
        body: GetBuilder<EditProfileController>(
          builder: (c) => SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              children: [
                const SizedBox(height: 16),
                _buildProfileLogo(),
                const SizedBox(height: 32),
                _buildField(
                  controller: c.nameController,
                  hint: "enterName".tr,
                  icon: Icons.person_outline,
                  isAr: isAr,
                ),
                const SizedBox(height: 16),
                _buildField(
                  controller: c.emailController,
                  hint: "enterPersonalEmail".tr,
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  isAr: isAr,
                ),
                const SizedBox(height: 16),
                _buildField(
                  controller: c.passwordController,
                  hint: "enterPassword".tr,
                  icon: Icons.lock_outline,
                  obscureText: c.isPasswordHidden,
                  suffix: IconButton(
                    icon: Icon(
                      c.isPasswordHidden ? Icons.visibility_off : Icons.visibility,
                      color: _textPurple.withOpacity(0.6),
                      size: 22,
                    ),
                    onPressed: c.togglePassword,
                  ),
                  isAr: isAr,
                ),
                const SizedBox(height: 16),
                _buildField(
                  controller: c.confirmPasswordController,
                  hint: "confirmPasswordHint".tr,
                  icon: Icons.lock_outline,
                  obscureText: c.isConfirmPasswordHidden,
                  suffix: IconButton(
                    icon: Icon(
                      c.isConfirmPasswordHidden ? Icons.visibility_off : Icons.visibility,
                      color: _textPurple.withOpacity(0.6),
                      size: 22,
                    ),
                    onPressed: c.toggleConfirmPassword,
                  ),
                  isAr: isAr,
                ),
                const SizedBox(height: 36),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: c.isLoading ? null : c.save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: c.isLoading
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Text("edit".tr, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileLogo() {
    final myServices = Get.find<nutri_guide_services.MyServices>();
    final imgUrl = myServices.profileImageUrl;

    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColor.shadowColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        image: imgUrl != null ? DecorationImage(
          image: NetworkImage(imgUrl),
          fit: BoxFit.cover,
        ) : null,
      ),
      child: imgUrl == null ? ClipOval(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Image.asset(ImageAssets.logo, fit: BoxFit.contain),
        ),
      ) : null,
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffix,
    required bool isAr,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: _fieldBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColor.shadowColor.withOpacity(0.25),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: const TextStyle(color: _textPurple, fontSize: 16),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: _textPurple.withOpacity(0.5)),
          prefixIcon: Icon(icon, color: _textPurple, size: 22),
          suffixIcon: suffix,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
}
