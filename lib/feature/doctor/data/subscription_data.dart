import 'dart:io';
import 'package:nutri_guide/core/constant/api_link.dart';

import '../../../core/class/crud.dart';

class SubscriptionData {
  final Crud crud;
  SubscriptionData(this.crud);

  /// GET /api/users-subscribed - fetch doctors this user subscribed to
  Future<dynamic> getMySubscriptions({String? token}) async {
    return await crud.getData(ApiLinks.usersSubscribed, token: token);
  }

  Future<dynamic> createSubscription(Map<String, dynamic> body, {File? receiptImage, String? token}) async {
    if (receiptImage == null) {
      return await crud.postData(ApiLinks.subscriptions, body, token: token);
    }
    return await crud.postMultipart(
      ApiLinks.subscriptions,
      fields: body.map((k, v) => MapEntry(k, v.toString())),
      files: [
        MultipartFileField(fieldName: "receipt_image", filePath: receiptImage.path),
      ],
      token: token,
    );
  }
}
