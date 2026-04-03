import 'package:dartz/dartz.dart';
import '../../../core/class/crud.dart';
import '../../../core/class/status_request.dart';
import '../../../core/constant/api_link.dart';

class AdsData {
  final Crud crud;
  AdsData(this.crud);

  /// GET /api/public/ads - List ads for carousel (no auth required)
  Future<Either<StatusRequest, Map<String, dynamic>>> fetchAds() async {
    return await crud.getData(ApiLinks.publicAds);
  }
}
