import 'package:get/get.dart';
import '../../../core/routes/app_route.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _goNext();
  }

  void _goNext() {
    Future.delayed(const Duration(milliseconds: 3000), () {
      Get.offAllNamed(AppRoute.gate);
    });
  }
}
