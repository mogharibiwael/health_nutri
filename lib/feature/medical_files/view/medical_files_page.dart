import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/shared/widgets/drawer.dart';
import '../../../core/class/status_request.dart';
import '../../../core/constant/theme/colors.dart';
import '../../../core/shared/widgets/app_bar.dart';
import '../controller/medical_files_controller.dart';
import '../model/medical_file_model.dart';

class MedicalFilesPage extends GetView<MedicalFilesController> {
  const MedicalFilesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<MedicalFilesController>();
    return Obx(() => SafeArea(
      child: Scaffold(
        drawer: HomeDrawer(controller: c),
        backgroundColor: Colors.grey.shade100,
        appBar: CustomAppBar(
          title: "helpFiles".tr,
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

  Widget _buildBody(MedicalFilesController c) {
    if (c.statusRequest.value == StatusRequest.loading && c.files.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (c.statusRequest.value == StatusRequest.failure ||
        c.statusRequest.value == StatusRequest.serverFailure) {
      return _EmptyState(
        icon: Icons.error_outline_rounded,
        title: "serverError".tr, // reused translation key for generic error
        onRetry: c.refresh,
      );
    }

    if (c.files.isEmpty) {
      return _EmptyState(
        icon: Icons.folder_open_outlined,
        title: "noHelpFiles".tr,
        onRetry: c.refresh,
      );
    }

    return RefreshIndicator(
      onRefresh: c.refresh,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: c.files.length,
        itemBuilder: (context, index) {
          return _FileCard(
            fileName: c.files[index].displayName,
            onDownload: () => c.downloadAndShow(c.files[index]),
          );
        },
      ),
    );
  }
}

class _FileCard extends StatelessWidget {
  final String fileName;
  final VoidCallback onDownload;

  const _FileCard({
    required this.fileName,
    required this.onDownload,
  });

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
                child: Text(
                  fileName,
                  style: TextStyle(
                    color: Colors.grey.shade800,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
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
                child: Text(
                  fileName,
                  style: TextStyle(
                    color: Colors.grey.shade800,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
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
