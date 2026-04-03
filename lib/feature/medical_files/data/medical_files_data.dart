import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import '../../../core/class/crud.dart';
import '../../../core/class/status_request.dart';
import '../../../core/constant/api_link.dart';

class MedicalFilesData {
  final Crud crud;

  MedicalFilesData(this.crud);

  /// GET /api/medical-files - Get paginated list of medical files
  Future<Either<StatusRequest, Map<String, dynamic>>> getMedicalFiles({
    String? token,
    int page = 1,
  }) async {
    return await crud.getData(
      ApiLinks.medicalFiles,
      token: token,
      query: {"page": page},
    );
  }

  /// Download file bytes from URL (uses same auth as other API calls)
  Future<Uint8List?> downloadFileBytes(String url, {String? token}) async {
    return await crud.getFileBytes(url, token: token);
  }
}
