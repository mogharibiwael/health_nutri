import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constant/asset.dart';
import '../../../core/constant/theme/colors.dart';
import '../../../core/shared/widgets/app_bar.dart';

const Color _textPurple = AppColor.deepPurple;

const List<String> _teamNamesAr = [
  "سماء أحمد الهمداني",
  "صفاء محمد هاني",
  "صفية عبد الرحمن الشرفي",
  "هديل فؤاد السماوي",
  "ولاء احمد الصلاحي",
];

const List<String> _teamNamesEn = [
  "Samaa Ahmed Al-Hamdani",
  "Safaa Mohammed Hany",
  "Safia Abdul Rahman Al-Sharfi",
  "Hadeel Fouad Al-Samawi",
  "Walaa Ahmed Al-Salahi",
];

class TeamPage extends StatelessWidget {
  const TeamPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isAr = Get.locale?.languageCode == 'ar';
    final names = isAr ? _teamNamesAr : _teamNamesEn;

    return SafeArea(
      child: Scaffold(
        appBar: CustomAppBar(
          title: "team".tr,
          showBackButton: true,
          showLogo: true,
        ),
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            children: [
              const SizedBox(height: 24),
              _buildLogo(),
              const SizedBox(height: 40),
              ...names.map((name) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: _textPurple,
                      ),
                      textAlign: isAr ? TextAlign.right : TextAlign.left,
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Center(
      child: Container(
        width: 140,
        height: 140,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColor.shadowColor.withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipOval(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Image.asset(ImageAssets.logo, fit: BoxFit.contain),
          ),
        ),
      ),
    );
  }
}
