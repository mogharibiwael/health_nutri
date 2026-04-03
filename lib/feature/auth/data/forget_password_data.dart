import 'package:get/get.dart';
import '../../../core/class/crud.dart';
import '../../../core/constant/api_link.dart';

class ForgotPasswordData {
  final Crud crud;
  ForgotPasswordData(this.crud);

  Future<dynamic> sendResetLink(String email) async {
    final body = {"email": email};

    final res = await crud.postData(ApiLinks.forgotPassword, body, token: null);
    return res;
  }
}
