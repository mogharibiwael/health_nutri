import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/shared/widgets/drawer.dart';
import '../../../core/class/status_request.dart';
import '../../../core/constant/theme/colors.dart';
import '../../../core/shared/widgets/app_bar.dart';
import '../controller/medical_tests_controller.dart';
import '../model/medical_test_model.dart';

class MedicalTestsPage extends GetView<MedicalTestsController> {
  const MedicalTestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<MedicalTestsController>();
    return Obx(() => SafeArea(
          child: Scaffold(
            drawer: HomeDrawer(controller: c),
            backgroundColor: Colors.grey.shade100,
            appBar: CustomAppBar(
              title: "medicalExaminations".tr,
              subtitle: c.isDoctor && c.selectedPatientName.isNotEmpty
                  ? c.selectedPatientName
                  : null,
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
      ));
  }

  Widget _buildBody(MedicalTestsController c) {
    if (c.isDoctor && !c.patientsLoaded.value && c.selectedPatientUserId == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (c.isDoctor && c.selectedPatientUserId == null && c.statusRequest.value == StatusRequest.rateLimit) {
      return _EmptyState(
        icon: Icons.schedule_rounded,
        title: "tooManyRequests".tr,
        onRetry: c.refresh,
      );
    }

    if (c.isDoctor && c.selectedPatientUserId == null && c.patients.isEmpty) {
      return _EmptyState(
        icon: Icons.people_outline,
        title: "noPatients".tr,
        onRetry: c.refresh,
      );
    }

    if (c.isDoctor && c.selectedPatientUserId == null) {
      return _PatientSelector(c: c);
    }

    if (c.statusRequest.value == StatusRequest.loading && c.tests.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (c.statusRequest.value == StatusRequest.offlineFailure) {
      return _EmptyState(
        icon: Icons.wifi_off_rounded,
        title: "noInternet".tr,
        onRetry: c.refresh,
      );
    }

    if (c.statusRequest.value == StatusRequest.rateLimit) {
      return _EmptyState(
        icon: Icons.schedule_rounded,
        title: "tooManyRequests".tr,
        onRetry: c.refresh,
      );
    }

    if (c.statusRequest.value == StatusRequest.serverFailure ||
        c.statusRequest.value == StatusRequest.failure) {
      return _EmptyState(
        icon: Icons.error_outline_rounded,
        title: "serverError".tr,
        onRetry: c.refresh,
      );
    }

    if (c.tests.isEmpty) {
      return _EmptyState(
        icon: Icons.medical_services_outlined,
        title: "noMedicalTests".tr,
        onRetry: c.refresh,
      );
    }

    return RefreshIndicator(
      onRefresh: c.refresh,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: c.tests.length,
        itemBuilder: (context, index) {
          return _TestCard(
            test: c.tests[index],
            onDownload: () => c.downloadAndShow(c.tests[index]),
          );
        },
      ),
    );
  }
}

class _PatientSelector extends StatelessWidget {
  final MedicalTestsController c;

  const _PatientSelector({required this.c});

  @override
  Widget build(BuildContext context) {
    final isAr = Get.locale?.languageCode == 'ar';

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          "selectPatient".tr,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade800,
          ),
          textAlign: isAr ? TextAlign.right : TextAlign.left,
        ),
        const SizedBox(height: 12),
        ...c.patients.map((p) => _PatientTile(
              patient: p,
              onTap: () => c.selectPatient(p),
            )),
      ],
    );
  }
}

class _PatientTile extends StatelessWidget {
  final dynamic patient;
  final VoidCallback onTap;

  const _PatientTile({required this.patient, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final name = patient.fullname ?? patient.name ?? "-";
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColor.shadowColor.withOpacity(0.12),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColor.primary.withOpacity(0.2),
          child: Icon(Icons.person, color: AppColor.primary),
        ),
        title: Text(
          name,
          style: TextStyle(
            color: Colors.grey.shade800,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: Icon(Icons.chevron_right, color: Colors.grey.shade600),
        onTap: onTap,
      ),
    );
  }
}

class _TestCard extends StatelessWidget {
  final MedicalTestModel test;
  final VoidCallback onDownload;

  const _TestCard({required this.test, required this.onDownload});

  @override
  Widget build(BuildContext context) {
    final isAr = Get.locale?.languageCode == 'ar';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColor.shadowColor.withOpacity(0.12),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            if (!isAr)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      test.name,
                      style: TextStyle(
                        color: Colors.grey.shade800,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (test.createdAt != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        test.createdAt!,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            IconButton(
              onPressed: onDownload,
              icon: Icon(
                Icons.download_rounded,
                color: AppColor.primary,
                size: 28,
              ),
              tooltip: "download".tr,
            ),
            if (isAr)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      test.name,
                      style: TextStyle(
                        color: Colors.grey.shade800,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                    ),
                    if (test.createdAt != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        test.createdAt!,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.end,
                      ),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onRetry;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.primary,
              ),
              child: Text("retry".tr),
            ),
          ],
        ),
      ),
    );
  }
}
