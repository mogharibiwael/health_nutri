import '../../../core/class/crud.dart';
import '../../../core/constant/api_link.dart';

class MedicalTestsData {
  final Crud crud;
  MedicalTestsData(this.crud);

  /// GET /api/medical-tests - Patient: own tests. Doctor: pass user_id for patient's tests.
  Future<dynamic> getMedicalTests({
    int? userId,
    String? token,
    int page = 1,
  }) async {
    final query = <String, String>{"page": page.toString()};
    if (userId != null && userId > 0) {
      query["user_id"] = userId.toString();
    }
    final qs = query.entries.map((e) => "${e.key}=${e.value}").join("&");
    final url = "${ApiLinks.medicalTests}?$qs";
    return crud.getData(url, token: token);
  }
}
