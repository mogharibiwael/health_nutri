import 'package:dartz/dartz.dart';
import 'package:nutri_guide/core/constant/api_link.dart';
import '../../../core/class/status_request.dart';
import '../../../core/class/crud.dart';

class AthkarData {
  final Crud crud;
  AthkarData(this.crud);

  Future<Either<StatusRequest, Map<String, dynamic>>> fetchAthkar({
    int page = 1,
    String? category,
  }) async {
    var url = "${ApiLinks.publicAthkar}?page=$page";
    if (category != null && category.isNotEmpty) {
      url += "&category=$category";
    }
    return await crud.getData(url);
  }
}
