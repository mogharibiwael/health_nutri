import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/class/status_request.dart';
import '../../../../core/function/handel_data.dart';
import '../../../../core/routes/app_route.dart';
import '../../../../core/service/serviecs.dart';
import '../data/doctor_patients_data.dart';
import '../model/patient_model.dart';

class DoctorPatientsController extends GetxController {
  final MyServices myServices = Get.find();
  final DoctorPatientsData dataSource = DoctorPatientsData(Get.find());


  Map<String, dynamic>? user;

  StatusRequest statusRequest = StatusRequest.loading;

  final List<PatientModel> patients = [];
  final searchController = TextEditingController();
  String searchQuery = '';

  int currentPage = 1;
  bool hasMore = true;

  @override
  void onInit() {
    super.onInit();
    loadUser();
    fetchPatients(first: true);
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  void onSearchChanged(String query) {
    searchQuery = query.trim();
    update();
  }

  List<PatientModel> get filteredPatients {
    final q = searchQuery.toLowerCase();
    if (q.isEmpty) return patients;
    return patients
        .where((p) =>
            p.fullname.toLowerCase().contains(q) ||
            (p.phoneNumber ?? '').contains(q) ||
            (p.user?.email ?? '').toLowerCase().contains(q))
        .toList();
  }

  Future<void> fetchPatients({bool first = false}) async {
    if (first) {
      currentPage = 1;
      hasMore = true;
      patients.clear();
      statusRequest = StatusRequest.loading;
      update();
    }

    final res = await dataSource.getPatients(
      page: currentPage,
      token: myServices.token,
    );

    statusRequest = handelData(res);
    update();

    res.fold(
          (l) {
        statusRequest = l;
        update();
      },
          (r) {
        final list = (r["data"] as List?) ?? [];
        final newItems = list
            .whereType<Map>()
            .map((e) => PatientModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();

        patients.addAll(newItems);

        final lastPage = (r["last_page"] is int)
            ? r["last_page"] as int
            : int.tryParse("${r["last_page"]}") ?? 1;

        hasMore = currentPage < lastPage;

        statusRequest = StatusRequest.success;
        update();
      },
    );
  }

  Future<void> refreshPatients() async {
    await fetchPatients(first: true);
  }

  void loadMore() {
    if (!hasMore) return;
    if (statusRequest == StatusRequest.loading) return;
    currentPage++;
    fetchPatients(first: false);
  }

  String get userName => (user?["name"] ?? "doctor").toString();
  String get userEmail => (user?["email"] ?? "-").toString();
  String get userPhone => (user?["phone"] ?? "-").toString();
  String get userRole  => (user?["role"] ?? "-").toString();

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

  Future<void> logout() async {
    await myServices.clearSession();
    Get.offAllNamed(AppRoute.login);
  }
}




