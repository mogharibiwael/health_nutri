import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/routes/app_route.dart';
import '../../../core/service/serviecs.dart';

class GateMiddleware extends GetMiddleware {
  GateMiddleware({this.priority = 0});

  @override
  final int priority;

  final MyServices myServices = Get.find();

  @override
  RouteSettings? redirect(String? route) {
    // 1) لا يوجد جلسة -> شاشة الترحيب ثم تسجيل الدخول
    if (!myServices.isLoggedIn) {
      return RouteSettings(name: AppRoute.welcome);
    }

    // 2) Logged in: everyone (doctor or patient) goes to shared home. Doctors enter even if not yet approved by admin; approved doctors see "My clinic" there.
    return RouteSettings(name: AppRoute.home);
  }
}
