import 'package:dartz/dartz.dart';
import 'package:nutri_guide/core/constant/api_link.dart';
import '../../../core/class/crud.dart';
import '../../../core/class/status_request.dart';

class DoctorsData {
  final Crud crud;
  DoctorsData(this.crud);

  /// GET public/doctors - no auth required (avoids 401)
  Future<Either<StatusRequest, Map<String, dynamic>>> fetchDoctors({
    String? token,
  }) async {
    final url = ApiLinks.publicDoctors;
    return await crud.getData(url); // no token for public endpoint
  }

  /// GET /doctor/{id}/rates - fetch doctor's aggregate rating (average, count)
  Future<Either<StatusRequest, Map<String, dynamic>>> getDoctorRates({
    required int doctorId,
    String? token,
  }) async {
    final url = ApiLinks.doctorRates(doctorId);
    return await crud.getData(url, token: token);
  }

  /// GET /my-rates?doctor_id=X - fetch current user's rating for this doctor
  Future<Either<StatusRequest, Map<String, dynamic>>> getMyRate({
    required int doctorId,
    String? token,
  }) async {
    final url = "${ApiLinks.myRates}?doctor_id=$doctorId";
    return await crud.getData(url, token: token);
  }

  /// POST /doctors/{id}/rate - submit rating (patient must be subscribed). Body: rate (1-5)
  Future<Either<StatusRequest, Map<String, dynamic>>> submitDoctorRate({
    required int doctorId,
    required int rate,
    String? token,
  }) async {
    final url = ApiLinks.doctorRate(doctorId);
    return await crud.postData(url, {"rate": rate}, token: token);
  }
}
