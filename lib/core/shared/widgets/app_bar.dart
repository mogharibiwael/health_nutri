import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../constant/asset.dart';
import '../../constant/theme/colors.dart';

/// Global reusable AppBar: back button (optional), page title, circular logo.
/// Use across all screens for consistent header.
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.onBack,
    this.showLogo = true,
    this.showBackButton = false,
    this.leading,
    this.actions,
  });

  final String title;
  /// Optional subtitle (e.g. patient name) shown below title
  final String? subtitle;
  final VoidCallback? onBack;
  final bool showLogo;
  final bool showBackButton;
  /// Optional leading widget (e.g. menu icon for drawer). When set, overrides showBackButton.
  final Widget? leading;
  /// Optional action buttons (e.g. refresh, add).
  final List<Widget>? actions;

  static const Color _lightLavender = AppColor.mutedPurple;
  static const Color _darkPurple = AppColor.deepPurple;

  static const double _appBarHeight = 88;

  @override
  Size get preferredSize => const Size.fromHeight(_appBarHeight);

  @override
  Widget build(BuildContext context) {
    final isAr = Get.locale?.languageCode == 'ar';
    final textDir = isAr ? TextDirection.rtl : TextDirection.ltr;
    final displayTitle = title.trim().isNotEmpty && title.trim() != "-"
        ? title.trim()
        : "patient".tr;

    return Container(
      decoration: BoxDecoration(
        color: _lightLavender,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xff9F8A9A).withOpacity(0.35),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Directionality(
        textDirection: textDir,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          child: Row(
            children: [
              if (leading != null)
                leading!
              else if (showBackButton)
                IconButton(
                  onPressed: onBack ?? () => Get.back(),
                  icon: Icon(Icons.arrow_back, color: _darkPurple, size: 26),
                  padding: const EdgeInsets.all(4),
                  constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                )
              else
                const SizedBox(width: 44, height: 44),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: subtitle != null && subtitle!.trim().isNotEmpty && subtitle!.trim() != "-"
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              displayTitle,
                              textAlign: isAr ? TextAlign.right : TextAlign.left,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                color: _darkPurple,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              subtitle!.trim(),
                              textAlign: isAr ? TextAlign.right : TextAlign.left,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: _darkPurple.withOpacity(0.9),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        )
                      : Text(
                          displayTitle,
                          textAlign: isAr ? TextAlign.right : TextAlign.left,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: _darkPurple,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                ),
              ),
              if (actions != null) ...actions!,
              if (showLogo)
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xff9F8A9A).withOpacity(0.25),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Padding(
                      padding: const EdgeInsets.all(6),
                      child: Image.asset(
                        ImageAssets.logo,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                )
              else
                const SizedBox(width: 44, height: 44),
            ],
          ),
        ),
      ),
    );
  }
}
