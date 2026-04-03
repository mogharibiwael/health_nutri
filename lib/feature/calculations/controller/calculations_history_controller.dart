import 'package:get/get.dart';
import 'package:dartz/dartz.dart';

import '../../../core/class/status_request.dart';
import '../../../core/function/handel_data.dart';
import '../../../core/service/serviecs.dart';
import '../data/calculations_data.dart';
import '../model/calculation_model.dart';

class CalculationsHistoryController extends GetxController {
  final CalculationsData calculationsData = CalculationsData(Get.find());
  final MyServices myServices = Get.find();

  StatusRequest statusRequest = StatusRequest.loading;
  final List<CalculationModel> calculations = [];

  @override
  void onInit() {
    super.onInit();
    loadHistory();
  }

  Future<void> loadHistory() async {
    statusRequest = StatusRequest.loading;
    update();

    final res = await calculationsData.history(token: myServices.token);

    res.fold((l) {
      statusRequest = l;
      update();
    }, (r) {
      statusRequest = handelData(r);
      final list = (r["data"] as List?) ?? (r["calculations"] as List?) ?? [];
      calculations.clear();
      calculations.addAll(
        list
            .whereType<Map>()
            .map((e) => CalculationModel.fromJson(Map<String, dynamic>.from(e))),
      );
      statusRequest = StatusRequest.success;
      update();
    });
  }

  Future<void> refreshHistory() async => loadHistory();
}
