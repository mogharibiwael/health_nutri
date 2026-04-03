import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dartz/dartz.dart';
import '../../../core/class/status_request.dart';
import '../../../core/function/handel_data.dart';
import '../../../core/service/serviecs.dart';
import '../../../core/permissions/permissions.dart';
import '../data/diet_data.dart';
import '../model/diet_model.dart';

class DietController extends GetxController {
  final DietData dietData = DietData(Get.find());
  final MyServices myServices = Get.find();
  late final Permissions permissions;

  StatusRequest statusRequest = StatusRequest.loading;
  StatusRequest mealsStatusRequest = StatusRequest.success;
  bool hasLoadedMealsOnce = false;
  StatusRequest createStatus = StatusRequest.success;
  StatusRequest doctorDietsStatus = StatusRequest.loading;

  DietModel? currentDiet;
  List<DietMealModel> meals = [];
  List<DietModel> allDiets = []; // For doctors: list of diets
  List<Map<String, dynamic>> dietPeriodsRef = [];
  List<Map<String, dynamic>> dietComponentsRef = [];
  List<Map<String, dynamic>> dietNotesRef = [];
  List<Map<String, dynamic>> dietTypesRef = [];

  String? get token => myServices.token;
  bool get isDoctor => permissions.isDoctor || permissions.isAdmin;
  bool get canCreateDiet => permissions.canCreateDietPlan;
  int? get currentUserId => myServices.userId;
  /// Doctor's record id for diet creation (backend expects doctor_id from doctors table)
  int? get currentDoctorId => myServices.doctorId;

  // Create diet plan form controllers (for doctors)
  final TextEditingController patientIdController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController dailyCaloriesController = TextEditingController();
  final TextEditingController durationDaysController = TextEditingController();
  final TextEditingController startDateController = TextEditingController();
  final TextEditingController endDateController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    permissions = Permissions(myServices);
    // Only load diet if user is patient
    if (permissions.canViewMyDiet) {
      loadMyDiet();
    } else {
      statusRequest = StatusRequest.success;
      update();
    }
  }

  Future<void> loadMyDiet() async {
    statusRequest = StatusRequest.loading;
    update();

    final res = await dietData.getMyDiet(token: token);

    res.fold((l) {
      statusRequest = l;
      update();
    }, (r) {
      statusRequest = handelData(r);

      if (r["data"] is Map) {
        currentDiet = DietModel.fromJson(r["data"] as Map<String, dynamic>);
      } else {
        currentDiet = DietModel.fromJson(r);
      }

      statusRequest = StatusRequest.success;
      update();
    });
  }

  Future<void> loadMeals() async {
    mealsStatusRequest = StatusRequest.loading;
    update();

    final res = await dietData.getMyDietMeals(token: token);

    res.fold((l) {
      mealsStatusRequest = l;
      hasLoadedMealsOnce = true;
      update();
    }, (r) {
      mealsStatusRequest = handelData(r);

      final List data = (r["data"] ?? r["meals"] ?? []) as List;
      meals = data
          .map((e) => DietMealModel.fromJson(e as Map<String, dynamic>))
          .toList();

      mealsStatusRequest = StatusRequest.success;
      hasLoadedMealsOnce = true;
      update();
    });
  }

  Future<void> createDietPlan({
    required int patientId,
    required int doctorId,
    required String title,
    required int dailyCalories,
    required int durationDays,
    required String startDate,
    required String endDate,
    List<Map<String, dynamic>>? meals,
    List<Map<String, dynamic>>? mealPeriods,
    List<String>? doctorNotes,
    VoidCallback? onSuccess,
  }) async {
    createStatus = StatusRequest.loading;
    update();
    print("patientId--1-1-1-1-1-1-1-1-1");
    print(patientId);
    print("patientId--1-1-1-1-1-1-1-1-1");
    final res = await dietData.createDietPlan(
      patientId: patientId,
      doctorId: doctorId,
      title: title,
      dailyCalories: dailyCalories,
      durationDays: durationDays,
      startDate: startDate,
      endDate: endDate,
      meals: meals,
      mealPeriods: mealPeriods,
      doctorNotes: doctorNotes,
      token: token,
    );

    res.fold((l) {
      createStatus = StatusRequest.failure;
      update();
      Get.snackbar("error".tr, "serverError".tr);
    }, (r) {
      if (r.containsKey("errors")) {
        createStatus = StatusRequest.failure;
        update();
        final errors = r["errors"] as Map?;
        final firstError = errors?.values.first;
        final msg = (firstError is List && firstError.isNotEmpty)
            ? firstError.first.toString()
            : r["message"]?.toString() ?? "serverError".tr;
        Get.snackbar("error".tr, msg);
        return;
      }

      createStatus = StatusRequest.success;
      update();
      Get.snackbar("success".tr, r["message"]?.toString() ?? "Diet plan created successfully");
      onSuccess?.call();
    });
  }

  Future<void> refreshDiet() async {
    await loadMyDiet();
  }

  /// GET /api/diets - Load all diets (for doctors)
  Future<void> loadAllDiets({int page = 1}) async {
    if (!isDoctor) return;
    doctorDietsStatus = StatusRequest.loading;
    update();
    final res = await dietData.getAllDiets(token: token, page: page);
    res.fold((l) {
      doctorDietsStatus = l;
      update();
    }, (r) {
      final list = (r["data"] as List?) ?? [];
      allDiets = list
          .whereType<Map>()
          .map((e) => DietModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      doctorDietsStatus = StatusRequest.success;
      update();
    });
  }

  /// GET /api/diet-plans/{id} - Load full diet plan with meals
  Future<DietModel?> loadDiet(int dietId) async {
    final res = await dietData.getDietPlan(planId: dietId, token: token);
    return res.fold((_) => null, (r) {
      final d = r["data"] is Map ? r["data"] as Map<String, dynamic> : r;
      return d is Map<String, dynamic> ? DietModel.fromJson(d) : null;
    });
  }

  /// PUT /api/diets/{id} - Update diet
  Future<bool> updateDiet({
    required int dietId,
    required Map<String, dynamic> body,
  }) async {
    final res = await dietData.updateDiet(dietId: dietId, body: body, token: token);
    return res.fold((_) => false, (r) {
      if (r.containsKey("errors")) return false;
      Get.snackbar("success".tr, r["message"]?.toString() ?? "saved".tr);
      return true;
    });
  }

  /// DELETE /api/diets/{id} - Delete diet
  Future<bool> deleteDiet(int dietId) async {
    final res = await dietData.deleteDiet(dietId: dietId, token: token);
    return res.fold((_) => false, (r) {
      Get.snackbar("success".tr, r["message"]?.toString() ?? "saved".tr);
      return true;
    });
  }

  /// PUT /api/diets/{id}/status - Change diet status
  Future<bool> updateDietStatus({required int dietId, required String status}) async {
    final res = await dietData.updateDietStatus(dietId: dietId, status: status, token: token);
    return res.fold((_) => false, (r) {
      Get.snackbar("success".tr, r["message"]?.toString() ?? "saved".tr);
      return true;
    });
  }

  /// GET /api/diet-periods - Load diet periods reference
  Future<void> loadDietPeriodsRef() async {
    final res = await dietData.getDietPeriods(token: token);
    res.fold((_) {}, (r) {
      dietPeriodsRef = ((r["data"] ?? r) as List?)?.map((e) => Map<String, dynamic>.from(e as Map)).toList() ?? [];
      update();
    });
  }

  /// GET /api/diet-components - Load diet components reference
  Future<void> loadDietComponentsRef() async {
    final res = await dietData.getDietComponents(token: token);
    res.fold((_) {}, (r) {
      dietComponentsRef = ((r["data"] ?? r) as List?)?.map((e) => Map<String, dynamic>.from(e as Map)).toList() ?? [];
      update();
    });
  }

  /// GET /api/diet-notes - Load diet notes reference
  Future<void> loadDietNotesRef() async {
    final res = await dietData.getDietNotes(token: token);
    res.fold((_) {}, (r) {
      dietNotesRef = ((r["data"] ?? r) as List?)?.map((e) => Map<String, dynamic>.from(e as Map)).toList() ?? [];
      update();
    });
  }

  /// GET /api/diet-types - Load diet types reference
  Future<void> loadDietTypesRef() async {
    final res = await dietData.getDietTypes(token: token);
    res.fold((_) {}, (r) {
      dietTypesRef = ((r["data"] ?? r) as List?)?.map((e) => Map<String, dynamic>.from(e as Map)).toList() ?? [];
      update();
    });
  }

  @override
  void onClose() {
    patientIdController.dispose();
    titleController.dispose();
    dailyCaloriesController.dispose();
    durationDaysController.dispose();
    startDateController.dispose();
    endDateController.dispose();
    super.onClose();
  }
}
