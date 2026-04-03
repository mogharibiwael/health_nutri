import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/shared/widgets/drawer.dart';
import '../../../core/class/status_request.dart';
import '../../../core/constant/theme/colors.dart';
import '../../../core/permissions/permissions.dart';
import '../../../core/service/serviecs.dart';
import '../../../core/shared/widgets/app_bar.dart';
import '../controller/consultations_controller.dart';
import '../model/consultation_model.dart';

class ConsultationsPage extends GetView<ConsultationsController> {
  const ConsultationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ConsultationsController>(
      builder: (c) => SafeArea(
        child: Scaffold(
          drawer: HomeDrawer(controller: c),
          appBar: CustomAppBar(
            title: "consultations".tr,
            showBackButton: true,
            leading: Builder(
              builder: (ctx) => IconButton(
                icon: Icon(Icons.menu, color: AppColor.primary, size: 26),
                onPressed: () => Scaffold.of(ctx).openDrawer(),
              ),
            ),
          actions: [
            if (Permissions(Get.find<MyServices>()).canRequestConsultation)
              IconButton(
                icon: const Icon(Icons.add, color: AppColor.deepPurple),
                onPressed: () => _showRequestDialog(context, c),
              ),
          ],
        ),
        body: _buildBody(c),
      ),
    ));
  }

  Widget _buildBody(ConsultationsController c) {
    if (c.statusRequest == StatusRequest.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (c.statusRequest == StatusRequest.offlineFailure) {
      return _EmptyState(
        icon: Icons.wifi_off_rounded,
        title: "noInternet".tr,
        buttonText: "retry".tr,
        onRetry: c.refreshConsultations,
      );
    }

    if (c.statusRequest == StatusRequest.serverFailure ||
        c.statusRequest == StatusRequest.failure) {
      return _EmptyState(
        icon: Icons.error_outline_rounded,
        title: "serverError".tr,
        buttonText: "retry".tr,
        onRetry: c.refreshConsultations,
      );
    }

    if (c.consultations.isEmpty) {
      return _EmptyState(
        icon: Icons.event_note_outlined,
        title: "noConsultations".tr,
        buttonText: "refresh".tr,
        onRetry: c.refreshConsultations,
      );
    }

    return RefreshIndicator(
      onRefresh: c.refreshConsultations,
      child: NotificationListener<ScrollNotification>(
        onNotification: (n) {
          if (n.metrics.pixels >= n.metrics.maxScrollExtent - 200) {
            c.loadMore();
          }
          return false;
        },
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: c.consultations.length + (c.isLoadingMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index >= c.consultations.length) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _ConsultationCard(consultation: c.consultations[index]),
            );
          },
        ),
      ),
    );
  }

  void _showRequestDialog(BuildContext context, ConsultationsController c) {
    final doctorIdController = TextEditingController();
    final dateController = TextEditingController();
    final notesController = TextEditingController();
    String selectedType = "initial";

    Get.dialog(
      Dialog(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "requestConsultation".tr,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: doctorIdController,
                decoration: InputDecoration(
                  labelText: "doctorId".tr,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedType,
                decoration: InputDecoration(
                  labelText: "consultationType".tr,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: [
                  DropdownMenuItem(value: "initial", child: Text("initialConsultation".tr)),
                  DropdownMenuItem(value: "follow_up", child: Text("followUp".tr)),
                  DropdownMenuItem(value: "review", child: Text("review".tr)),
                ],
                onChanged: (v) => selectedType = v ?? "initial",
              ),
              const SizedBox(height: 12),
              TextField(
                controller: dateController,
                decoration: InputDecoration(
                  labelText: "scheduledDate".tr,
                  hintText: "2024-12-25 14:30:00",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: notesController,
                decoration: InputDecoration(
                  labelText: "notes".tr,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      child: Text("cancel".tr),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final doctorId = int.tryParse(doctorIdController.text);
                        if (doctorId == null || dateController.text.isEmpty) {
                          Get.snackbar("error".tr, "fillFields".tr);
                          return;
                        }
                        c.requestConsultation(
                          doctorId: doctorId,
                          consultationType: selectedType,
                          scheduledDate: dateController.text,
                          notes: notesController.text.isEmpty ? null : notesController.text,
                        );
                        Get.back();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.primary,
                      ),
                      child: Text("request".tr),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConsultationCard extends StatelessWidget {
  final ConsultationModel consultation;

  const _ConsultationCard({required this.consultation});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    consultation.doctorName ?? "Doctor #${consultation.doctorId}",
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColor.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    consultation.typeDisplay,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColor.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              "Date: ${consultation.scheduledDate}",
              style: TextStyle(color: Colors.grey.shade700),
            ),
            if (consultation.notes != null && consultation.notes!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                consultation.notes!,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
            ],
            if (consultation.status != null) ...[
              const SizedBox(height: 8),
              Text(
                "Status: ${consultation.status}",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String buttonText;
  final VoidCallback onRetry;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.buttonText,
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
              child: Text(buttonText),
            ),
          ],
        ),
      ),
    );
  }
}
