import 'package:dartz/dartz.dart';
import '../../../core/class/crud.dart';
import '../../../core/class/status_request.dart';
import '../../../core/constant/api_link.dart';

/// Per backend routes:
/// - POST /api/calculations/nutrition (calculate + optional save)
/// - GET /api/calculations/history (history)
class CalculationsData {
  final Crud crud;
  CalculationsData(this.crud);

  /// GET /api/calculations/history - list of saved calculations for current patient.
  Future<Either<StatusRequest, Map<String, dynamic>>> history({String? token}) async {
    return await crud.getData(ApiLinks.calculationsHistory, token: token);
  }

  /// GET /api/patients/{patientId}/calculations - for doctor to view a specific patient's calculations.
  Future<Either<StatusRequest, Map<String, dynamic>>> patientHistory({
    required int patientId,
    String? token,
  }) async {
    return await crud.getData(ApiLinks.doctorPatientCalculations(patientId), token: token);
  }

  /// POST /api/calculations/nutrition
  /// Body: weight, height, age, gender, activity_level, goal, save (optional)
  /// activity_level: "sedentary" | "low" | "moderate" | "active" | "very_active"
  /// goal: "maintain" | "lose" | "gain"
  Future<Either<StatusRequest, Map<String, dynamic>>> nutrition({
    required double weight,
    required double height,
    required int age,
    required String gender,
    required String activityLevel,
    String goal = "maintain",
    bool save = false,
    String? token,
  }) async {
    final body = {
      "weight": weight,
      "height": height,
      "age": age,
      "gender": gender,
      "activity_level": activityLevel,
      "goal": goal,
      "save": save,
    };
    return await crud.postData(ApiLinks.calculationsNutrition, body, token: token);
  }
}
