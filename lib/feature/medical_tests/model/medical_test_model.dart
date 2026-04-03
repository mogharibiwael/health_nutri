import '../../../core/constant/api_link.dart';

class MedicalTestModel {
  final int id;
  final String name;
  /// API returns "image" - file path or URL
  final String? image;
  final int? userId;
  final int? doctorId;
  final String? createdAt;
  final String? patientName;
  final String? status;

  MedicalTestModel({
    required this.id,
    required this.name,
    this.image,
    this.userId,
    this.doctorId,
    this.createdAt,
    this.patientName,
    this.status,
  });

  /// Use download endpoint; if image is full URL, could use that instead
  String get downloadUrl => ApiLinks.medicalTestDownload(id);

  factory MedicalTestModel.fromJson(Map<String, dynamic> json) {
    int _toInt(dynamic v) {
      if (v is int) return v;
      return int.tryParse(v.toString()) ?? 0;
    }

    final user = json["user"];
    final userName = user is Map ? (user["name"]?.toString()) : null;

    return MedicalTestModel(
      id: _toInt(json["id"]),
      name: (json["name"] ?? "").toString(),
      image: json["image"]?.toString(),
      userId: json["user_id"] != null ? _toInt(json["user_id"]) : null,
      doctorId: json["doctor_id"] != null ? _toInt(json["doctor_id"]) : null,
      createdAt: json["created_at"]?.toString(),
      patientName: json["patient_name"]?.toString() ?? userName,
      status: json["status"]?.toString(),
    );
  }
}
