import 'package:dartz/dartz.dart';
import 'package:nutri_guide/core/constant/api_link.dart';
import '../../../core/class/status_request.dart';
import '../../../core/class/crud.dart';

class TipsData {
  final Crud crud;
  TipsData(this.crud);

  Future<Either<StatusRequest, Map<String, dynamic>>> fetchTips({
    required int page,
    String? token,
    int? categoryId,
  }) async {
    return await crud.getData(
      ApiLinks.publicTips,
      token: token,
      query: {
        "page": page,
        if (categoryId != null && categoryId > 0) "category_id": categoryId,
      },
    );
  }
}
