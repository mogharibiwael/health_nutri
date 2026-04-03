import 'package:get/get.dart';
import 'package:dartz/dartz.dart';
import '../../../core/class/status_request.dart';
import '../../../core/function/handel_data.dart';
import '../../../core/service/serviecs.dart';
import '../data/doctors_data.dart';
import '../model/doctor_model.dart';

class DoctorsController extends GetxController {
  final DoctorsData doctorsData = DoctorsData(Get.find());
  final MyServices myServices = Get.find();

  StatusRequest statusRequest = StatusRequest.loading;
  final List<DoctorModel> doctors = [];

  String? get token => myServices.sharedPreferences.getString("token");

  @override
  void onInit() {
    super.onInit();
    fetchDoctors();
  }

  Future<void> fetchDoctors() async {
    statusRequest = StatusRequest.loading;
    doctors.clear();
    update();

    final Either<StatusRequest, Map<String, dynamic>> res =
    await doctorsData.fetchDoctors(token: token);

    res.fold((l) {
      statusRequest = l;
      update();
    }, (r) {
      statusRequest = StatusRequest.success;
      List list = (r["data"] ?? r["doctors"] ?? []) as List;
      doctors.clear();
      for (final e in list) {
        if (e is Map<String, dynamic>) {
          try {
            doctors.add(DoctorModel.fromJson(e));
          } catch (_) {}
        } else if (e is Map) {
          try {
            doctors.add(DoctorModel.fromJson(Map<String, dynamic>.from(e)));
          } catch (_) {}
        }
      }
      update();
    });
  }

  Future<void> refreshDoctors() async {
    await fetchDoctors();
  }

  // (Optional) If you want details page later
  void openDoctor(DoctorModel d) {
    // Get.toNamed("/doctor_details", arguments: d);

  }
}
