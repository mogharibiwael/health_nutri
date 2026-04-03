import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/class/status_request.dart';
import '../../../../core/routes/app_route.dart';
import '../../../../core/service/serviecs.dart';
import '../data/doctor_patients_data.dart';
import '../model/patient_model.dart';

class PatientDetailsController extends GetxController {
  late PatientModel patient;
  final DoctorPatientsData patientsData = DoctorPatientsData(Get.find());
  final MyServices myServices = Get.find();

  // Last calculation (from /api/doctor/patients/{id}/calculations)
  StatusRequest calculationsStatus = StatusRequest.success;
  double? lastCalcCalories;
  double? lastCalcBmi;
  double? lastCalcBmr;
  double? lastCalcCarboG;
  double? lastCalcFatG;
  double? lastCalcProteinG;
  DateTime? lastCalcCreatedAt;

  /// Macro percentages (carbs 50-65, protein 15-25, fat 25-35). Sum must = 100.
  static const int carbsMin = 50, carbsMax = 65;
  static const int proteinMin = 15, proteinMax = 25;
  static const int fatMin = 25, fatMax = 35;
  static const int carbsDefault = 55, proteinDefault = 20, fatDefault = 25;

  int carbsPercent = carbsDefault;
  int proteinPercent = proteinDefault;
  int fatPercent = fatDefault;

  bool isEditingMacros = false;
  StatusRequest macrosStatus = StatusRequest.success;
  StatusRequest saveMacrosStatus = StatusRequest.success;

  /// Which sections are expanded: 1=info, 2=nutritional, 3=macros
  final Set<int> expandedSections = {};

  void toggleSection(int section) {
    if (expandedSections.contains(section)) {
      expandedSections.remove(section);
    } else {
      expandedSections.add(section);
    }
    update();
  }

  bool isSectionExpanded(int section) => expandedSections.contains(section);

  @override
  void onInit() {
    super.onInit();

    final arg = Get.arguments;
    if (arg is PatientModel) {
      patient = arg;
    } else if (arg is Map<String, dynamic>) {
      patient = PatientModel.fromJson(arg);
    } else {
      patient = PatientModel(
        id: 0,
        fullname: "-",
        userId: 0,
      );
    }

    _setMacrosFromPatient();
    if (patient.id > 0) {
      _loadMacros();
      _loadPatientDetailsIfNeeded();
      _loadLastCalculation();
    }
  }


  @override
  void onReady() {
    print("patient---------");
    print(patient.id);
    print("patient----------");
  }

  /// Always fetch patient details - backend may return patient_id for diet-plans.
  Future<void> _loadPatientDetailsIfNeeded() async {
    // Doctor endpoints expect the patient USER id in many cases.
    final doctorPatientId = patient.userId > 0 ? patient.userId : patient.id;
    final res = await patientsData.getPatientDetails(
      patientId: doctorPatientId,
      token: myServices.token,
    );
    res.fold((_) {}, (r) {
      final statusCode = r["_statusCode"] ?? 200;
      if (statusCode == 200 || statusCode == 201) {
        _applyPatientDetails(r);
      } else {
        print("[PatientDetails] Skip update, status: $statusCode");
      }
    });
  }

  void _applyPatientDetails(Map<String, dynamic> r) {
    // Backend may return:
    // - { data: {...patient fields...} }
    // - { patient: {...user fields...}, calculations: [...] }
    final raw = r["data"];
    final data = raw is Map ? Map<String, dynamic>.from(raw) : r;
    if (data is! Map) return;

    // If wrapped as {patient: {...}}, prefer that but keep wrapper keys too (so PatientModel can merge).
    final patientMap = data["patient"];
    final merged = <String, dynamic>{
      ...Map<String, dynamic>.from(data as Map),
      if (patientMap is Map) ...Map<String, dynamic>.from(patientMap),
      if (patientMap is Map) "patient": Map<String, dynamic>.from(patientMap),
    };

    final updated = PatientModel.fromJson(merged);
    print("[PatientDetails] patient: id=${updated.id} user_id=${updated.userId} patientIdForDiet=${updated.patientIdForDiet}");
    patient = patient.copyWith(
      id: updated.id > 0 ? updated.id : null,
      userId: updated.userId > 0 ? updated.userId : null,
      patientIdForDiet: updated.patientIdForDiet,
      fullname: updated.fullname,
      gender: updated.gender ?? patient.gender,
      height: updated.height ?? patient.height,
      weight: updated.weight ?? patient.weight,
      phoneNumber: updated.phoneNumber ?? patient.phoneNumber,
      birthdate: updated.birthdate ?? patient.birthdate,
      physicalActivity: updated.physicalActivity ?? patient.physicalActivity,
      medical: updated.medical ?? patient.medical,
      user: updated.user ?? patient.user,
    );
    update();
  }

  double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString());
  }

  DateTime? _toDate(dynamic v) {
    if (v == null) return null;
    try {
      return DateTime.tryParse(v.toString());
    } catch (_) {
      return null;
    }
  }

  Future<void> _loadLastCalculation() async {
    calculationsStatus = StatusRequest.loading;
    update();
    try {
      final doctorPatientId = patient.userId > 0 ? patient.userId : patient.id;
      final res = await patientsData.getPatientCalculations(
        patientId: doctorPatientId,
        token: myServices.token,
      );
      res.fold((l) {
        calculationsStatus = l;
        update();
      }, (r) {
        calculationsStatus = StatusRequest.success;
        final data = r["data"] is Map ? (r["data"] as Map<String, dynamic>) : r;
        final listRaw = (data is Map) ? (data["calculations"] ?? data["data"] ?? data["items"]) : null;
        final list = listRaw is List ? listRaw : <dynamic>[];
        Map<String, dynamic>? latest;
        DateTime? latestDate;
        for (final e in list) {
          if (e is! Map) continue;
          final m = Map<String, dynamic>.from(e as Map);
          final d = _toDate(m["created_at"]) ?? _toDate(m["createdAt"]);
          if (latest == null) {
            latest = m;
            latestDate = d;
            continue;
          }
          if (d != null && (latestDate == null || d.isAfter(latestDate!))) {
            latest = m;
            latestDate = d;
          }
        }
        // Fallback: if no parsable dates, take the last item
        if (latest == null && list.isNotEmpty && list.last is Map) {
          latest = Map<String, dynamic>.from(list.last as Map);
          latestDate = _toDate(latest["created_at"]) ?? _toDate(latest["createdAt"]);
        }

        if (latest != null) {
          lastCalcCreatedAt = latestDate;
          lastCalcCalories = _toDouble(latest["calories"] ?? latest["total_calories"] ?? latest["totalCalories"]);
          lastCalcBmi = _toDouble(latest["BMI"] ?? latest["bmi"]);
          lastCalcBmr = _toDouble(latest["BMR"] ?? latest["bmr"]);
          lastCalcCarboG = _toDouble(latest["carbo"] ?? latest["carbs"] ?? latest["carbohydrates"]);
          lastCalcFatG = _toDouble(latest["fat"] ?? latest["fats"]);
          lastCalcProteinG = _toDouble(latest["protin"] ?? latest["protein"]);

          // If patient macros weren't set yet, we can prime them from last calculation.
          if (patient.carbohydrates == null && lastCalcCarboG != null) {
            patient = patient.copyWith(
              carbohydrates: lastCalcCarboG,
              fats: lastCalcFatG,
              protein: lastCalcProteinG,
            );
            _setMacrosFromPatient();
          }
        }
        update();
      });
    } catch (_) {
      calculationsStatus = StatusRequest.failure;
      update();
    }
  }

  void _setMacrosFromPatient() {
    final cal = dailyCalories ?? 2000.0;
    final carbsG = patient.carbohydrates;
    final fatG = patient.fats;
    final proteinG = patient.protein;
    if (carbsG != null && fatG != null && proteinG != null && cal > 0) {
      carbsPercent = ((carbsG * 4) / cal * 100).round().clamp(carbsMin, carbsMax);
      proteinPercent = ((proteinG * 4) / cal * 100).round().clamp(proteinMin, proteinMax);
      fatPercent = ((fatG * 9) / cal * 100).round().clamp(fatMin, fatMax);
      _normalizeMacroSum();
    } else {
      carbsPercent = carbsDefault;
      proteinPercent = proteinDefault;
      fatPercent = fatDefault;
    }
  }

  void _normalizeMacroSum() {
    int sum = carbsPercent + proteinPercent + fatPercent;
    if (sum == 100) return;
    int diff = 100 - sum;
    while (diff != 0 && (carbsPercent != carbsMin || proteinPercent != proteinMin || fatPercent != fatMin) &&
        (carbsPercent != carbsMax || proteinPercent != proteinMax || fatPercent != fatMax)) {
      if (diff > 0) {
        if (fatPercent < fatMax) { fatPercent++; diff--; }
        else if (proteinPercent < proteinMax) { proteinPercent++; diff--; }
        else if (carbsPercent < carbsMax) { carbsPercent++; diff--; }
        else break;
      } else {
        if (fatPercent > fatMin) { fatPercent--; diff++; }
        else if (proteinPercent > proteinMin) { proteinPercent--; diff++; }
        else if (carbsPercent > carbsMin) { carbsPercent--; diff++; }
        else break;
      }
    }
  }

  Future<void> _loadMacros() async {
    macrosStatus = StatusRequest.loading;
    update();

    final doctorPatientId = patient.userId > 0 ? patient.userId : patient.id;
    final res = await patientsData.getPatientMacros(
      patientId: doctorPatientId,
      token: myServices.token,
    );

    res.fold((l) {
      macrosStatus = l;
      update();
    }, (r) {
      macrosStatus = StatusRequest.success;
      final data = r["data"] is Map ? r["data"] as Map<String, dynamic> : r;
      final carbs = data["carbohydrates"];
      final fats = data["fats"];
      final protein = data["protein"];
      patient = patient.copyWith(
        carbohydrates: carbs != null ? (num.tryParse(carbs.toString())?.toDouble()) : null,
        fats: fats != null ? (num.tryParse(fats.toString())?.toDouble()) : null,
        protein: protein != null ? (num.tryParse(protein.toString())?.toDouble()) : null,
      );
      _setMacrosFromPatient();
      update();
    });
  }

  void toggleEditMacros() {
    isEditingMacros = !isEditingMacros;
    if (!isEditingMacros) _setMacrosFromPatient();
    update();
  }

  /// When we increment one macro, reduce another by 1 to keep sum=100.
  void _reduceOtherForIncrement(int exclude) {
    if (exclude != 1 && fatPercent > fatMin) {
      fatPercent--;
      return;
    }
    if (exclude != 2 && proteinPercent > proteinMin) {
      proteinPercent--;
      return;
    }
    if (exclude != 3 && carbsPercent > carbsMin) {
      carbsPercent--;
    }
  }

  /// When we decrement one macro, increase another by 1 to keep sum=100.
  void _increaseOtherForDecrement(int exclude) {
    if (exclude != 1 && fatPercent < fatMax) {
      fatPercent++;
      return;
    }
    if (exclude != 2 && proteinPercent < proteinMax) {
      proteinPercent++;
      return;
    }
    if (exclude != 3 && carbsPercent < carbsMax) {
      carbsPercent++;
    }
  }

  void incrementCarbs() {
    if (carbsPercent >= carbsMax) return;
    carbsPercent++;
    _reduceOtherForIncrement(1);
    update();
  }

  void decrementCarbs() {
    if (carbsPercent <= carbsMin) return;
    carbsPercent--;
    _increaseOtherForDecrement(1);
    update();
  }

  void incrementProtein() {
    if (proteinPercent >= proteinMax) return;
    proteinPercent++;
    _reduceOtherForIncrement(2);
    update();
  }

  void decrementProtein() {
    if (proteinPercent <= proteinMin) return;
    proteinPercent--;
    _increaseOtherForDecrement(2);
    update();
  }

  void incrementFats() {
    if (fatPercent >= fatMax) return;
    fatPercent++;
    _reduceOtherForIncrement(3);
    update();
  }

  void decrementFats() {
    if (fatPercent <= fatMin) return;
    fatPercent--;
    _increaseOtherForDecrement(3);
    update();
  }

  int get macroSum => carbsPercent + proteinPercent + fatPercent;
  bool get macroSumValid => macroSum == 100;

  double get calculatedCarbsGrams => ((dailyCalories ?? 0) * carbsPercent / 100) / 4;
  double get calculatedProteinGrams => ((dailyCalories ?? 0) * proteinPercent / 100) / 4;
  double get calculatedFatGrams => ((dailyCalories ?? 0) * fatPercent / 100) / 9;

  /// Age in years from birthdate (YYYY-MM-DD or similar)
  int? get patientAge {
    final b = patient.birthdate;
    if (b == null || b.isEmpty) return null;
    final parts = b.split(RegExp(r'[-/]'));
    if (parts.isEmpty) return null;
    final year = int.tryParse(parts[0]);
    if (year == null) return null;
    return DateTime.now().year - year;
  }

  /// BMR (Mifflin-St Jeor). Men: (10×Weight)+(6.25×Height)-(5×Age)+5. Women: -161 instead of +5.
  /// Weight in kg, Height in cm (or meters if < 10, auto-converted).
  double? get bmr {
    final w = patient.weight;
    final hRaw = patient.height;
    final age = patientAge;
    if (w == null || hRaw == null || age == null || w <= 0 || hRaw <= 0) return null;
    final h = (hRaw > 0 && hRaw < 10) ? hRaw * 100 : hRaw; // meters → cm
    final isFemale = (patient.gender ?? '').toLowerCase().contains('f') ||
        (patient.gender ?? '').contains('انث') ||
        (patient.gender ?? '').contains('انثى') ||
        (patient.gender ?? '').contains('female');
    if (isFemale) {
      return (10 * w) + (6.25 * h) - (5 * age) - 161;
    }
    return (10 * w) + (6.25 * h) - (5 * age) + 5;
  }

  /// Calories = BMR * activity multiplier
  double? get dailyCalories {
    final b = bmr;
    if (b == null) return null;
    final act = double.tryParse(patient.physicalActivity ?? '') ?? 1.3;
    return (b * act) + (b * act * 0.1);
  }

  double? get bmi {
    final hRaw = patient.height;
    final w = patient.weight;
    if (hRaw == null || w == null || hRaw <= 0) return null;
    final h = (hRaw > 0 && hRaw < 10) ? hRaw * 100 : hRaw; // meters → cm
    return w / ((h / 100) * (h / 100));
  }

  double get activityMultiplier => double.tryParse(patient.physicalActivity ?? '') ?? 1.3;

  Future<bool> saveMacros() async {
    if (!macroSumValid) {
      Get.snackbar("error".tr, "macroSumMustBe100".tr);
      return false;
    }

    final cal = dailyCalories;
    if (cal == null || cal <= 0) {
      Get.snackbar("error".tr, "fillPatientProfile".tr);
      return false;
    }

    final carbs = (cal * carbsPercent / 100) / 4;
    final protein = (cal * proteinPercent / 100) / 4;
    final fats = (cal * fatPercent / 100) / 9;

    saveMacrosStatus = StatusRequest.loading;
    update();

    final res = await patientsData.updatePatientMacros(
      patientId: patient.id,
      carbohydrates: carbs,
      fats: fats,
      protein: protein,
      token: myServices.token,
    );

    return res.fold((l) {
      saveMacrosStatus = StatusRequest.failure;
      update();
      Get.snackbar("error".tr, "serverError".tr);
      return false;
    }, (r) {
      if (r.containsKey("errors")) {
        saveMacrosStatus = StatusRequest.failure;
        update();
        final msg = r["message"]?.toString() ?? "serverError".tr;
        Get.snackbar("error".tr, msg);
        return false;
      }
      saveMacrosStatus = StatusRequest.success;
      patient = patient.copyWith(carbohydrates: carbs, fats: fats, protein: protein);
      isEditingMacros = false;
      _setMacrosFromPatient();
      update();
      Get.snackbar("success".tr, "saved".tr);
      return true;
    });
  }

  Future<void> openCreateDiet() async {
    // 1. Save macros first as requested by user
    final saved = await saveMacros();
    if (!saved) return;

    // 2. Proceed to creation flow
    // Backend expects doctor_id (doctors table id), not user_id. Use doctorId from session or fetch profile.
    int? doctorId = myServices.doctorId;
    if (doctorId == null && myServices.isDoctor) {
      final res = await patientsData.getDoctorProfile(token: myServices.token);
      res.fold(
        (l) {
          Get.snackbar("error".tr, "Could not load doctor profile");
        },
        (r) {
          final data = r["data"] is Map ? r["data"] as Map<String, dynamic> : r;
          final id = data["id"];
          doctorId = id is int ? id : int.tryParse(id?.toString() ?? "");
          if (doctorId != null && doctorId! > 0) {
            _fetchAndNavigateToDiet(doctorId!);
          } else {
            Get.snackbar("error".tr, "Doctor profile invalid");
          }
        },
      );
      return;
    }
    if (doctorId == null || doctorId <= 0) {
      Get.snackbar("error".tr, "Session error");
      return;
    }
    await _fetchAndNavigateToDiet(doctorId);
  }

  /// Fetch patient details before navigating - use patient from PatientDetailsController for diet creation.
  Future<void> _fetchAndNavigateToDiet(int doctorId) async {
    final res = await patientsData.getPatientDetails(
      patientId: patient.id,
      token: myServices.token,
    );
    res.fold((_) => _navigateToDietPeriods(doctorId), (r) => _applyPatientAndNavigate(r, doctorId));
  }

  void _applyPatientAndNavigate(Map<String, dynamic> r, int doctorId) {
    final data = r["data"] is Map ? r["data"] as Map<String, dynamic> : r;
    if (data is Map<String, dynamic>) {
      final updated = PatientModel.fromJson(data);
      print("[PatientDetails] patient for diet: id=${updated.id} user_id=${updated.userId} patientIdForDiet=${updated.patientIdForDiet} effective=${updated.effectivePatientId}");
      patient = patient.copyWith(
        id: updated.id > 0 ? updated.id : null,
        userId: updated.userId > 0 ? updated.userId : null,
        patientIdForDiet: updated.patientIdForDiet,
        fullname: updated.fullname,
      );
    }
    _navigateToDietPeriods(doctorId);
  }

  void _navigateToDietPeriods(int doctorId) {
    Get.toNamed(
      AppRoute.dietPeriods,
      arguments: {
        "patient_id": patient.effectivePatientId,
        "patient_name": patient.fullname,
        "doctor_id": doctorId,
        "patient": patient,
      },
    );
  }

  @override
  void onClose() {
    super.onClose();
  }
}
