import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dartz/dartz.dart';
import '../../../core/class/status_request.dart';
import '../../../core/function/handel_data.dart';
import '../../../core/service/serviecs.dart';
import '../data/consultations_data.dart';
import '../model/consultation_model.dart';

class ConsultationsController extends GetxController {
  final ConsultationsData consultationsData = ConsultationsData(Get.find());
  final MyServices myServices = Get.find();

  StatusRequest statusRequest = StatusRequest.loading;
  StatusRequest requestStatus = StatusRequest.success;

  final List<ConsultationModel> consultations = [];

  int currentPage = 1;
  bool hasNextPage = false;
  bool isLoadingMore = false;

  // Request consultation form controllers
  final TextEditingController doctorIdController = TextEditingController();
  final TextEditingController scheduledDateController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  String selectedType = "initial"; // initial, follow_up, review

  String? get token => myServices.token;

  @override
  void onInit() {
    super.onInit();
    fetchFirstPage();
  }

  Future<void> fetchFirstPage() async {
    currentPage = 1;
    consultations.clear();
    statusRequest = StatusRequest.loading;
    update();

    final res = await consultationsData.getConsultations(
      page: currentPage,
      token: token,
    );

    res.fold((l) {
      statusRequest = l;
      update();
    }, (r) {
      statusRequest = handelData(r);

      final List data = (r["data"] ?? []) as List;
      consultations.addAll(
        data.map((e) => ConsultationModel.fromJson(e as Map<String, dynamic>)),
      );

      hasNextPage = r["next_page_url"] != null;
      statusRequest = StatusRequest.success;
      update();
    });
  }

  Future<void> refreshConsultations() async {
    await fetchFirstPage();
  }

  Future<void> loadMore() async {
    if (!hasNextPage || isLoadingMore || statusRequest == StatusRequest.loading) return;

    isLoadingMore = true;
    update();

    final nextPage = currentPage + 1;
    final res = await consultationsData.getConsultations(
      page: nextPage,
      token: token,
    );

    res.fold((l) {
      isLoadingMore = false;
      update();
    }, (r) {
      final List data = (r["data"] ?? []) as List;
      consultations.addAll(
        data.map((e) => ConsultationModel.fromJson(e as Map<String, dynamic>)),
      );

      currentPage = nextPage;
      hasNextPage = r["next_page_url"] != null;
      isLoadingMore = false;
      update();
    });
  }

  Future<void> requestConsultation({
    required int doctorId,
    required String consultationType,
    required String scheduledDate,
    String? notes,
  }) async {
    requestStatus = StatusRequest.loading;
    update();

    final res = await consultationsData.requestConsultation(
      doctorId: doctorId,
      consultationType: consultationType,
      scheduledDate: scheduledDate,
      notes: notes,
      token: token,
    );

    res.fold((l) {
      requestStatus = StatusRequest.failure;
      update();
      Get.snackbar("error".tr, "serverError".tr);
    }, (r) {
      if (r.containsKey("errors")) {
        requestStatus = StatusRequest.failure;
        update();
        final errors = r["errors"] as Map?;
        final firstError = errors?.values.first;
        final msg = (firstError is List && firstError.isNotEmpty)
            ? firstError.first.toString()
            : r["message"]?.toString() ?? "serverError".tr;
        Get.snackbar("error".tr, msg);
        return;
      }

      requestStatus = StatusRequest.success;
      update();
      Get.snackbar("success".tr, r["message"]?.toString() ?? "Consultation requested successfully");
      refreshConsultations();
    });
  }

  @override
  void onClose() {
    doctorIdController.dispose();
    scheduledDateController.dispose();
    notesController.dispose();
    super.onClose();
  }
}
