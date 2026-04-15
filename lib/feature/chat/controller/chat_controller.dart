import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/class/status_request.dart';
import '../../../core/function/handel_data.dart';
import '../../../core/service/notification_service.dart';
import '../../../core/service/serviecs.dart';
import '../data/chat_data.dart';
import '../model/chat_message_model.dart';

class ChatController extends GetxController {
  final MyServices myServices = Get.find();
  final ChatData chatData = ChatData(Get.find());

  late final int doctorId;     // used for /chat/history/{doctorId}
  late int receiverId;         // REQUIRED by POST /chat/messages
  String doctorName = "";

  int myUserId = 0;

  /// IMPORTANT:
  /// If backend expects conversation_id and you don't have it,
  /// we fallback to doctorId (because history endpoint is keyed by doctorId).
  late int conversationId;

  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  /// Selected file for upload (path and display name)
  String? attachedFilePath;
  String? attachedFileName;

  StatusRequest statusRequest = StatusRequest.loading; // history loading
  StatusRequest sendStatus = StatusRequest.success;

  final List<ChatMessageModel> messages = [];
  bool get isSending => sendStatus == StatusRequest.loading;

  bool get isCurrentUserDoctor => (myServices.type ?? "").toLowerCase() == "doctor";

  int currentPage = 1;
  bool hasMore = true;

  Timer? _pollingTimer;
  int _lastReadMessageId = 0;

  @override
  void onInit() {
    super.onInit();

    final args = (Get.arguments as Map?) ?? {};

    doctorId = (args["doctor_id"] is int)
        ? args["doctor_id"]
        : int.tryParse("${args["doctor_id"]}") ?? 0;

    doctorName = (args["doctor_name"] ?? "").toString();

    // If you passed receiver_id from previous screen keep it,
    // BUT if it's missing we default receiver_id to doctorId (most common for your backend).
    receiverId = (args["receiver_id"] is int)
        ? args["receiver_id"]
        : int.tryParse("${args["receiver_id"]}") ?? 0;

    conversationId = (args["conversation_id"] is int)
        ? args["conversation_id"]
        : int.tryParse("${args["conversation_id"]}") ?? 0;

    if (conversationId == 0) conversationId = doctorId;

    // ✅ Fallback for receiver_id
    // Your backend error says receiver_id is required, and history returns doctor_id.
    // So for patient->doctor messages, receiver_id is most likely doctorId.
    if (receiverId == 0) receiverId = doctorId;

    _loadMyUserId();
    loadHistory(first: true).then((_) {
      _startPolling();
    });
  }

  void _loadMyUserId() {
    final u = myServices.user;
    final id = u?["id"];
    if (id is int) myUserId = id;
    if (id is String) myUserId = int.tryParse(id) ?? 0;
  }

  Future<void> loadHistory({bool first = false}) async {
    if (doctorId == 0) {
      statusRequest = StatusRequest.failure;
      update();
      return;
    }

    if (first) {
      currentPage = 1;
      hasMore = true;
      messages.clear();
      statusRequest = StatusRequest.loading;
      update();
    }

    final isDoctor = (myServices.type ?? "").toLowerCase() == "doctor";

    final res = await chatData.getHistory(
      doctorId: doctorId,
      page: currentPage,
      receiverId: receiverId > 0 ? receiverId : null,
      isDoctor: isDoctor,
      token: myServices.token,
    );

    statusRequest = handelData(res);
    update();

    res.fold(
          (l) {
        statusRequest = l;
        update();
      },
          (r) {
        // Support both "data" and "messages" response keys (some backends use "messages")
        List? rawList = r["data"] as List?;
        if (rawList == null || rawList.isEmpty) {
          rawList = r["messages"] as List?;
        }
        final list = rawList ?? [];

        final myDoctorId = myServices.doctorId;
        final newMsgs = list
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .map((e) => ChatMessageModel.fromHistoryJson(e, myUserId: myUserId, myDoctorId: myDoctorId))
            .toList();

        // sort ascending by createdAt for UI
        newMsgs.sort((a, b) => a.createdAt.compareTo(b.createdAt));

        messages
          ..clear()
          ..addAll(newMsgs);

        statusRequest = StatusRequest.success;
        update();
        _scrollToBottom();
      },
    );
  }

  Future<void> refreshHistory() async => loadHistory(first: true);

  void clearAttachment() {
    attachedFilePath = null;
    attachedFileName = null;
    update();
  }

  Future<void> pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? xFile = await picker.pickImage(source: ImageSource.gallery);
      if (xFile != null) {
        attachedFilePath = xFile.path;
        attachedFileName = xFile.name;
        update();
      }
    } catch (e) {
      Get.snackbar("Error", "Could not pick image");
    }
  }

  Future<void> pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );
      if (result != null && result.files.isNotEmpty) {
        final f = result.files.first;
        final path = f.path;
        if (path != null && path.isNotEmpty) {
          attachedFilePath = path;
          attachedFileName = f.name;
          update();
        } else {
          Get.snackbar("Error", "File path not available");
        }
      }
    } catch (e) {
      Get.snackbar("Error", "Could not pick file");
    }
  }

  Future<void> send() async {
    if (isSending) return;

    final text = messageController.text.trim();
    final hasFile = attachedFilePath != null && attachedFilePath!.isNotEmpty;
    // keep in case you later want image-specific UX (preview, compression, etc.)
    // ignore: unused_local_variable
    final isImage = hasFile &&
        ((attachedFileName ?? attachedFilePath ?? "").toLowerCase().endsWith(".png") ||
            (attachedFileName ?? attachedFilePath ?? "").toLowerCase().endsWith(".jpg") ||
            (attachedFileName ?? attachedFilePath ?? "").toLowerCase().endsWith(".jpeg") ||
            (attachedFileName ?? attachedFilePath ?? "").toLowerCase().endsWith(".webp") ||
            (attachedFileName ?? attachedFilePath ?? "").toLowerCase().endsWith(".gif"));

    if (text.isEmpty && !hasFile) return;

    if (receiverId == 0) {
      Get.snackbar("Error", "Missing receiver_id");
      return;
    }

    final messageText = text.isEmpty ? (hasFile ? "" : "(Attachment)") : text;

    // optimistic
    final optimistic = ChatMessageModel(
      id: -DateTime.now().millisecondsSinceEpoch,
      userId: myUserId,
      doctorId: doctorId,
      message: messageText.isEmpty ? "(Attachment)" : messageText,
      createdAt: DateTime.now(),
      isMe: true,
      pending: true,
      localAttachmentPath: hasFile ? attachedFilePath : null,
    );

    messages.add(optimistic);
    messageController.clear();
    final fileToSend = attachedFilePath;
    final fileNameToSend = attachedFileName;
    clearAttachment();
    update();
    _scrollToBottom();

    sendStatus = StatusRequest.loading;
    update();
    _scrollToBottom();
    Future.microtask(() => _markVisibleUnreadAsRead());

    if (fileToSend != null && File(fileToSend).existsSync()) {
      final res = await chatData.sendMessageWithFile(
        conversationId: conversationId,
        receiverId: receiverId,
        message: messageText,
        filePath: fileToSend,
        fileName: fileNameToSend,
        token: myServices.token,
      );
      res.fold(
        (l) {
          sendStatus = StatusRequest.success;
          messages.remove(optimistic);
          update();
          Get.snackbar("Error", _mapStatus(l));
        },
        (r) async {
          // If a patient is sending a file, keep a copy in medical-tests (الفحص الطبي)
          if (!isCurrentUserDoctor && fileToSend != null) {
            try {
              final inferredName = (messageText.trim().isNotEmpty
                      ? messageText.trim()
                      : (fileNameToSend?.trim().isNotEmpty == true ? fileNameToSend!.trim() : "Medical Test"))
                  .replaceAll(RegExp(r'\\s+'), ' ');

              await chatData.uploadMedicalTest(
                name: inferredName,
                filePath: fileToSend,
                fileName: fileNameToSend,
                doctorId: doctorId,
                userId: myUserId,
                token: myServices.token,
              );
            } catch (e) {
              debugPrint("Failed to copy file to medical tests: $e");
            }
          }
          sendStatus = StatusRequest.success;
          update();
          await refreshHistory();
        },
      );
    } else {
      final res = await chatData.sendMessage(
        conversationId: conversationId,
        receiverId: receiverId,
        message: messageText,
        token: myServices.token,
      );
      res.fold(
        (l) {
          sendStatus = StatusRequest.success;
          messages.remove(optimistic);
          update();
          Get.snackbar("Error", _mapStatus(l));
        },
        (r) async {
          sendStatus = StatusRequest.success;
          update();
          await refreshHistory();
        },
      );
    }
  }

  String _mapStatus(StatusRequest s) {
    if (s == StatusRequest.offlineFailure) return "No internet connection";
    if (s == StatusRequest.serverFailure) return "Server error";
    return "Failed";
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!scrollController.hasClients) return;
      // During rebuilds/refresh, the controller can briefly be attached twice.
      // Avoid the assertion by waiting for a single attached position.
      if (scrollController.positions.length != 1) return;
      scrollController.animateTo(
        scrollController.position.maxScrollExtent + 120,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void onClose() {
    _pollingTimer?.cancel();
    messageController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (statusRequest != StatusRequest.loading) {
        _pollNewMessages();
      }
    });
  }

  Future<void> _pollNewMessages() async {
    final isDoctor = (myServices.type ?? "").toLowerCase() == "doctor";
    final res = await chatData.getHistory(
      doctorId: doctorId,
      page: 1, // Only check first page
      receiverId: receiverId > 0 ? receiverId : null,
      isDoctor: isDoctor,
      token: myServices.token,
    );

    res.fold(
      (l) => null,
      (r) {
        List? rawList = r["data"] as List?;
        if (rawList == null || rawList.isEmpty) {
          rawList = r["messages"] as List?;
        }
        final list = rawList ?? [];
        final myDoctorId = myServices.doctorId;

        bool hasNew = false;
        for (var e in list) {
          final m = ChatMessageModel.fromHistoryJson(Map<String, dynamic>.from(e), myUserId: myUserId, myDoctorId: myDoctorId);
          
          // If message is new and not mine
          if (!messages.any((existing) => existing.id == m.id)) {
            messages.add(m);
            hasNew = true;
            
            if (!m.isMe) {
               _showNotification(m);
            }
          }
        }

        if (hasNew) {
          messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
          update();
          _scrollToBottom();
        }
      },
    );
  }

  void _showNotification(ChatMessageModel msg) {
     // Don't show notification if app is in background? 
     // Local notifications usually show up regardless of app state if triggered.
     final NotificationService notificationService = NotificationService();
     notificationService.showNow(
       id: msg.id.hashCode.abs() % 2147483647,
       title: isCurrentUserDoctor ? "New message from patient" : (doctorName.isNotEmpty ? doctorName : "New message"),
       body: msg.message,
     );
  }


  Future<void> _markVisibleUnreadAsRead() async {
    // mark all unread messages that are not mine
    final unread = messages.where((m) => !m.isMe && !m.read && m.id > 0).toList();
    if (unread.isEmpty) return;

    for (final m in unread) {
      await markAsRead(m.id);
    }
  }

  /// Upload medical test to api/medical-tests (from Medical Test dialog)
  Future<void> uploadMedicalTest({
    required String name,
    required String filePath,
    String? fileName,
  }) async {
    if (myUserId <= 0) {
      Get.snackbar("error".tr, "Session error");
      return;
    }
    final res = await chatData.uploadMedicalTest(
      name: name,
      filePath: filePath,
      fileName: fileName,
      doctorId: doctorId,
      userId: myUserId,
      token: myServices.token,
    );
    res.fold(
      (l) {
        Get.snackbar("error".tr, _mapStatus(l));
      },
      (r) {
        if (r.containsKey("errors")) {
          final msg = r["message"]?.toString() ?? "Failed";
          Get.snackbar("error".tr, msg);
        } else {
          Get.snackbar("success".tr, r["message"]?.toString() ?? "Medical test uploaded");
          refreshHistory();
        }
      },
    );
  }

  Future<void> markAsRead(int messageId) async {
    // local update first
    final idx = messages.indexWhere((e) => e.id == messageId);
    if (idx != -1 && !messages[idx].read) {
      messages[idx] = messages[idx].copyWith(read: true);
      update();
    }

    final res = await chatData.markAsRead(
      messageId: messageId,
      token: myServices.token,
    );

    // لو فشل الطلب، رجّعها false (اختياري)
    res.fold?.call(
          (l) {
        final i = messages.indexWhere((e) => e.id == messageId);
        if (i != -1) {
          messages[i] = messages[i].copyWith(read: false);
          update();
        }
      },
          (r) {},
    );
  }

}
