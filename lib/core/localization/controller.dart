import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nutri_guide/core/service/serviecs.dart';

class LocalController extends GetxController {
  late MyServices myServices;
  Locale language = const Locale('ar');

  @override
  void onInit() {
    myServices = Get.find();
    _loadSavedLanguage();
    super.onInit();
  }

  void _loadSavedLanguage() {
    String? code = myServices.sharedPreferences.getString("lang");
    if (code == "ar") {
      language = const Locale('ar');
    } else if (code == "en") {
      language = const Locale('en');
    } else {
      language = Locale(Get.deviceLocale?.languageCode ?? 'ar');
    }
  }

  void changeLang(String code) {
    language = Locale(code);
    myServices.sharedPreferences.setString("lang", code);
    Get.updateLocale(language);
  }

  bool get isArabic => language.languageCode == 'ar';
}
