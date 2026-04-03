import 'package:get/get.dart';

import '../../../core/routes/app_route.dart';
import '../../../core/service/serviecs.dart';
import 'package:flutter/material.dart';


class GuestMiddleware extends GetMiddleware {
  GuestMiddleware({this.priority = 1});
  @override
  final int priority;

  final MyServices myServices = Get.find();

  @override
  RouteSettings? redirect(String? route) {
    // إذا مسجل دخول -> حسب النوع
    if (myServices.isLoggedIn) {
      final t = (myServices.type ?? "user").toString();
      return RouteSettings(
        name: t == "doctor" ? AppRoute.doctorHome : AppRoute.home,
      );
    }

    // إذا غير مسجل دخول -> روح login (بدل null)
    return  RouteSettings(name: AppRoute.login);
  }
}
