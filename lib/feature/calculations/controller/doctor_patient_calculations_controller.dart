import 'package:get/get.dart';

import '../../../core/class/status_request.dart';
import '../../../core/function/handel_data.dart';
import '../../../core/service/serviecs.dart';
import '../../../doctorApp/feature/home/model/patient_model.dart';
import '../data/calculations_data.dart';
import '../model/calculation_model.dart';

class DoctorPatientCalculationsController extends GetxController {
  final CalculationsData calculationsData = CalculationsData(Get.find());
  final MyServices myServices = Get.find();

  StatusRequest statusRequest = StatusRequest.loading;
  final List<CalculationModel> calculations = [];

  late PatientModel patient;
  String patientName = "";

  @override
  void onInit() {
    super.onInit();
    final args = (Get.arguments as Map?) ?? {};
    final p = args["patient"];
    if (p is PatientModel) {
      patient = p;
      patientName = patient.fullname;
    } else {
      patient = PatientModel(id: 0, fullname: "-", userId: 0);
      patientName = (args["patient_name"] ?? "-").toString();
    }
    loadHistory();
  }

  int get patientId => patient.effectivePatientId;

  Future<void> loadHistory() async {
    if (patientId <= 0) {
      statusRequest = StatusRequest.failure;
      update();
      return;
    }
    statusRequest = StatusRequest.loading;
    update();

    final res = await calculationsData.patientHistory(
      patientId: patientId,
      token: myServices.token,
    );

    res.fold((l) {
      statusRequest = l;
      update();
    }, (r) {
      statusRequest = handelData(r);
      final list = (r["data"] as List?) ??
          (r["calculations"] as List?) ??
          ((r["data"] is Map && (r["data"] as Map)["data"] is List)
              ? (r["data"] as Map)["data"] as List
              : <dynamic>[]);
      calculations
        ..clear()
        ..addAll(
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

