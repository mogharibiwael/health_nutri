import '../../../core/constant/api_link.dart';

class MedicalTestModel {
  final int id;
  final String name;
  /// API returns "image" - file path or URL for the uploaded test file
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

  /// Build every plausible URL for the file stored in [image].
  /// The API /download endpoint is tried first, then direct storage paths.
  List<String> get downloadUrls {
    final urls = <String>[];
    final seen = <String>{};

    void add(String? v) {
      if (v == null) return;
      final s = v.trim();
      if (s.isEmpty || seen.contains(s)) return;
      seen.add(s);
      urls.add(s);
    }

    // 1. Authenticated API download endpoint
    add(ApiLinks.medicalTestDownload(id));

    final img = image?.trim();

    if (img != null && img.isNotEmpty) {
      final base = ApiLinks.storageBase;

      if (img.startsWith('http://') || img.startsWith('https://')) {
        // Full URL returned directly from the API
        add(img);
        // Also try replacing /uploads/ with /storage/ in case the CDN differs
        add(img.replaceFirst(RegExp(r'/uploads/'), '/storage/'));
      } else {
        // Relative path — strip leading slash and known prefixes for manipulation
        final raw = img.startsWith('/') ? img.substring(1) : img;
        final withoutUploads = raw.replaceFirst(RegExp(r'^uploads/'), '');
        final withoutStorage = raw.replaceFirst(RegExp(r'^storage/'), '');

        // Most common Laravel combinations
        add('$base/storage/$withoutUploads');
        add('$base/storage/uploads/$withoutUploads');
        add('$base/$raw');
        add('$base/storage/$raw');
        add('$base/storage/$withoutStorage');
        add('$base/uploads/$withoutUploads');
      }
    }

    return urls;
  }

  factory MedicalTestModel.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic v) {
      if (v is int) return v;
      return int.tryParse(v.toString()) ?? 0;
    }

    final user = json["user"];
    final userName = user is Map ? (user["name"]?.toString()) : null;

    return MedicalTestModel(
      id: toInt(json["id"]),
      name: (json["name"] ?? "").toString(),
      image: json["image"]?.toString(),
      userId: json["user_id"] != null ? toInt(json["user_id"]) : null,
      doctorId: json["doctor_id"] != null ? toInt(json["doctor_id"]) : null,
      createdAt: json["created_at"]?.toString(),
      patientName: json["patient_name"]?.toString() ?? userName,
      status: json["status"]?.toString(),
    );
  }
}
