import 'package:flutter/foundation.dart';
import 'package:nutri_guide/core/constant/api_link.dart';

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
  /// Attachment path or URL (from API). If it's a relative path, UI prefixes storage base.
  final String? attachment;
  /// Local attachment path (optimistic UI while uploading).
  final String? localAttachmentPath;

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
    this.attachment,
    this.localAttachmentPath,
  });

  /// True if sender_type is "doctor".
  bool get isFromDoctor =>
      (senderType ?? "").toString().toLowerCase().trim() == "doctor";

  /// Local path takes priority (optimistic), falls back to API attachment.
  String? get effectiveAttachment =>
      (localAttachmentPath != null && localAttachmentPath!.isNotEmpty)
          ? localAttachmentPath
          : attachment;

  bool get hasAttachment =>
      effectiveAttachment != null && effectiveAttachment!.trim().isNotEmpty;

  bool get isImageAttachment {
    final a = effectiveAttachment;
    if (a == null) return false;
    // strip query string before checking extension
    final lower = a.split('?').first.toLowerCase();
    return lower.endsWith('.png') ||
        lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.webp') ||
        lower.endsWith('.gif');
  }

  /// Build a full, usable URL from the API attachment field.
  String? get attachmentUrl {
    final a = attachment;
    if (a == null || a.trim().isEmpty) return null;
    final v = a.trim();

    // Already a full URL — encode and return.
    if (v.startsWith('http://') || v.startsWith('https://')) {
      return Uri.encodeFull(v);
    }

    final base = ApiLinks.storageBase; // e.g. https://host.com

    // Absolute path from root (starts with /)
    if (v.startsWith('/')) {
      // /storage/... → keep as-is; /uploads/... → swap to /storage/...
      final normalized = v.startsWith('/uploads/')
          ? v.replaceFirst('/uploads/', '/storage/')
          : v;
      return Uri.encodeFull('$base$normalized');
    }

    // Relative path (e.g. "chat-files/...", "uploads/chat-files/...", "storage/chat-files/...")
    String rel = v;
    if (rel.startsWith('uploads/')) {
      // uploads/chat-files/... → storage/chat-files/...
      rel = 'storage/${rel.substring('uploads/'.length)}';
    } else if (!rel.startsWith('storage/')) {
      // chat-files/..., images/... etc → storage/chat-files/...
      rel = 'storage/$rel';
    }
    // rel now starts with "storage/..."
    return Uri.encodeFull('$base/$rel');
  }

  ChatMessageModel copyWith({
    bool? pending,
    bool? read,
    String? attachment,
    String? localAttachmentPath,
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
      attachment: attachment ?? this.attachment,
      localAttachmentPath: localAttachmentPath ?? this.localAttachmentPath,
    );
  }

  /// Try every plausible key that backends use for file attachments.
  static String? _extractAttachment(Map<String, dynamic> json) {
    const keys = [
      "file",
      "file_path",
      "file_url",
      "attachment",
      "attachment_path",
      "attachment_url",
      "media",
      "media_url",
      "image",
      "image_url",
    ];
    for (final k in keys) {
      final v = json[k];
      if (v == null) continue;
      final s = v.toString().trim();
      if (s.isNotEmpty) return s;
    }
    return null;
  }

  factory ChatMessageModel.fromHistoryJson(
    Map<String, dynamic> json, {
    required int myUserId,
    int? myDoctorId,
  }) {
    final uid = (json["user_id"] is int)
        ? json["user_id"] as int
        : int.tryParse("${json["user_id"]}") ?? 0;
    final did = (json["doctor_id"] is int)
        ? json["doctor_id"] as int
        : int.tryParse("${json["doctor_id"]}") ?? 0;
    final readRaw = (json["read"] ?? "false").toString().toLowerCase();
    final isRead = readRaw == "true" || readRaw == "1";
    final isMe = uid == myUserId ||
        (myDoctorId != null && myDoctorId > 0 && did == myDoctorId);
    final senderTypeRaw =
        (json["sender_type"] ?? "").toString().trim().toLowerCase();
    final senderType = senderTypeRaw.isEmpty ? null : senderTypeRaw;

    final extractedAttachment = _extractAttachment(json);

    // ── Debug logging ──────────────────────────────────────────────────────
    debugPrint(
      '[ChatMessage] id=${json["id"]}  '
      'keys=${json.keys.toList()}  '
      'attachment=$extractedAttachment  '
      'message=${(json["message"] ?? "").toString().substring(0, ((json["message"] ?? "").toString().length).clamp(0, 60))}',
    );
    if (extractedAttachment != null) {
      final model = ChatMessageModel(
        id: 0,
        userId: uid,
        doctorId: did,
        message: '',
        createdAt: DateTime.now(),
        isMe: isMe,
        attachment: extractedAttachment,
      );
      debugPrint(
        '[ChatMessage] → attachmentUrl=${model.attachmentUrl}  '
        'isImage=${model.isImageAttachment}',
      );
    }
    // ───────────────────────────────────────────────────────────────────────

    return ChatMessageModel(
      id: (json["id"] is int)
          ? json["id"] as int
          : int.tryParse("${json["id"]}") ?? 0,
      userId: uid,
      doctorId: did,
      message: (json["message"] ?? "").toString(),
      createdAt:
          DateTime.tryParse((json["created_at"] ?? "").toString()) ??
              DateTime.now(),
      isMe: isMe,
      read: isRead,
      senderType: senderType,
      attachment: extractedAttachment,
    );
  }
}
