import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/shared/widgets/drawer.dart';
import '../../../core/class/status_request.dart';
import '../../../core/constant/theme/colors.dart';
import '../../../core/shared/widgets/app_bar.dart';
import '../controller/doctors_controller.dart';
import '../model/doctor_model.dart';

class DoctorsPage extends GetView<DoctorsController> {
  const DoctorsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DoctorsController>(
      builder: (c) => SafeArea(
          child: Scaffold(
            drawer: HomeDrawer(controller: c),
            backgroundColor: Colors.grey.shade100,
            appBar: CustomAppBar(
              title: "doctorsList".tr,
              showBackButton: true,
              showLogo: true,
              leading: Builder(
                builder: (ctx) => IconButton(
                  icon: Icon(Icons.menu, color: AppColor.primary, size: 26),
                  onPressed: () => Scaffold.of(ctx).openDrawer(),
                ),
              ),
            ),
          body: _buildBody(c),
        ),
      ),
    );
  }

  Widget _buildBody(DoctorsController c) {
    if (c.statusRequest == StatusRequest.loading) {
      return  Center(
        child: CircularProgressIndicator(color: AppColor.primary),
      );
    }

    if (c.statusRequest == StatusRequest.offlineFailure) {
      return _StateView(
        title: "noInternet".tr,
        buttonText: "retry".tr,
        onRetry: c.fetchDoctors,
      );
    }

    if (c.statusRequest == StatusRequest.serverFailure ||
        c.statusRequest == StatusRequest.failure) {
      return _StateView(
        title: "serverError".tr,
        buttonText: "retry".tr,
        onRetry: c.fetchDoctors,
      );
    }

    if (c.doctors.isEmpty) {
      return _StateView(
        title: "noDoctors".tr,
        buttonText: "refresh".tr,
        onRetry: c.refreshDoctors,
      );
    }

    return RefreshIndicator(
      onRefresh: c.refreshDoctors,
      color: AppColor.primary,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        itemCount: c.doctors.length,
        separatorBuilder: (_, __) => const SizedBox(height: 14),
        itemBuilder: (context, index) {
          final d = c.doctors[index];
          return _DoctorCard(
            doctor: d,
            onTap: () => Get.toNamed("/doctor-details", arguments: d),
          );
        },
      ),
    );
  }
}

String _doctorDisplayName(String name, bool isAr) {
  if (name.startsWith("د.") || name.startsWith("Dr.")) return name;
  return isAr ? "د. $name" : "Dr. $name";
}

class _DoctorCard extends StatelessWidget {
  final DoctorModel doctor;
  final VoidCallback onTap;

  const _DoctorCard({
    required this.doctor,
    required this.onTap,
  });

  static const Color _cardBg = Colors.white;
  static const Color _nameColor = AppColor.deepPurple;

  @override
  Widget build(BuildContext context) {
    final isAr = Get.locale?.languageCode == 'ar';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: _cardBg,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: AppColor.primary.withOpacity(0.25),
                blurRadius: 20,
                offset: const Offset(4, 6),
                spreadRadius: 0,
              ),
              BoxShadow(
                color: AppColor.primary.withOpacity(0.12),
                blurRadius: 12,
                offset: const Offset(0, 4),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            textDirection: isAr ? TextDirection.ltr : TextDirection.rtl,
            children: [
              Expanded(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: isAr ? MainAxisAlignment.start : MainAxisAlignment.end,
                  children: [
                    Flexible(
                      child: Text(
                        _doctorDisplayName(doctor.name, isAr),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: _nameColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        textAlign: isAr ? TextAlign.right : TextAlign.left,
                      ),
                    ),
                    if (doctor.isVerified) ...[
                      const SizedBox(width: 6),
                      Icon(Icons.verified_rounded, size: 20, color: AppColor.primary),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.asset(
                  doctor.avatarAsset,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StateView extends StatelessWidget {
  final String title;
  final String buttonText;
  final VoidCallback onRetry;

  const _StateView({
    required this.title,
    required this.buttonText,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(buttonText),
              ),
            )
          ],
        ),
      ),
    );
  }
}
