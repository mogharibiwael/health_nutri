import 'package:dartz/dartz.dart';

import '../../../core/class/crud.dart';
import '../../../core/class/status_request.dart';
import '../../../core/constant/api_link.dart';

class PatientDoctorsData {
  final Crud crud;
  PatientDoctorsData(this.crud);

  /// GET /api/patients/my-doctors
  Future<Either<StatusRequest, Map<String, dynamic>>> getMyDoctors({String? token}) async {
    return await crud.getData(ApiLinks.patientMyDoctors, token: token);
  }
}

