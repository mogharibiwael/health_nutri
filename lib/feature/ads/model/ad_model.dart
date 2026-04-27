class AdModel {
  final int id;
  final String? title;
  final String? imageUrl;
  final String? link;
  final String? description;
  final String? phoneNumber;
  final String? type;
  final bool isActive;

  AdModel({
    required this.id,
    this.title,
    this.imageUrl,
    this.link,
    this.description,
    this.phoneNumber,
    this.type,
    this.isActive = true,
  });

  factory AdModel.fromJson(Map<String, dynamic> json, {String? storageBase}) {
    int _toInt(dynamic v) {
      if (v is int) return v;
      return int.tryParse(v.toString()) ?? 0;
    }

    String? rawImage = json["image_url"]?.toString() ??
        json["image"]?.toString() ??
        json["image_path"]?.toString() ??
        json["path"]?.toString();
    String? imageUrl = _normalizeImageUrl(rawImage, storageBase: storageBase);
    final bool isActive = _toBool(json["is_active"], fallback: true);

    return AdModel(
      id: _toInt(json["id"]),
      title: json["title"]?.toString(),
      imageUrl: imageUrl ?? rawImage,
      link: json["link"]?.toString(),
      description: json["description"]?.toString() ?? json["describtion"]?.toString(),
      phoneNumber: json["phone_number"]?.toString(),
      type: json["type"]?.toString(),
      isActive: isActive,
    );
  }

  static bool _toBool(dynamic v, {required bool fallback}) {
    if (v == null) return fallback;
    if (v is bool) return v;
    if (v is num) return v != 0;
    final s = v.toString().trim().toLowerCase();
    if (s.isEmpty) return fallback;
    if (s == 'true' || s == '1' || s == 'yes' || s == 'y') return true;
    if (s == 'false' || s == '0' || s == 'no' || s == 'n') return false;
    return fallback;
  }

  static String? _normalizeImageUrl(String? raw, {String? storageBase}) {
    if (raw == null) return null;
    var v = raw.trim();
    if (v.isEmpty) return null;

    // If already a full URL, just encode and return.
    if (v.startsWith('http://') || v.startsWith('https://')) {
      return Uri.encodeFull(v);
    }

    // Some deployments serve files directly under /uploads (not /storage).
    // If backend returns a path that includes /storage, strip it to match server config.
    // Example: /storage/uploads/x.png -> /uploads/x.png
    //          storage/uploads/x.png  -> uploads/x.png
    final lower = v.toLowerCase();
    if (lower.startsWith('/storage/')) {
      v = v.replaceFirst(RegExp(r'^/storage/', caseSensitive: false), '/');
    } else if (lower.startsWith('storage/')) {
      v = v.replaceFirst(RegExp(r'^storage/', caseSensitive: false), '');
    }

    // If it's a bare filename or relative path without a leading '/', assume it's under /uploads/
    if (!v.startsWith('/')) {
      if (!v.toLowerCase().startsWith('uploads/')) {
        v = 'uploads/$v';
      }
      v = '/$v';
    }

    if (storageBase == null || storageBase.trim().isEmpty) {
      return Uri.encodeFull(v);
    }

    final base = storageBase.endsWith('/') ? storageBase.substring(0, storageBase.length - 1) : storageBase;
    final path = v.startsWith('/') ? v : '/$v';
    return Uri.encodeFull('$base$path');
  }
}
