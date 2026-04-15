import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
    final myServices = Get.find<nutri_guide_services.MyServices>();
    final isDoctor = myServices.isDoctor || myServices.isAdmin;

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
                _buildProfileAvatar(c, isDoctor: isDoctor),
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

  Widget _buildProfileAvatar(EditProfileController c, {required bool isDoctor}) {
    final myServices = Get.find<nutri_guide_services.MyServices>();
    final imgUrl = myServices.profileImageUrl;
    final picked = c.profileImageBytes;

    return Center(
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          CircleAvatar(
            radius: 60,
            backgroundColor: Colors.white,
            child: CircleAvatar(
              radius: 56,
              backgroundColor: isDoctor
                  ? Colors.grey.shade100
                  : AppColor.primary.withOpacity(0.12),
              backgroundImage: picked != null
                  ? MemoryImage(picked)
                  : (imgUrl != null ? NetworkImage(imgUrl) : null) as ImageProvider<Object>?,
              child: (picked == null && imgUrl == null)
                  ? Icon(
                      isDoctor ? Icons.medical_services_outlined : Icons.person_outline,
                      size: 50,
                      color: isDoctor ? Colors.grey.shade700 : AppColor.primary,
                    )
                  : null,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (picked != null) ...[
                GestureDetector(
                  onTap: c.removePickedImage,
                  child: Container(
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.55),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(Icons.close, color: Colors.white, size: 18),
                  ),
                ),
              ],
              GestureDetector(
                onTap: c.pickProfileImageFromGallery,
                child: Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: AppColor.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(Icons.photo_library_outlined, color: Colors.white, size: 18),
                ),
              ),
            ],
          ),
        ],
      ),
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
