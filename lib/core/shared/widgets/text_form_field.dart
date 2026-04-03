import 'package:flutter/material.dart';

import '../../constant/theme/colors.dart';

// This Custom TextFormField Widget have label and hint and icon
class CustomTextFormField extends StatelessWidget {
  TextEditingController controller;
  String label;
  String hintText;
  IconData icon;
  TextInputType keyboardType;
  bool obscureText;
  final Widget? suffixIcon;


  CustomTextFormField({
    super.key,
    required this.controller,
    required this.label,
    required this.hintText,
    required this.icon,
    required this.keyboardType,
    required this.obscureText,
     this.suffixIcon
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 24),
      child: TextFormField(
        controller: controller,
        keyboardType:keyboardType ,
        obscureText: obscureText,
        style: TextStyle(color: AppColor.primary),

        decoration: InputDecoration(
          label: Text(label),
          hintText: hintText,
          suffix: suffixIcon,
          floatingLabelBehavior: FloatingLabelBehavior.always,
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          suffixIcon: Icon(icon, color: AppColor.textColor),
        ),
      ),
    );
  }
}
