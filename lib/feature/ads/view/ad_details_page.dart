import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constant/theme/colors.dart';
import '../../../core/shared/widgets/app_bar.dart';
import '../model/ad_model.dart';

class AdDetailsPage extends StatelessWidget {
  const AdDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final arg = Get.arguments;
    final ad = (arg is AdModel) ? arg : (arg is Map ? arg["ad"] as AdModel? : null);
    if (ad == null) {
      return SafeArea(
        child: Scaffold(
          appBar: CustomAppBar(title: "Ads", showBackButton: true, showLogo: false),
          body: Center(child: Text("serverError".tr)),
        ),
      );
    }

    final title = (ad.title ?? ad.type ?? "").trim();
    final description = (ad.description ?? "").trim();
    final hasTitle = title.isNotEmpty;
    final hasDesc = description.isNotEmpty;
    final hasPhone = (ad.phoneNumber ?? "").trim().isNotEmpty;
    final hasLink = (ad.link ?? "").trim().isNotEmpty;

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: CustomAppBar(
          title: hasTitle ? title : "Ads",
          showBackButton: true,
          showLogo: false,
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _ImageCard(imageUrl: ad.imageUrl),
            const SizedBox(height: 12),
            if (hasTitle)
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColor.deepPurple,
                ),
              ),
            if (hasDesc) ...[
              const SizedBox(height: 8),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.45,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
            if (hasPhone || hasLink) ...[
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  if (hasPhone)
                    _ActionChip(
                      icon: Icons.call_rounded,
                      label: (ad.phoneNumber ?? "").trim(),
                      onTap: () => _launchUri(Uri.parse("tel:${(ad.phoneNumber ?? "").trim()}")),
                    ),
                  if (hasLink)
                    _ActionChip(
                      icon: Icons.open_in_new_rounded,
                      label: "open".tr,
                      onTap: () {
                        final raw = (ad.link ?? "").trim();
                        final uri = Uri.tryParse(raw.startsWith("http") ? raw : "https://$raw");
                        if (uri != null) _launchUri(uri);
                      },
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _launchUri(Uri uri) async {
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        Get.snackbar("error".tr, "serverError".tr);
      }
    } catch (_) {
      Get.snackbar("error".tr, "serverError".tr);
    }
  }
}

class _ImageCard extends StatelessWidget {
  final String? imageUrl;
  const _ImageCard({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final url = imageUrl;
    final hasImage = url != null && url.trim().isNotEmpty;

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: hasImage
            ? Image.network(
                url!,
                fit: BoxFit.cover,
                headers: const {'Accept': 'image/*'},
                errorBuilder: (_, __, ___) => _placeholder(),
              )
            : _placeholder(),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: AppColor.primary.withOpacity(0.08),
      child: Center(
        child: Icon(Icons.image_outlined, size: 56, color: AppColor.primary.withOpacity(0.6)),
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionChip({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: AppColor.primary.withOpacity(0.10),
          border: Border.all(color: AppColor.primary.withOpacity(0.25)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: AppColor.primary),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w700, color: AppColor.deepPurple),
            ),
          ],
        ),
      ),
    );
  }
}

