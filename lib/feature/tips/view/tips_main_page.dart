import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constant/theme/colors.dart';
import '../../../core/class/status_request.dart';
import '../../../core/constant/asset.dart';
import '../../../core/shared/widgets/app_bar.dart';
import '../controller/tips_main_controller.dart';
import '../model/tips.dart';

class TipsMainPage extends GetView<TipsMainController> {
  const TipsMainPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isAr = Get.locale?.languageCode == 'ar';

    return SafeArea(
      child: Scaffold(
        appBar: CustomAppBar(
          title: "tips".tr,
          showBackButton: true,
          showLogo: false,
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
          return RefreshIndicator(
            onRefresh: c.refresh,
            color: AppColor.primary,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 8),
                  _IntroCard(isAr: isAr),
                  const SizedBox(height: 24),
                  if (c.categories.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        "noTipsFound".tr,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                    )
                  else
                    ...List.generate(
                      c.categories.length,
                      (i) => Padding(
                        padding: EdgeInsets.only(bottom: i < c.categories.length - 1 ? 14 : 0),
                        child: _CategoryCard(
                          category: c.categories[i],
                          isAr: isAr,
                          onTap: () => _openCategory(c.categories[i]),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  void _openCategory(TipCategory category) {
    Get.toNamed("/tips-list", arguments: {
      "categoryId": category.id,
      "categoryName": category.displayName,
    });
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

class _IntroCard extends StatelessWidget {
  final bool isAr;

  const _IntroCard({required this.isAr});

  static const Color _textPurple = AppColor.deepPurple;

  @override
  Widget build(BuildContext context) {
    final imageSection = SizedBox(
      width: 120,
      child: Image.asset(
        ImageAssets.tipsImage,
        fit: BoxFit.cover,
        alignment: Alignment.centerLeft,
        errorBuilder: (_, __, ___) => Container(
          color: Colors.white,
          child: Icon(
            Icons.lightbulb_rounded,
            size: 48,
            color: AppColor.primary.withOpacity(0.6),
          ),
        ),
      ),
    );

    final textSection = Expanded(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Align(
          alignment: isAr ? Alignment.centerRight : Alignment.centerLeft,
          child: Text(
            "tipsIntro".tr,
            textAlign: isAr ? TextAlign.right : TextAlign.left,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: _textPurple,
              height: 1.4,
            ),
          ),
        ),
      ),
    );

    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColor.shadowColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: isAr ?  [imageSection, textSection]:[textSection, imageSection] ,
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final TipCategory category;
  final bool isAr;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.category,
    required this.isAr,
    required this.onTap,
  });

  static const Color _textPurple = AppColor.deepPurple;

  IconData _iconForCategory(TipCategory c) {
    final name = (c.nameEn ?? c.nameAr ?? "").toLowerCase();
    if (name.contains("sport") || name.contains("رياض")) return Icons.fitness_center_rounded;
    if (name.contains("myth") || name.contains("خراف")) return Icons.lightbulb_rounded;
    return Icons.restaurant_menu_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
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
          child: Row(
            children: [
              Icon(_iconForCategory(category), size: 28, color: _textPurple),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  category.displayName,
                  textAlign: isAr ? TextAlign.right : TextAlign.left,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: _textPurple,
                  ),
                ),
              ),
              Icon(
                isAr ? Icons.arrow_back_ios : Icons.arrow_forward_ios,
                size: 16,
                color: _textPurple.withOpacity(0.6),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
