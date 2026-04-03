import 'package:dartz/dartz.dart';
import '../../../core/class/crud.dart';
import '../../../core/class/status_request.dart';
import '../../../core/constant/api_link.dart';

class ConsultationsData {
  final Crud crud;
  ConsultationsData(this.crud);

  /// GET /api/consultations - List all consultations for logged-in user
  Future<Either<StatusRequest, Map<String, dynamic>>> getConsultations({
    int page = 1,
    String? token,
  }) async {
    final url = "${ApiLinks.consultations}?page=$page";
    return await crud.getData(url, token: token);
  }

  /// POST /api/consultations - Request a new consultation session
  Future<Either<StatusRequest, Map<String, dynamic>>> requestConsultation({
    required int doctorId,
    required String consultationType, // initial, follow_up, review
    required String scheduledDate, // "2024-12-25 14:30:00"
    String? notes,
    String? token,
  }) async {
    final body = {
      "doctor_id": doctorId,
      "consultation_type": consultationType,
      "scheduled_date": scheduledDate,
      if (notes != null && notes.isNotEmpty) "notes": notes,
    };
    return await crud.postData(ApiLinks.consultations, body, token: token);
  }
}
