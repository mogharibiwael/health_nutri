import 'package:get/get.dart';

class SpiritualNutritionController extends GetxController {
  void goMorningAthkar() => Get.toNamed("/athkar-list", arguments: {
        "category": "صباحي",
        "titleKey": "morningAthkar",
      });

  void goEveningAthkar() => Get.toNamed("/athkar-list", arguments: {
        "category": "مسائي",
        "titleKey": "eveningAthkar",
      });
}
