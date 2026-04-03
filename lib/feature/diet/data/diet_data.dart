import 'package:dartz/dartz.dart';
import '../../../core/class/crud.dart';
import '../../../core/class/status_request.dart';
import '../../../core/constant/api_link.dart';

class DietData {
  final Crud crud;
  DietData(this.crud);

  /// GET /api/diets - Get all diets
  Future<Either<StatusRequest, Map<String, dynamic>>> getAllDiets({
    String? token,
    int page = 1,
  }) async {
    return await crud.getData(ApiLinks.diets, token: token, query: {"page": page});
  }

  /// POST /api/diets - Create new diet
  Future<Either<StatusRequest, Map<String, dynamic>>> createDiet({
    required Map<String, dynamic> body,
    String? token,
  }) async {
    return await crud.postData(ApiLinks.dietPlans, body, token: token);
  }

  /// GET /api/diets/{id} - Get specific diet
  Future<Either<StatusRequest, Map<String, dynamic>>> getDiet({
    required int dietId,
    String? token,
  }) async {
    return await crud.getData(ApiLinks.diet(dietId), token: token);
  }

  /// GET /api/diet-plans/{id} - Get full diet plan with meals (doctor/patient)
  Future<Either<StatusRequest, Map<String, dynamic>>> getDietPlan({
    required int planId,
    String? token,
  }) async {
    return await crud.getData(ApiLinks.dietPlan(planId), token: token);
  }

  /// PUT /api/diets/{id} - Update diet
  Future<Either<StatusRequest, Map<String, dynamic>>> updateDiet({
    required int dietId,
    required Map<String, dynamic> body,
    String? token,
  }) async {
    return await crud.putData(ApiLinks.diet(dietId), body, token: token);
  }

  /// DELETE /api/diets/{id} - Delete diet
  Future<Either<StatusRequest, Map<String, dynamic>>> deleteDiet({
    required int dietId,
    String? token,
  }) async {
    return await crud.deleteData(ApiLinks.diet(dietId), token: token);
  }

  /// PUT /api/diets/{id}/status - Change diet status
  Future<Either<StatusRequest, Map<String, dynamic>>> updateDietStatus({
    required int dietId,
    required String status,
    String? token,
  }) async {
    return await crud.putData(ApiLinks.dietStatus(dietId), {"status": status}, token: token);
  }

  /// GET /api/my-diet - Get current patient's diet
  Future<Either<StatusRequest, Map<String, dynamic>>> getMyDiet({
    String? token,
  }) async {
    return await crud.getData(ApiLinks.myDiet, token: token);
  }

  /// GET /api/my-diet/meals - Get diet meals
  Future<Either<StatusRequest, Map<String, dynamic>>> getMyDietMeals({
    String? token,
  }) async {
    return await crud.getData(ApiLinks.myDietMeals, token: token);
  }

  /// GET /api/diet-periods - Get diet periods
  Future<Either<StatusRequest, Map<String, dynamic>>> getDietPeriods({
    String? token,
  }) async {
    return await crud.getData(ApiLinks.dietPeriods, token: token);
  }

  /// GET /api/diet-components - Get diet components
  Future<Either<StatusRequest, Map<String, dynamic>>> getDietComponents({
    String? token,
  }) async {
    return await crud.getData(ApiLinks.dietComponents, token: token);
  }

  /// GET /api/diet-notes - Get diet notes
  Future<Either<StatusRequest, Map<String, dynamic>>> getDietNotes({
    String? token,
  }) async {
    return await crud.getData(ApiLinks.dietNotes, token: token);
  }

  /// GET /api/diet-types - Get diet types
  Future<Either<StatusRequest, Map<String, dynamic>>> getDietTypes({
    String? token,
  }) async {
    return await crud.getData(ApiLinks.dietTypes, token: token);
  }

  /// Create diet plan - uses POST /api/diet-plans
  Future<Either<StatusRequest, Map<String, dynamic>>> createDietPlan({
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
    String? token,
  }) async {
    final body = {
      "patient_id": patientId,
      "doctor_id": doctorId,
      "title": title,
      "daily_calories": dailyCalories,
      "duration_days": durationDays,
      "start_date": startDate,
      "end_date": endDate,
      if (meals != null && meals.isNotEmpty) "meals": meals,
      if (mealPeriods != null && mealPeriods.isNotEmpty) "meal_periods": mealPeriods,
      if (doctorNotes != null && doctorNotes.isNotEmpty) "doctor_notes": doctorNotes,
    };
    // Debug: verify payload before sending (remove after fixing patient_id)
    print("[DietData] POST diet-plans body: patient_id=$patientId, doctor_id=$doctorId");
    return await createDiet(body: body, token: token);
  }
}
