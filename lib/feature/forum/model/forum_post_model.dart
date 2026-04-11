class ForumPostModel {
  final int id;
  final int forumId;
  final int userId;
  final String? title;  // optional - API doc: POST only sends content
  final String content;
  final String? userName;
  final String? userImage;
  final int likesCount;
  final bool isLiked;
  final String? createdAt;

  ForumPostModel({
    required this.id,
    required this.forumId,
    required this.userId,
    this.title,
    required this.content,
    this.userName,
    this.userImage,
    this.likesCount = 0,
    this.isLiked = false,
    this.createdAt,
  });

  factory ForumPostModel.fromJson(Map<String, dynamic> json) {
    // Extract user name from nested user object if available
    String? uName;
    if (json["user"] is Map) {
      uName = (json["user"] as Map)["name"]?.toString();
    }
    uName ??= json["user_name"]?.toString();

    // Extract user image
    String? uImage;
    if (json["user"] is Map) {
      final u = json["user"] as Map;
      final pat = u["patient"] ?? u["patient_profile"] ?? u["patientProfile"];
      if (pat is Map && pat["image"] != null) uImage = pat["image"].toString();
      final doc = u["doctor"] ?? u["doctor_profile"] ?? u["doctorProfile"];
      if (doc is Map && doc["profile_image"] != null) uImage = doc["profile_image"].toString();
    }
    uImage ??= json["user_image"]?.toString();

    return ForumPostModel(
      id: (json["id"] is int) ? json["id"] : int.tryParse("${json["id"]}") ?? 0,
      forumId: (json["forum_id"] is int) ? json["forum_id"] : int.tryParse("${json["forum_id"]}") ?? 0,
      userId: (json["user_id"] is int) ? json["user_id"] : int.tryParse("${json["user_id"]}") ?? 0,
      title: json["title"]?.toString(),
      content: (json["content"] ?? json["body"] ?? "").toString(),
      userName: uName,
      userImage: uImage,
      likesCount: (json["likes_count"] is int)
          ? json["likes_count"]
          : int.tryParse("${json["likes_count"]}") ?? 0,
      isLiked: json["is_liked"] == true || json["is_liked"] == 1,
      createdAt: json["created_at"]?.toString(),
    );
  }

  ForumPostModel copyWith({
    int? likesCount,
    bool? isLiked,
  }) {
    return ForumPostModel(
      id: id,
      forumId: forumId,
      userId: userId,
      title: title,
      content: content,
      userName: userName,
      userImage: userImage,
      likesCount: likesCount ?? this.likesCount,
      isLiked: isLiked ?? this.isLiked,
      createdAt: createdAt,
    );
  }
}
