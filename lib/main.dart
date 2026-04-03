import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nutri_guide/core/constant/theme/theme.dart';
import 'package:nutri_guide/core/localization/controller.dart';
import 'package:nutri_guide/core/localization/translation.dart';
import 'package:nutri_guide/core/routes/app_route.dart';
import 'package:nutri_guide/core/service/notification_service.dart';
import 'package:nutri_guide/core/service/serviecs.dart';

import 'core/routes/binding.dart';
import 'core/routes/route.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initialServices(); // Essential for MyServices
  
  try {
    final notif = NotificationService();
    await notif.initialize();
    await notif.rescheduleStoredReminders();
  } catch (e) {
    debugPrint("Notification Initialization Error: $e");
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    LocalController controller = Get.put(LocalController());
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      translations: Translation(),
      locale: controller.language,
      title: 'nutri gide',
      theme: themeData,
      initialRoute: AppRoute.splash,
      initialBinding: InitBinding(),
      getPages: AppPages.pages,
    );
  }
}
