import 'dart:convert';

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

    String? rawImage = json["image_url"]?.toString() ?? json["image"]?.toString();
    String? imageUrl = rawImage;
    if (imageUrl != null && imageUrl.isNotEmpty && storageBase != null) {
      final base = storageBase.endsWith("/") ? storageBase : "$storageBase/";
      imageUrl = imageUrl.startsWith("http") ? imageUrl : "$base$imageUrl";
    }

    return AdModel(
      id: _toInt(json["id"]),
      title: json["title"]?.toString(),
      imageUrl: imageUrl ?? rawImage,
      link: json["link"]?.toString(),
      description: json["description"]?.toString() ?? json["describtion"]?.toString(),
      phoneNumber: json["phone_number"]?.toString(),
      type: json["type"]?.toString(),
      isActive: json["is_active"] == true, // check this!
    );
  }
}

void main() {
  String jsonStr = '''[
  {
    "id": 6,
    "admin_id": 1,
    "date": "2026-03-28 17:42:25",
    "image": "uploads/advertisements/1774719745_letter-s-spider-logo-design_445285-689.webp",
    "describtion": "ششششششششش",
    "phone_number": "798789",
    "type": "عرض",
    "GPS": "78978989",
    "created_at": "2026-03-28T17:42:25.000000Z",
    "updated_at": "2026-03-28T17:42:25.000000Z",
    "is_active": true
  },
  {
    "id": 1,
    "admin_id": 1,
    "date": null,
    "image": null,
    "describtion": null,
    "phone_number": null,
    "type": null,
    "GPS": null,
    "created_at": "2026-03-27T07:10:21.000000Z",
    "updated_at": "2026-03-27T07:10:21.000000Z",
    "is_active": 1
  }
]''';

  List rawList = jsonDecode(jsonStr);
  List<AdModel> ads = [];

  for (final e in rawList) {
    if (e is Map<String, dynamic>) {
      final ad = AdModel.fromJson(e, storageBase: "https://base.com");
      print("Parsed Ad id: \${ad.id}, isActive: \${ad.isActive}, image: \${ad.imageUrl}");
      if (ad.isActive && ad.imageUrl != null && ad.imageUrl!.isNotEmpty) {
        ads.add(ad);
      }
    } else if (e is Map) {
      final ad = AdModel.fromJson(Map<String, dynamic>.from(e), storageBase: "https://base.com");
      print("Parsed Ad id: \${ad.id}, isActive: \${ad.isActive}, image: \${ad.imageUrl}");
      if (ad.isActive && ad.imageUrl != null && ad.imageUrl!.isNotEmpty) {
        ads.add(ad);
      }
    }
  }

  print("Total ads added: \${ads.length}");
}
