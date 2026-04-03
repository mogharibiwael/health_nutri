import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/shared/widgets/drawer.dart';
import '../../../core/constant/theme/colors.dart';
import '../../../core/localization/controller.dart';
import '../../../core/shared/widgets/app_bar.dart';
import '../controller/settings_controller.dart';

const Color _textPurple = AppColor.deepPurple;

class SettingsPage extends GetView<SettingsController> {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isAr = Get.locale?.languageCode == 'ar';

    return SafeArea(
      child: Scaffold(
        drawer: HomeDrawer(controller: controller),
        appBar: CustomAppBar(
          title: "settings".tr,
          showBackButton: true,
          showLogo: true,
          leading: Builder(
            builder: (ctx) => IconButton(
              icon: Icon(Icons.menu, color: AppColor.primary, size: 26),
              onPressed: () => Scaffold.of(ctx).openDrawer(),
            ),
          ),
        ),
        backgroundColor: Colors.white,
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _SettingsCard(
                icon: Icons.person_outline,
                label: "personalAccount".tr,
                onTap: controller.goPersonalAccount,
                isAr: isAr,
              ),
              const SizedBox(height: 14),
              _SettingsCard(
                icon: Icons.alarm_outlined,
                label: "remindersAlerts".tr,
                onTap: controller.goRemindersAlerts,
                isAr: isAr,
              ),
              const SizedBox(height: 14),
              _SettingsCard(
                icon: Icons.groups_outlined,
                label: "team".tr,
                onTap: controller.goTeam,
                isAr: isAr,
              ),
              const SizedBox(height: 14),
              _LanguageCard(isAr: isAr),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageCard extends StatelessWidget {
  final bool isAr;

  const _LanguageCard({required this.isAr});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LocalController>(
      builder: (lc) {
        return Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          elevation: 0,
          shadowColor: AppColor.shadowColor,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColor.shadowColor.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (!isAr) Icon(Icons.language, color: _textPurple, size: 26),
                    if (!isAr) const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        "language".tr,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: _textPurple,
                        ),
                        textAlign: isAr ? TextAlign.right : TextAlign.left,
                      ),
                    ),
                    if (isAr) const SizedBox(width: 16),
                    if (isAr) Icon(Icons.language, color: _textPurple, size: 26),
                  ],
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 12,
                  runSpacing: 10,
                  children: [
                    _LangChip(code: "ar", label: "العربية", lc: lc),
                    _LangChip(code: "en", label: "English", lc: lc),
                  ],
                ),

              ],
            ),
          ),
        );
      },
    );
  }
}

class _LangChip extends StatelessWidget {
  final String code;
  final String label;
  final LocalController lc;

  const _LangChip({required this.code, required this.label, required this.lc});

  @override
  Widget build(BuildContext context) {
    final isSelected = lc.language.languageCode == code;
    return Material(
      color: isSelected ? AppColor.primary.withOpacity(0.15) : Colors.grey.shade100,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => lc.changeLang(code),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected ? AppColor.primary : Colors.grey.shade700,
            ),
          ),
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isAr;

  const _SettingsCard({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.isAr,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 0,
      shadowColor: AppColor.shadowColor,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColor.shadowColor.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              if (!isAr) Icon(icon, color: _textPurple, size: 26),
              if (!isAr) const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: _textPurple,
                  ),
                  textAlign: isAr ? TextAlign.right : TextAlign.left,
                ),
              ),
              if (isAr) const SizedBox(width: 16),
              if (isAr) Icon(icon, color: _textPurple, size: 26),
              const SizedBox(width: 8),
              Icon(
                isAr ? Icons.arrow_back_ios : Icons.arrow_forward_ios,
                size: 18,
                color: _textPurple.withOpacity(0.6),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
