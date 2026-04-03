import 'package:nutri_guide/core/class/crud.dart';
import 'package:nutri_guide/core/constant/api_link.dart';

class VerifyEmailData {
  final Crud crud;
  VerifyEmailData(this.crud);

  Future<dynamic> verify(String email, String code) async {
    final res = await crud.postData(ApiLinks.verifyEmail, {
      "email": email,
      "code": code,
    });
    return res.fold((l) => l, (r) => r);
  }

  /// Sends verification code to the given email (called after signup or for resend).
  Future<dynamic> sendVerificationCode(String email) async {
    final res = await crud.postData(ApiLinks.resendVerificationCode, {
      "email": email,
    });
    return res.fold((l) => l, (r) => r);
  }
}
