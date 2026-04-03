import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/shared/widgets/drawer.dart';
import '../../../core/class/status_request.dart';
import '../../../core/constant/theme/colors.dart';
import '../../../core/shared/widgets/app_bar.dart';
import '../controller/tips_controller.dart';

class TipsPage extends GetView<TipsController> {
  const TipsPage({super.key});

  static const Color _lightGrey = AppColor.mutedPurple;
  static const Color _darkPurple = AppColor.deepPurple;

  @override
  Widget build(BuildContext context) {
    final args = (Get.arguments as Map?) ?? {};
    final categoryName = (args["categoryName"] ?? "tips".tr).toString();
    return GetBuilder<TipsController>(
      builder: (c) => SafeArea(
        child: Scaffold(
          drawer: HomeDrawer(controller: c),
          appBar: CustomAppBar(
            title: categoryName,
            showBackButton: true,
            leading: Builder(
              builder: (ctx) => IconButton(
                icon: Icon(Icons.menu, color: AppColor.primary, size: 26),
                onPressed: () => Scaffold.of(ctx).openDrawer(),
              ),
            ),
          ),
          backgroundColor: Colors.white,
          body: _buildBody(c, categoryName),
        ),
      ),
    );
  }

  Widget _buildBody(TipsController c, String categoryName) {
    if (c.statusRequest == StatusRequest.loading) {
      return  Center(child: CircularProgressIndicator(color: AppColor.primary));
    }

    if (c.statusRequest == StatusRequest.offlineFailure) {
      return _StateView(
        title: "noInternet".tr,
        buttonText: "retry".tr,
        onRetry: c.fetchFirstPage,
      );
    }

    if (c.statusRequest == StatusRequest.serverFailure ||
        c.statusRequest == StatusRequest.failure) {
      return _StateView(
        title: "serverError".tr,
        buttonText: "retry".tr,
        onRetry: c.fetchFirstPage,
      );
    }

    if (c.tips.isEmpty) {
      return _StateView(
        title: "noTipsFound".tr,
        buttonText: "refresh".tr,
        onRetry: c.refreshTips,
      );
    }

    return RefreshIndicator(
      onRefresh: c.refreshTips,
      color: AppColor.primary,
      child: NotificationListener<ScrollNotification>(
        onNotification: (n) {
          if (n.metrics.pixels >= n.metrics.maxScrollExtent - 200) {
            c.loadMore();
          }
          return false;
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            // Category header - dark purple pill
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColor.primary,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: AppColor.primary.withOpacity(0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      categoryName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),

              ),
            ),
            const SizedBox(height: 24),
            // Tip cards
            ...List.generate(
              c.tips.length + (c.isLoadingMore ? 1 : 0),
              (index) {
                if (index >= c.tips.length) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Center(
                      child: SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColor.primary,
                        ),
                      ),
                    ),
                  );
                }
                final tip = c.tips[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _TipCard(text: tip.describtion),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  final String text;

  const _TipCard({required this.text});

  static const Color _darkPurple = AppColor.deepPurple;

  @override
  Widget build(BuildContext context) {
    final isAr = Get.locale?.languageCode == 'ar';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColor.shadowColor.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Text(
        text,
        textAlign: isAr ? TextAlign.right : TextAlign.left,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: _darkPurple,
          height: 1.45,
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
            Text(title, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onRetry,
                child: Text(buttonText),
              ),
            )
          ],
        ),
      ),
    );
  }
}
