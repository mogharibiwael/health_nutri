import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../../core/constant/theme/colors.dart';
import '../../../core/constant/asset.dart';
import '../../../core/routes/app_route.dart';

/// شاشة الترحيب قبل تسجيل الدخول - تحتوي على الشعار والنص وثلاثة أزرار: خروج، إنشاء حساب، تسجيل دخول.

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});
  static const Color _deepPurple = AppColor.deepPurple;
  static const Color _mutedPurple = AppColor.mutedPurple;
  static const Color _secondary = AppColor.secondary;

  @override
  Widget build(BuildContext context) {
    final isAr = Get.locale?.languageCode == 'ar';
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 24),
          children: [
            const SizedBox(height: 32),
            // ─── Logo with container behind (rounded bottom) ───
            _buildLogo(),
            const SizedBox(height: 28),
            // ─── Welcome text panel ───
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildTextPanel(isAr),
            ),
            const SizedBox(height: 52),
            // ─── Buttons ───
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: _buildButtons(context),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildLogo() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
          bottomLeft: Radius.circular(90),
          bottomRight: Radius.circular(90),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColor.deepPurple.withOpacity(0.08),
            blurRadius: 4,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
      child: Image.asset(
        ImageAssets.logo,
        height: 200,
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildTextPanel(bool isAr) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      decoration: BoxDecoration(
        color: _mutedPurple,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(0),
          topRight: Radius.circular(50),
          bottomLeft: Radius.circular(50),
          bottomRight: Radius.circular(0),
        ),
        boxShadow: [
          BoxShadow(
            color: _secondary.withOpacity(0.5),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "welcomeTitle".tr,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: AppColor.accentGreen,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            "welcomeBody".tr,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              height: 1.6,
              fontWeight: FontWeight.bold,
              color: _secondary,
              shadows: [
                Shadow(
                  color: AppColor.deepPurple.withOpacity(0.3),
                  offset: const Offset(0, 2),
                  blurRadius: 1,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButtons(BuildContext context) {
    return Row(
      children: [
        const SizedBox(height: 150),
        _welcomeButton(
          label: "exit".tr,
          onTap: () {
            if (kIsWeb) return;
            SystemNavigator.pop();
          },
        ),
        const SizedBox(width: 6),
        _welcomeButton(
          label: "signup".tr,
          onTap: () => Get.offAllNamed(AppRoute.signUp),
        ),
        const SizedBox(width: 12),
        _welcomeButton(
          label: "login".tr,
          onTap: () => Get.offAllNamed(AppRoute.login),
        ),
      ],
    );
  }

  Widget _welcomeButton({required String label, required VoidCallback onTap}) {
    return Expanded(
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: _secondary.withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: _mutedPurple,
          borderRadius: BorderRadius.circular(12),
          elevation: 0,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              alignment: Alignment.center,
              child: Text(
                label,
                style:  const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: _secondary,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
