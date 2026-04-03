import 'package:flutter/material.dart';
import 'package:nutri_guide/core/constant/theme/colors.dart';

class GlobalButton extends StatelessWidget {
  final String textButton;
  final VoidCallback? onPress;
  final bool isLoading;

  const GlobalButton({
    super.key,
    required this.textButton,
    required this.onPress,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          backgroundColor: AppColor.primary,
          foregroundColor: AppColor.white,
          textStyle: Theme.of(context).textTheme.titleMedium,
        ),
        onPressed: isLoading ? null : onPress,
        child: isLoading
            ? const SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.white,
          ),
        )
            : Text(textButton),
      ),
    );
  }
}
