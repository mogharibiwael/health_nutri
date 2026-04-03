import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nutri_guide/core/constant/theme/colors.dart';

class TextSignup extends StatelessWidget {


  void Function()? onTapFun;
   TextSignup({super.key,required this.onTapFun});

  @override
  Widget build(BuildContext context) {
    return   Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [

        Text("dont_have_account".tr + "!"),

        SizedBox(width: 5,),
        InkWell(

          onTap: onTapFun,

          child: Text("signup".tr,style: TextStyle(color: AppColor.primary),),

        ),
      ],
    );
  }
}
