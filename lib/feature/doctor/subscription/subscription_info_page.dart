import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nutri_guide/feature/doctor/subscription/subscription_info_controller.dart';
import '../../../core/constant/theme/colors.dart';
import '../../../core/shared/widgets/app_bar.dart';

class SubscriptionInfoPage extends GetView<SubscriptionInfoController> {
  const SubscriptionInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = controller;
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey.shade200,
        appBar: CustomAppBar(
          title: "subscriptionInfo".tr,
          showBackButton: true,
          showLogo: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: c.formKey,
            child: GetBuilder<SubscriptionInfoController>(
              builder: (c) => c.isSubscribed && !c.isApproved
                  ? _buildPendingUI()
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          "enterYourInfo".tr,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: c.fullNameController,
                          decoration: InputDecoration(
                            labelText: "fullName".tr,
                            hintText: "enterName".tr,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade300,
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty) ? "fillFields".tr : null,
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: c.phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            labelText: "phone".tr,
                            hintText: "enterPhone".tr,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade300,
                          ),
                        ),
                        const SizedBox(height: 14),
                        GetBuilder<SubscriptionInfoController>(
                          builder: (_) => InkWell(
                            onTap: c.pickDate,
                            child: InputDecorator(
                              decoration: InputDecoration(
                                labelText: "selectDateOfBirth".tr,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade300,
                                suffixIcon: const Icon(Icons.calendar_today_outlined),
                              ),
                              child: Text(
                                c.dateOfBirthText.isEmpty ? "12-06-1990" : c.dateOfBirthText,
                                style: TextStyle(
                                  color: c.dateOfBirthText.isEmpty ? Colors.grey : const Color(0xDD2A0126),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: GetBuilder<SubscriptionInfoController>(
                                builder: (_) => InkWell(
                                  onTap: c.pickHeight,
                                  child: InputDecorator(
                                    decoration: InputDecoration(
                                      labelText: "selectHeight".tr,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      filled: true,
                                      fillColor: Colors.grey.shade300,
                                      suffixIcon: const Icon(Icons.height_outlined),
                                    ),
                                    child: Text(
                                      c.heightText.isEmpty ? "170 cm" : c.heightText,
                                      style: TextStyle(
                                        color: c.heightText.isEmpty ? Colors.grey : const Color(0xDD2A0126),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: GetBuilder<SubscriptionInfoController>(
                                builder: (_) => InkWell(
                                  onTap: c.pickWeight,
                                  child: InputDecorator(
                                    decoration: InputDecoration(
                                      labelText: "selectWeight".tr,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      filled: true,
                                      fillColor: Colors.grey.shade300,
                                      suffixIcon: const Icon(Icons.monitor_weight_outlined),
                                    ),
                                    child: Text(
                                      c.weightText.isEmpty ? "70 kg" : c.weightText,
                                      style: TextStyle(
                                        color: c.weightText.isEmpty ? Colors.grey : const Color(0xDD2A0126),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Text(
                          "gender".tr,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        GetBuilder<SubscriptionInfoController>(
                          builder: (_) => Row(
                            children: [
                              Expanded(
                                child: _RadioTile<SubscriptionGender>(
                                  value: SubscriptionGender.male,
                                  groupValue: c.gender,
                                  label: "male".tr,
                                  onChanged: c.setGender,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _RadioTile<SubscriptionGender>(
                                  value: SubscriptionGender.female,
                                  groupValue: c.gender,
                                  label: "female".tr,
                                  onChanged: c.setGender,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          "physicalActivity".tr,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        GetBuilder<SubscriptionInfoController>(
                          builder: (_) => Column(
                            children: [
                              _ActivityRadio(
                                value: SubscriptionActivity.sedentary,
                                groupValue: c.activity,
                                label: "activitySedentaryLong".tr,
                                onChanged: c.setActivity,
                              ),
                              _ActivityRadio(
                                value: SubscriptionActivity.light,
                                groupValue: c.activity,
                                label: "activityLightLong".tr,
                                onChanged: c.setActivity,
                              ),
                              _ActivityRadio(
                                value: SubscriptionActivity.moderate,
                                groupValue: c.activity,
                                label: "activityModerateLong".tr,
                                onChanged: c.setActivity,
                              ),
                              _ActivityRadio(
                                value: SubscriptionActivity.active,
                                groupValue: c.activity,
                                label: "activityActiveLong".tr,
                                onChanged: c.setActivity,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),
                        SizedBox(
                          height: 52,
                          child: ElevatedButton(
                            onPressed: c.goToPaymentInvoice,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColor.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: Text("next".tr),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPendingUI() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 40),
        Icon(
          Icons.hourglass_empty_rounded,
          size: 80,
          color: AppColor.primary,
        ),
        const SizedBox(height: 24),
        Text(
          "waitingForApproval".tr,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColor.primary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          "subscription_sent_pending_approval".tr,
          style: TextStyle(
            fontSize: 15,
            color: Colors.grey.shade700,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40),
      ],
    );
  }
}

class _RadioTile<T> extends StatelessWidget {
  final T value;
  final T groupValue;
  final String label;
  final ValueChanged<T> onChanged;

  const _RadioTile({
    required this.value,
    required this.groupValue,
    required this.label,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(value),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: value == groupValue
                ? AppColor.primary
                : Colors.grey.shade400,
            width: value == groupValue ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Radio<T>(
              value: value,
              groupValue: groupValue,
              onChanged: (_) => onChanged(value),
              activeColor: AppColor.primary,
            ),
            Expanded(child: Text(label, style: const TextStyle(fontSize: 14))),
          ],
        ),
      ),
    );
  }
}

class _ActivityRadio extends StatelessWidget {
  final SubscriptionActivity value;
  final SubscriptionActivity groupValue;
  final String label;
  final ValueChanged<SubscriptionActivity> onChanged;

  const _ActivityRadio({
    required this.value,
    required this.groupValue,
    required this.label,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => onChanged(value),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: value == groupValue
                  ? AppColor.primary
                  : Colors.grey.shade400,
              width: value == groupValue ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Radio<SubscriptionActivity>(
                value: value,
                groupValue: groupValue,
                onChanged: (_) => onChanged(value),
                activeColor: AppColor.primary,
              ),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
