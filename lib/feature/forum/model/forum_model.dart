class ForumModel {
  final int id;
  final String name;
  final String? description;
  final String? createdAt;
  final int? doctorId;
  final String? doctorName;
  /// Whether the current user has joined this forum (from API or from users list).
  final bool isJoined;

  ForumModel({
    required this.id,
    required this.name,
    this.description,
    this.createdAt,
    this.doctorId,
    this.doctorName,
    this.isJoined = false,
  });

  /// [myUserId] optional: if API returns "users" list, we set isJoined when this user is in the list.
  factory ForumModel.fromJson(Map<String, dynamic> json, {int? myUserId}) {
    int? parseInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      return int.tryParse(v.toString());
    }

    final doctorJson = json["doctor"] is Map ? Map<String, dynamic>.from(json["doctor"]) : null;

    bool isJoined = false;
    if (json["is_joined"] is bool) {
      isJoined = json["is_joined"] as bool;
    } else if (json["has_joined"] is bool) {
      isJoined = json["has_joined"] as bool;
    } else if (myUserId != null && json["users"] is List) {
      final users = json["users"] as List;
      for (final u in users) {
        if (u is Map) {
          final id = parseInt(u["id"]);
          if (id == myUserId) {
            isJoined = true;
            break;
          }
        } else if (u is int && u == myUserId) {
          isJoined = true;
          break;
        }
      }
    }

    return ForumModel(
      id: (json["id"] is int) ? json["id"] : int.tryParse("${json["id"]}") ?? 0,
      name: (json["name"] ?? "-").toString(),
      description: json["description"]?.toString(),
      createdAt: json["created_at"]?.toString(),
      doctorId: parseInt(json["doctor_id"] ?? doctorJson?["id"]),
      doctorName: (doctorJson?["name"] ?? json["doctor_name"])?.toString(),
      isJoined: isJoined,
    );
  }
}
