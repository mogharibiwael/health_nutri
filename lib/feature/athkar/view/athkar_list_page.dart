import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/class/status_request.dart';
import '../../../core/constant/theme/colors.dart';
import '../../../core/shared/widgets/app_bar.dart';
import '../controller/athkar_list_controller.dart';
import '../model/athkar_model.dart';

const Color _textPurple = AppColor.deepPurple;
const Color _textPurpleLight = Color(0xff6a5a7a);

class AthkarListPage extends GetView<AthkarListController> {
  const AthkarListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isAr = Get.locale?.languageCode == 'ar';

    return SafeArea(
      child: Scaffold(
        appBar: CustomAppBar(
          title: controller.pageTitle,
          showBackButton: true,
          showLogo: true,
        ),
        backgroundColor: Colors.white,
        body: Obx(() {
          final c = controller;
          final status = c.statusRequest.value;
          if (status == StatusRequest.loading) {
            return Center(child: CircularProgressIndicator(color: AppColor.primary));
          }
          if (status == StatusRequest.offlineFailure) {
            return _StateView(
              title: "noInternet".tr,
              onRetry: c.refresh,
            );
          }
          if (status == StatusRequest.serverFailure ||
              status == StatusRequest.failure) {
            return _StateView(
              title: "serverError".tr,
              onRetry: c.refresh,
            );
          }
          if (c.athkarList.isEmpty) {
            return _StateView(
              title: "noAthkarFound".tr,
              onRetry: c.refresh,
            );
          }
          return RefreshIndicator(
            onRefresh: c.refresh,
            color: AppColor.primary,
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: c.athkarList.length,
              itemBuilder: (context, i) => Padding(
                padding: EdgeInsets.only(bottom: i < c.athkarList.length - 1 ? 16 : 0),
                child: _AthkarCard(
                  athkar: c.athkarList[i],
                  isAr: isAr,
                  index: i,
                  controller: c,
                ),

              ),
            ),
          );
        }),
      ),
    );
  }
}

class _AthkarCard extends StatelessWidget {
  final AthkarModel athkar;
  final bool isAr;
  final int index;
  final AthkarListController controller;

  _AthkarCard({required this.athkar, required this.isAr, required this.index, required this.controller});


  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final count = controller.currentCounts[index] ?? 0;
      final isDone = count == 0;
      
      return Material(
        color: isDone ? Colors.grey.shade100 : Colors.white,
        borderRadius: BorderRadius.circular(18),
        elevation: isDone ? 0 : 3,
        shadowColor: AppColor.shadowColor.withOpacity(0.3),
        child: InkWell(
          onTap: () => controller.decrement(index),
          borderRadius: BorderRadius.circular(18),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isDone ? Colors.grey.shade300 : Colors.transparent,
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: isAr ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Text(
                  athkar.content,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isDone ? Colors.grey : _textPurple,
                    height: 1.8,
                    decoration: isDone ? TextDecoration.lineThrough : null,
                  ),
                  textAlign: isAr ? TextAlign.right : TextAlign.left,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (isAr) _buildResetButton() else _buildCounterIndicator(count, isDone),
                    if (isAr) _buildCounterIndicator(count, isDone) else _buildResetButton(),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildCounterIndicator(int count, bool isDone) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isDone ? Colors.grey.shade300 : AppColor.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isDone ? (Get.locale?.languageCode == 'ar' ? "تم" : "Done") : "$count",
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: isDone ? Colors.grey.shade700 : AppColor.primary,
        ),
      ),
    );
  }

  Widget _buildResetButton() {
    return IconButton(
      icon: const Icon(Icons.refresh, size: 20),
      onPressed: () => controller.reset(index),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      color: Colors.grey.shade400,
    );
  }

  String _repetitionText(int n) {

    if (Get.locale?.languageCode == 'ar') {
      if (n == 3) return "ثلاث مرات";
      if (n == 7) return "سبع مرات";
      if (n == 10) return "عشر مرات";
      return "$n مرات";
    }
    return "$n times";
  }
}

class _StateView extends StatelessWidget {
  final String title;
  final VoidCallback onRetry;

  const _StateView({required this.title, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onRetry,
                child: Text("retry".tr),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
