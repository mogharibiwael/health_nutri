import 'package:get/get.dart';
import '../../../core/routes/app_route.dart';
import '../../../../doctorApp/feature/home/model/patient_model.dart';
import '../../../core/service/diet_calculator_service.dart';
import '../model/exchange_model.dart';
import '../model/portion_categories_model.dart';

class PortionCategoriesController extends GetxController {
  int? patientId;
  String patientName = "";
  int? doctorId;
  PatientModel? patient;
  List<Map<String, dynamic>> periods = [];
   DietTargetsResult? targets;
  DailyExchangePlan? exchangePlan;

  late PortionCategoriesPlan portionPlan;

  // --- Multi-step Wizard State ---
  int currentStep = 1;
  bool showSummary = false;
  bool showMeatTarget = false;
  bool showStarchTarget = false;
  bool showFatTarget = false;

  @override
  void onInit() {
    super.onInit();
    final args = (Get.arguments as Map?) ?? {};
    patientId = args["patient_id"];
    patientName = (args["patient_name"] ?? "").toString();
    doctorId = args["doctor_id"] is int
        ? args["doctor_id"] as int
        : int.tryParse("${args["doctor_id"]}") ?? 0;
    patient = args["patient"] as PatientModel?;
    if (args["periods"] is List) {
      periods = (args["periods"] as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    }
    targets = args["targets"] as DietTargetsResult?;
    if (args["exchange_plan"] is DailyExchangePlan) {
      exchangePlan = args["exchange_plan"] as DailyExchangePlan;
    } else if (args["exchange_plan_json"] is Map) {
      exchangePlan = DailyExchangePlan.fromJson(
        Map<String, dynamic>.from(args["exchange_plan_json"] as Map),
      );
    }
    portionPlan = exchangePlan != null
        ? PortionCategoriesPlan.fromDailyExchange(exchangePlan!)
        : PortionCategoriesPlan();
  }

  void setPortion(String key, double value) {
    switch (key) {
      case 'milkSkim':
        portionPlan.milkSkim = value.clamp(0, 20);
        break;
      case 'milkLowFat':
        portionPlan.milkLowFat = value.clamp(0, 20);
        break;
      case 'milkWhole':
        portionPlan.milkWhole = value.clamp(0, 20);
        break;
      case 'vegetables':
        portionPlan.vegetables = value.clamp(0, 20);
        break;
      case 'fruit':
        portionPlan.fruit = value.clamp(0, 20);
        break;
      case 'starch':
        portionPlan.starch = value.clamp(0, 20);
        break;
      case 'otherCarbs':
        portionPlan.otherCarbs = value.clamp(0, 20);
        break;
      case 'meatVeryLean':
        portionPlan.meatVeryLean = value.clamp(0, 20);
        break;
      case 'meatLean':
        portionPlan.meatLean = value.clamp(0, 20);
        break;
      case 'meatMediumFat':
        portionPlan.meatMediumFat = value.clamp(0, 20);
        break;
      case 'meatHighFat':
        portionPlan.meatHighFat = value.clamp(0, 20);
        break;
      case 'fat':
        portionPlan.fat = value.clamp(0, 30);
        break;
    }
    update();
  }

  double getPortion(String key) {
    final m = portionPlan.toGroupMap();
    return m[key] ?? 0;
  }

  // --- Target Calculations ---

  double get currentProtein => portionPlan.totalProtein;
  double get currentCarbs => portionPlan.totalCarbs;
  double get currentFat => portionPlan.totalFat;
  double get currentCalories => portionPlan.totalCalories;

  double get targetProtein => targets?.macros.proteinG ?? 0;
  double get targetCarbs => targets?.macros.carbsG ?? 0;
  double get targetFat => targets?.macros.fatG ?? 0;
  double get targetCalories => targets?.macros.calories ?? 0;

  double get errorRate {
    if (currentCalories == 0) return 0;
    return (targetCalories - currentCalories).abs() / currentCalories;
  }

  double get baseCarbs =>
      (portionPlan.milkSkim * 12) +
      (portionPlan.milkLowFat * 12) +
      (portionPlan.milkWhole * 12) +
      (portionPlan.vegetables * 5) +
      (portionPlan.fruit * 15);

  double get baseProtein =>
      (portionPlan.milkSkim * 8) +
      (portionPlan.milkLowFat * 8) +
      (portionPlan.milkWhole * 8) +
      (portionPlan.vegetables * 2) +
      (portionPlan.fruit * 0) +
      (portionPlan.starch * 3) +
      (portionPlan.otherCarbs * 3);

  /// User requested formula: Target Fat - (Milk, Veg, Fruit fat) / 5
  double get remainingFatTarget {
    final target = targetFat;
    final milkF = (portionPlan.milkSkim * ExchangeDefinitions.milkSkim.fatG) +
                 (portionPlan.milkLowFat * ExchangeDefinitions.milkLowFat.fatG) +
                 (portionPlan.milkWhole * ExchangeDefinitions.milkWhole.fatG);
    final vegF = (portionPlan.vegetables * ExchangeDefinitions.vegetables.fatG);
    final fruF = (portionPlan.fruit * ExchangeDefinitions.fruit.fatG);
    final starchF = (portionPlan.starch * ExchangeDefinitions.starch.fatG) +
                    (portionPlan.otherCarbs * ExchangeDefinitions.starch.fatG);
    
    final totalSubtracted = milkF + vegF + fruF + starchF;
    final remaining = target - totalSubtracted;
    
    // Safety check: if result is 12.8 and it shouldn't be, something is very wrong with the source data
    return remaining / 5.0;
  }

  double get remainingCarbsTarget => (targetCarbs - baseCarbs) / 15.0;
  double get remainingProteinTarget {
    // Collect proteins from Milk and Vegetables only (Fruit has 0, Starch/Other are what we calculate)
    final proteinFromMilkAndVeg = 
        (portionPlan.milkSkim * 8) +
        (portionPlan.milkLowFat * 8) +
        (portionPlan.milkWhole * 8) +
        (portionPlan.vegetables * 2);

    // Formula requested by user: (Target Protein - (Milk/Veg Prot)) / 7
    return (targetProtein - proteinFromMilkAndVeg) / 7.0;
  }

  void calculateMeat() {
    showMeatTarget = true;
    update();
  }

  void calculateStarch() {
    showStarchTarget = true;
    update();
  }

  void calculateFat() {
    showFatTarget = true;
    update();
  }

  // --- Specialized Workflow State ---
  bool isInitialView = true;
  bool showFullTable = false;

  void calculateAndShowRemaining() {
    // This will be called from the UI and used to trigger popups sequentially
    update();
  }

  void nextStep() {
    if (isInitialView) {
      isInitialView = false;
      showFullTable = true;
      currentStep = 2;
    } else if (!showSummary) {
      showSummary = true;
      currentStep = 3;
    }
    update();
  }

  void setStarchAndOther(double starch, double other) {
    portionPlan.starch = starch;
    portionPlan.otherCarbs = other;
    update();
  }

  void setMeats(double veryLean, double lean, double medium, double high) {
    portionPlan.meatVeryLean = veryLean;
    portionPlan.meatLean = lean;
    portionPlan.meatMediumFat = medium;
    portionPlan.meatHighFat = high;
    update();
  }

  void setFat(double value) {
    portionPlan.fat = value;
    update();
  }

  void finishInitialPhase() {
    isInitialView = false;
    showFullTable = true;
    currentStep = 2;
    update();
  }

  void previousStep() {
    if (showSummary) {
      showSummary = false;
      currentStep = 2;
    } else if (showFullTable) {
      showFullTable = false;
      isInitialView = true;
      currentStep = 1;
    } else if (currentStep > 1) {
      currentStep--;
    }
    update();
  }

  void finishDistribution() {
    if (patientId == null || doctorId == null) {
      Get.snackbar("error".tr, "fillFields".tr);
      return;
    }
    
    // Skip redundant Carb and Protein full pages (now handled by popups)
    // Go directly to final Meal Distribution
    Get.toNamed(
      AppRoute.dietDistribution,
      arguments: {
        "patient_id": patientId,
        "patient_name": patientName,
        "doctor_id": doctorId,
        "patient": patient,
        "periods": periods,
        "targets": targets,
        "portion_plan": portionPlan,
        "exchange_plan": portionPlan.toDailyExchange(),
        "exchange_plan_json": portionPlan.toDailyExchange().toJson(),
      },
    );
  }
}
