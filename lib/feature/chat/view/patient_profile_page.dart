import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nutri_guide/core/class/status_request.dart';
import 'package:nutri_guide/core/constant/theme/colors.dart';
import 'package:nutri_guide/core/shared/widgets/app_bar.dart';
import '../controller/patient_profile_controller.dart';

class PatientProfilePage extends GetView<PatientProfileController> {


  const PatientProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PatientProfileController>(
      builder: (c) => SafeArea(
        child: Scaffold(
        appBar: CustomAppBar(
          title: "completeProfile".tr,
          showBackButton: true,
        ),
        body: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _SectionTitle("gender".tr),
                const SizedBox(height: 6),

                Row(
                  children: [
                    Expanded(
                      child: _ChoiceChip(
                        text: "male".tr,
                        selected: c.gender == "male",
                        onTap: () => c.setGender("male"),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _ChoiceChip(
                        text: "female".tr,
                        selected: c.gender == "female",
                        onTap: () => c.setGender("female"),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                _SectionTitle("dateOfBirth".tr),
                const SizedBox(height: 6),

                TextField(
                  controller: c.dobController,
                  readOnly: true,
                  onTap: () => c.pickDob(context),
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    hintText: "YYYY-MM-DD",
                    prefixIcon: const Icon(Icons.calendar_today_outlined),
                  ),
                ),

                const SizedBox(height: 14),

                _SectionTitle("heightCm".tr),
                const SizedBox(height: 6),

                TextField(
                  controller: c.heightController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.height),
                  ),
                ),

                const SizedBox(height: 14),

                _SectionTitle("weightKg".tr),
                const SizedBox(height: 6),

                TextField(
                  controller: c.weightController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.monitor_weight_outlined),
                  ),
                ),

                const SizedBox(height: 14),

                _SectionTitle("physicalActivity".tr),
                const SizedBox(height: 6),

                DropdownButtonFormField<String>(
                  value: c.physicalActivity,
                  items: [
                    DropdownMenuItem(value: "sedentary", child: Text("sedentary".tr,style: TextStyle(color: AppColor.textColor),)),
                    DropdownMenuItem(value: "low", child: Text("low".tr,style: TextStyle(color: AppColor.textColor))),
                    DropdownMenuItem(value: "active", child: Text("active".tr,style: TextStyle(color: AppColor.textColor))),
                    DropdownMenuItem(value: "very_active", child: Text("veryActive".tr,style: TextStyle(color: AppColor.textColor))),
                  ],
                  onChanged: (v) {
                    if (v != null) c.setActivity(v);
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 14),

                _SectionTitle("medicalHistory".tr),
                const SizedBox(height: 6),

                TextField(
                  controller: c.medicalHistoryController,
                  minLines: 2,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 18),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: c.statusRequest == StatusRequest.loading ? null : c.save,
                    child: Text("save".tr),
                  ),
                ),
              ],
            ),

            if (c.statusRequest == StatusRequest.loading)
              const Positioned.fill(
                child: ColoredBox(
                  color: Color(0x33000000),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
          ],
        ),
      ),
    ));
  }
}


class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700));
  }
}

class _ChoiceChip extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;

  const _ChoiceChip({
    required this.text,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? AppColor.primary : Colors.grey.shade300, width: selected ? 1.6 : 1),
          color: selected ? AppColor.primary.withOpacity(0.08) : null,
        ),
        child: Center(
          child: Text(text, style: TextStyle(fontWeight: FontWeight.w700, color: selected ? AppColor.primary : null)),
        ),
      ),
    );
  }
}
