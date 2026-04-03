import 'package:dartz/dartz.dart';
import 'package:nutri_guide/core/class/crud.dart';

import '../../../core/class/status_request.dart';
import '../../../core/constant/api_link.dart';

class LoginData {
  final Crud crud;
  LoginData(this.crud);

  /// [allowPendingDoctor] when true: backend may return token for doctors not yet approved by admin (app allows them in; approval only affects "My clinic").
  Future<Either<StatusRequest, Map<String, dynamic>>> getData(
      String email, String password, {bool allowPendingDoctor = true}) async {
    final body = <String, dynamic>{
      "email": email,
      "password": password,
    };
    if (allowPendingDoctor) {
      body["allow_pending_doctor"] = true;
    }
    return await crud.postData(ApiLinks.login, body);
  }
}

