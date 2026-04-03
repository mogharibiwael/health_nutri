import 'package:nutri_guide/core/constant/api_link.dart';

import '../../../core/class/crud.dart';

class SignupData {
  final Crud crud;
  SignupData(this.crud);

  /// User payload: name, email, password, password_confirmation
  /// Doctor payload: + type, phone, gender, degree (file), cv (file), consultation_fee
  /// CV must be pdf, doc, or docx. Degree can be image or document.
  Future<dynamic> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    String? phone,
    String? type,
    String? gender,
    String? degreeFilePath,
    String? cvFilePath,
    double? consultationFee,
    String? bankAccount,
    String? specialization,
  }) async {
    final fields = <String, String>{
      "name": name,
      "email": email,
      "password": password,
      "password_confirmation": passwordConfirmation,
    };

    if (type == "doctor") {
      if (phone != null && phone.isNotEmpty) fields["phone"] = phone;
      if (gender != null && gender.isNotEmpty) fields["gender"] = gender;
      if (consultationFee != null) fields["consultation_fee"] = consultationFee.toString();
      if (bankAccount != null && bankAccount.isNotEmpty) fields["bank_account"] = bankAccount;
      if (specialization != null && specialization.isNotEmpty) fields["specialization"] = specialization;
      fields["type"] = "doctor";
    }

    final files = <MultipartFileField>[];
    if (type == "doctor") {
      if (degreeFilePath != null && degreeFilePath.isNotEmpty) {
        files.add(MultipartFileField(fieldName: "degree", filePath: degreeFilePath));
      }
      if (cvFilePath != null && cvFilePath.isNotEmpty) {
        files.add(MultipartFileField(fieldName: "cv", filePath: cvFilePath));
      }
    }

    if (files.isNotEmpty) {
      final response = await crud.postMultipart(
        ApiLinks.register,
        fields: fields,
        files: files,
      );
      return response.fold((l) => l, (r) => r);
    }

    final body = <String, dynamic>{};
    for (final e in fields.entries) {
      body[e.key] = e.value;
    }
    final response = await crud.postData(ApiLinks.register, body);
    return response.fold((l) => l, (r) => r);
  }
}
