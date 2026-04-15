import '../../../core/constant/api_link.dart';

/// Local (asset) PDF file shown in "Medical Files" screen.
class AssetMedicalFileModel {
  final String assetPath; // e.g. assets/files/guide.pdf

  const AssetMedicalFileModel({required this.assetPath});

  String get fileName {
    final p = assetPath.replaceAll('\\', '/');
    return p.split('/').isNotEmpty ? p.split('/').last : assetPath;
  }

  String get baseName {
    final name = fileName;
    final dot = name.lastIndexOf('.');
    return dot > 0 ? name.substring(0, dot) : name;
  }

  String get displayName {
    switch (baseName.toLowerCase()) {
      case 'alter':
        return 'نظام البدائل';
      case 'jurd':
        return 'الكتاب الاردني للتغذية';
      case 'krause':
        return 'krause';
      default:
        return baseName;
    }
  }
}

class MedicalFileModel {
  final int id;
  final int? patientId;
  final String fileName;
  final String filePath;
  final String fileType;
  final int fileSize;
  final String? description;
  final String? uploadedAt;
  final String? status;
  final String? downloadUrl; // Full URL from backend if provided

  MedicalFileModel({
    required this.id,
    this.patientId,
    required this.fileName,
    required this.filePath,
    required this.fileType,
    required this.fileSize,
    this.description,
    this.uploadedAt,
    this.status,
    this.downloadUrl,
  });

  /// Laravel storage URL: domain.com/storage/uploads/...
  String get storageUrl {
    final base = ApiLinks.storageBase;
    final path = filePath.startsWith('/') ? filePath.substring(1) : filePath;
    return '$base/storage/$path';
  }

  /// Direct URL: domain.com/uploads/... (when files are in public/uploads)
  String get directUrl {
    final base = ApiLinks.storageBase;
    final path = filePath.startsWith('/') ? filePath : '/$filePath';
    return '$base$path';
  }

  /// API path for file (some backends serve at /api/...)
  String get apiStorageUrl {
    final base = ApiLinks.storageBase;
    final path = filePath.startsWith('/') ? filePath.substring(1) : filePath;
    return '$base/api/storage/$path';
  }

  /// URL via API base (some backends: domain.com/api/uploads/...)
  String get apiUploadsUrl {
    final base = ApiLinks.storageBase.replaceFirst(RegExp(r'/api$'), '');
    final path = filePath.startsWith('/') ? filePath : '/$filePath';
    return '$base/api$path';
  }

  /// All possible download URLs to try (backend URL first if provided).
  /// Tries direct/storage URLs first (common Laravel), then API download endpoint.
  List<String> get downloadUrls {
    final urls = <String>[];
    final seen = <String>{};
    void addUrl(String? value) {
      if (value == null) return;
      final v = value.trim();
      if (v.isEmpty || seen.contains(v)) return;
      seen.add(v);
      urls.add(v);
    }

    final rawPath = filePath.trim();
    final normalizedPath = rawPath.startsWith('/') ? rawPath.substring(1) : rawPath;
    final withoutUploadsPrefix = normalizedPath.replaceFirst(RegExp(r'^uploads/'), '');
    final base = ApiLinks.storageBase;

    if (downloadUrl != null && downloadUrl!.trim().isNotEmpty) {
      addUrl(downloadUrl);
    }

    // Try direct and storage URLs first (files in public/ or storage link)
    addUrl(directUrl);
    addUrl(storageUrl);
    addUrl('$base/storage/$normalizedPath');
    addUrl('$base/storage/uploads/$withoutUploadsPrefix');
    addUrl('$base/uploads/$withoutUploadsPrefix');

    // API endpoint and API path variants
    addUrl(ApiLinks.medicalFileDownload(id));
    addUrl(apiUploadsUrl);
    addUrl(apiStorageUrl);

    return urls;
  }

  String get fileSizeFormatted {
    if (fileSize < 1024) return '$fileSize B';
    if (fileSize < 1024 * 1024) return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  factory MedicalFileModel.fromJson(Map<String, dynamic> json) {
    int _toInt(dynamic v) {
      if (v is int) return v;
      return int.tryParse(v.toString()) ?? 0;
    }

    return MedicalFileModel(
      id: _toInt(json["id"]),
      patientId: json["patient_id"] != null ? _toInt(json["patient_id"]) : null,
      fileName: (json["file_name"] ?? "").toString(),
      filePath: (json["file_path"] ?? "").toString(),
      fileType: (json["file_type"] ?? "pdf").toString().toLowerCase(),
      fileSize: _toInt(json["file_size"] ?? 0),
      description: json["description"]?.toString(),
      uploadedAt: json["uploaded_at"]?.toString(),
      status: json["status"]?.toString(),
      downloadUrl: json["download_url"]?.toString() ?? json["url"]?.toString(),
    );
  }
}
