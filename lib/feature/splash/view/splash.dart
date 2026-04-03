import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constant/theme/colors.dart';
import '../../../core/constant/asset.dart';
import '../controller/controller.dart';

class SplashScreen extends GetView<SplashController> {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  ImageAssets.logo,
                  height: 200,
                  fit: BoxFit.contain,
                ),

                _AppNameText(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// App name with first word in #67025F and second part in #587430.
class _AppNameText extends StatelessWidget {
  static const Color _firstColor = AppColor.deepPurple;
  static const Color _secondColor = AppColor.accentGreen;

  @override
  Widget build(BuildContext context) {
    final full = 'appName'.tr;
    final space = full.indexOf(' ');
    final firstWord = space > 0 ? full.substring(0, space) : full;
    final secondPart = space > 0 ? full.substring(space).trim() : '';

    return Text.rich(
      TextSpan(
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
        ),
        children: [
          TextSpan(text: firstWord, style: TextStyle(color:_firstColor )),
          if (secondPart.isNotEmpty) TextSpan(text: ' $secondPart',style: TextStyle(color:_secondColor )),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}
