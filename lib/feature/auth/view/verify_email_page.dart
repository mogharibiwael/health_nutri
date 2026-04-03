import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/class/status_request.dart';
import '../../../core/constant/theme/colors.dart';
import '../../../core/shared/widgets/app_bar.dart';
import '../controller/verify_email_controller.dart';

class VerifyEmailPage extends GetView<VerifyEmailController> {
  const VerifyEmailPage({super.key});

  static const Color _lightLavender = Color(0xffe4e0ec);
  static const Color _darkPurpleText = AppColor.deepPurple;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: "verifyEmailTitle".tr,
        showBackButton: true,
        onBack: () => controller.goBack(),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          children: [
            const SizedBox(height: 24),
            // ─── Email input (when not passed as argument) ───
            GetBuilder<VerifyEmailController>(
              builder: (c) {
                if (!c.hasEmailArgument) {
                  return Column(
                    children: [
                      _buildEmailField(c),
                      const SizedBox(height: 16),
                    ],
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            // ─── Verification code input ───
            GetBuilder<VerifyEmailController>(
              builder: (c) => _buildCodeField(c),
            ),
            const SizedBox(height: 16),
            // ─── "Verification code has been sent to" ───
            GetBuilder<VerifyEmailController>(
              builder: (c) => _buildSentToText(c),
            ),
            const SizedBox(height: 12),
            // ─── Resend code link ───
            GetBuilder<VerifyEmailController>(
              builder: (c) => _buildResendLink(c),
            ),
            const SizedBox(height: 28),
            // ─── Buttons ───
            GetBuilder<VerifyEmailController>(
              builder: (c) => _buildButtons(c),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }


  Widget _buildEmailField(VerifyEmailController c) {
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
        controller: c.emailController,
        keyboardType: TextInputType.emailAddress,
        style: const TextStyle(color: _darkPurpleText),
        decoration: InputDecoration(
          hintText: "enterPersonalEmail".tr,
          hintStyle: TextStyle(color: Colors.grey.shade600, fontSize: 16),
          prefixIcon: Icon(Icons.email_outlined, color: AppColor.textColor, size: 22),
          border: InputBorder.none,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
      ),
    );
  }

  Widget _buildCodeField(VerifyEmailController c) {
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
        controller: c.codeController,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        style: const TextStyle(color: _darkPurpleText),
        decoration: InputDecoration(
          hintText: "verificationCode".tr,
          hintStyle: TextStyle(color: Colors.grey.shade600, fontSize: 16),
          border: InputBorder.none,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
      ),
    );
  }

  Widget _buildSentToText(VerifyEmailController c) {
    final email = c.email;
    return Column(
      children: [
        Text(
          "verificationCodeSentTo".tr,
          style: const TextStyle(
            fontSize: 15,
            color: _darkPurpleText,
          ),
          textAlign: TextAlign.center,
        ),
        if (email.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            email,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: _darkPurpleText,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  Widget _buildResendLink(VerifyEmailController c) {
    if (c.email.isEmpty) return const SizedBox.shrink();
    final isLoading = c.statusRequest == StatusRequest.loading;
    return GestureDetector(
      onTap: isLoading ? null : c.resendCode,
      child: Text(
        "resendCode".tr,
        style: TextStyle(
          fontSize: 14,
          color: isLoading ? Colors.grey : AppColor.primary,
          fontWeight: FontWeight.w600,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }

  Widget _buildButtons(VerifyEmailController c) {
    final isLoading = c.statusRequest == StatusRequest.loading;
    return Row(
      children: [
        Expanded(
          child: _buildButton(
            label: "verify".tr,
            onTap: isLoading ? null : c.verify,
            isLoading: isLoading,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildButton(
            label: "goBack".tr,
            onTap: isLoading ? null : c.goBack,
          ),
        ),
      ],
    );
  }

  Widget _buildButton({
    required String label,
    required VoidCallback? onTap,
    bool isLoading = false,
  }) {
    return Material(
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
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }
}
