import 'dart:convert';
import 'package:get/get.dart';
import 'package:nutri_guide/core/service/serviecs.dart';

import '../../../../core/routes/app_route.dart';


class DoctorHomeController extends GetxController {
  final MyServices myServices = Get.find();

  Map<String, dynamic>? user;

  @override
  void onInit() {
    super.onInit();
    loadUser();
  }

  void loadUser() {
    final userStr = myServices.sharedPreferences.getString("user");
    if (userStr == null || userStr.isEmpty) {
      user = null;
      update();
      return;
    }
    try {
      user = jsonDecode(userStr) as Map<String, dynamic>;
      print(myServices.sharedPreferences.getString("token"));
      print(user);
    } catch (_) {
      user = null;
    }
    update();
  }

  String get userName => (user?["name"] ?? "doctor").toString();
  String get userEmail => (user?["email"] ?? "-").toString();
  String get userPhone => (user?["phone"] ?? "-").toString();
  String get userRole  => (user?["role"] ?? "-").toString();



  Future<void> logout() async {
    await myServices.clearSession();
    Get.offAllNamed(AppRoute.login);
  }
}
