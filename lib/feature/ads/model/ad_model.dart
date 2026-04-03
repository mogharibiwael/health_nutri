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
      isActive: json["is_active"] == true,
    );
  }
}
