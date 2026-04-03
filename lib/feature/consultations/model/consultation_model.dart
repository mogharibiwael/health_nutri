class ConsultationModel {
  final int id;
  final int doctorId;
  final String? doctorName;
  final String consultationType; // initial, follow_up, review
  final String scheduledDate;
  final String? notes;
  final String? status;
  final String? createdAt;

  ConsultationModel({
    required this.id,
    required this.doctorId,
    this.doctorName,
    required this.consultationType,
    required this.scheduledDate,
    this.notes,
    this.status,
    this.createdAt,
  });

  factory ConsultationModel.fromJson(Map<String, dynamic> json) {
    int _toInt(dynamic v) {
      if (v is int) return v;
      return int.tryParse(v.toString()) ?? 0;
    }

    String? _extractDoctorName(Map<String, dynamic> json) {
      if (json["doctor"] is Map) {
        return (json["doctor"] as Map)["name"]?.toString();
      }
      return json["doctor_name"]?.toString();
    }

    return ConsultationModel(
      id: _toInt(json["id"]),
      doctorId: _toInt(json["doctor_id"]),
      doctorName: _extractDoctorName(json),
      consultationType: (json["consultation_type"] ?? "").toString(),
      scheduledDate: (json["scheduled_date"] ?? "").toString(),
      notes: json["notes"]?.toString(),
      status: json["status"]?.toString(),
      createdAt: json["created_at"]?.toString(),
    );
  }

  String get typeDisplay {
    switch (consultationType.toLowerCase()) {
      case "initial":
        return "Initial Consultation";
      case "follow_up":
        return "Follow-up";
      case "review":
        return "Review";
      default:
        return consultationType;
    }
  }
}
