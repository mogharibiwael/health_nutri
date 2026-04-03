import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/class/status_request.dart';
import '../../../core/shared/widgets/app_bar.dart';
import '../../../core/shared/widgets/global_button.dart';
import '../../../core/shared/widgets/text_form_field.dart';
import '../controller/forget_password_controller.dart';

class ForgotPasswordPage extends GetView<ForgotPasswordController> {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "forgotPasswordTitle".tr,
        showBackButton: true,
        onBack: () => Navigator.of(context).pop(),
      ),
      body: GetBuilder<ForgotPasswordController>(
        builder: (c) => ListView(
          padding: const EdgeInsets.all(24.0),
          children: [
            const SizedBox(height: 48),
            CustomTextFormField(
              controller: c.emailController,
              label: "email".tr,
              hintText: "enterYourEmail".tr,
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              obscureText: false,
            ),
            const SizedBox(height: 24),
            GlobalButton(
              textButton: c.statusRequest == StatusRequest.loading
                  ? "pleaseWait".tr
                  : "sendResetLink".tr,
              onPress: c.statusRequest == StatusRequest.loading ? null : c.send,
            ),
            const SizedBox(height: 12),
            if (c.statusRequest == StatusRequest.loading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }

}
