import 'package:dartz/dartz.dart';
import '../../../core/class/crud.dart';
import '../../../core/class/status_request.dart';
import '../../../core/constant/api_link.dart';

class PatientProfileData {
  final Crud crud;
  PatientProfileData(this.crud);

  Future<Either<StatusRequest, Map<String, dynamic>>> updateProfile(
    Map<String, dynamic> body, {
    required String? token,
  }) async {
    return await crud.putData(ApiLinks.patientProfile, body, token: token);
  }

  /// GET /patients/profile - fetch current patient's profile (height, weight, etc.)
  Future<Either<StatusRequest, Map<String, dynamic>>> getProfile({
    required String? token,
  }) async {
    return await crud.getData(ApiLinks.patientProfile, token: token);
  }
}
