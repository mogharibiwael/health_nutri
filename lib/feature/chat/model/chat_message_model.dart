class ChatMessageModel {
  final int id;
  final int userId;
  final int doctorId;
  final String message;
  final DateTime createdAt;
  final bool isMe;
  final bool pending;
  final bool read;
  /// From API: "doctor" | "user" (patient). Used for layout: doctor = right, user = left.
  final String? senderType;

  ChatMessageModel({
    required this.id,
    required this.userId,
    required this.doctorId,
    required this.message,
    required this.createdAt,
    required this.isMe,
    this.pending = false,
    this.read = false,
    this.senderType,
  });

  /// True if sender_type is "doctor".
  bool get isFromDoctor =>
      (senderType ?? "").toString().toLowerCase().trim() == "doctor";

  ChatMessageModel copyWith({
    bool? pending,
    bool? read,
  }) {
    return ChatMessageModel(
      id: id,
      userId: userId,
      doctorId: doctorId,
      message: message,
      createdAt: createdAt,
      isMe: isMe,
      pending: pending ?? this.pending,
      read: read ?? this.read,
      senderType: senderType,
    );
  }

  factory ChatMessageModel.fromHistoryJson(Map<String, dynamic> json, {required int myUserId, int? myDoctorId}) {
    final uid = (json["user_id"] is int) ? json["user_id"] : int.tryParse("${json["user_id"]}") ?? 0;
    final did = (json["doctor_id"] is int) ? json["doctor_id"] : int.tryParse("${json["doctor_id"]}") ?? 0;
    final readRaw = (json["read"] ?? "false").toString().toLowerCase();
    final isRead = readRaw == "true" || readRaw == "1";
    final isMe = uid == myUserId || (myDoctorId != null && myDoctorId > 0 && did == myDoctorId);
    final senderTypeRaw = (json["sender_type"] ?? "").toString().trim().toLowerCase();
    final senderType = senderTypeRaw.isEmpty ? null : senderTypeRaw;

    return ChatMessageModel(
      id: (json["id"] is int) ? json["id"] : int.tryParse("${json["id"]}") ?? 0,
      userId: uid,
      doctorId: did,
      message: (json["message"] ?? "").toString(),
      createdAt: DateTime.tryParse((json["created_at"] ?? "").toString()) ?? DateTime.now(),
      isMe: isMe,
      read: isRead,
      senderType: senderType,
    );
  }
}
