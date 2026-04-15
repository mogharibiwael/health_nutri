import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';
import '../../../core/shared/widgets/drawer.dart';
import '../../../core/class/status_request.dart';
import '../../../core/constant/theme/colors.dart';
import '../../../core/service/serviecs.dart';
import '../../../core/shared/widgets/app_bar.dart';
import '../controller/chat_controller.dart';
import '../model/chat_message_model.dart';

class ChatPage extends GetView<ChatController> {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ChatController>(
      builder: (c) => SafeArea(
          child: Scaffold(
            drawer: HomeDrawer(controller: c),
            appBar: CustomAppBar(
              title: c.doctorName.isNotEmpty ? c.doctorName : "Chat",
              showBackButton: true,
              leading: Builder(
                builder: (ctx) => IconButton(
                  icon: Icon(Icons.menu, color: AppColor.primary, size: 26),
                  onPressed: () => Scaffold.of(ctx).openDrawer(),
                ),
              ),
              actions: [
            IconButton(
              onPressed: c.refreshHistory,
              icon: const Icon(Icons.refresh, color: AppColor.deepPurple),
            ),
          ],
        ),
        body: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: _HistoryBody(c: c),
                ),
                _Composer(
                  controller: c.messageController,
                  isSending: c.isSending,
                  attachedFileName: c.attachedFileName,
                  onRemoveAttachment: c.clearAttachment,
                  // Only patients can upload files/medical tests in chat.
                  onAttach: () {
                    Get.bottomSheet(
                      SafeArea(
                        child: Container(
                          color: Colors.white,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                leading: const Icon(Icons.photo_library_outlined),
                                title: const Text("Photo"),
                                onTap: () {
                                  Get.back();
                                  c.pickImage();
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.attach_file),
                                title: const Text("File"),
                                onTap: () {
                                  Get.back();
                                  c.pickFile();
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  onSend: c.send,
                ),
              ],
            ),
            if (c.statusRequest == StatusRequest.loading)
              const _LoadingOverlay(),
          ],
        ),
      ),
    ));
  }
}

class _HistoryBody extends StatelessWidget {
  final ChatController c;
  const _HistoryBody({required this.c});

  @override
  Widget build(BuildContext context) {
    if (c.statusRequest == StatusRequest.offlineFailure) {
      return _StateView(title: "No internet", onRetry: c.refreshHistory);
    }
    if (c.statusRequest == StatusRequest.serverFailure || c.statusRequest == StatusRequest.failure) {
      return _StateView(title: "Server error", onRetry: c.refreshHistory);
    }

    return RefreshIndicator(
      onRefresh: c.refreshHistory,
      child: ListView.builder(
        controller: c.scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        itemCount: c.messages.isEmpty ? 1 : c.messages.length,
        itemBuilder: (_, i) {
          if (c.messages.isEmpty) {
            return const Padding(
              padding: EdgeInsets.only(top: 120),
              child: Center(child: Text("No messages yet")),
            );
          }
          return _Bubble(
            message: c.messages[i],
            isCurrentUserDoctor: c.isCurrentUserDoctor,
          );
        },
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  final ChatMessageModel message;
  final bool isCurrentUserDoctor;

  const _Bubble({required this.message, required this.isCurrentUserDoctor});

  /// Use API sender_type: "doctor" = right, "user" = left. Fallback when sender_type missing.
  bool get _isFromDoctor {
    if (message.senderType != null && message.senderType!.isNotEmpty) {
      return message.isFromDoctor;
    }
    return (isCurrentUserDoctor && message.isMe) || (!isCurrentUserDoctor && !message.isMe);
  }

  @override
  Widget build(BuildContext context) {
    final isFromDoctor = _isFromDoctor;
    final isMyMessage = message.isMe;
    // sender_type "doctor" → right, "user" → left
    final onRight = isFromDoctor;
    
    final myServices = Get.find<MyServices>();
    final imgUrl = isMyMessage ? myServices.profileImageUrl : null;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: onRight ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!onRight) _avatar(isDoctor: false, imageUrl: imgUrl),
          if (!onRight) const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: onRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    isFromDoctor ? "Doctor" : "Patient",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: onRight
                        ? AppColor.primary.withOpacity(0.15)
                        : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(onRight ? 16 : 4),
                      bottomRight: Radius.circular(onRight ? 4 : 16),
                    ),
                    border: Border.all(
                      color: onRight
                          ? AppColor.primary.withOpacity(0.35)
                          : Colors.grey.shade300,
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColor.textColor.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (message.hasAttachment && message.isImageAttachment) ...[
                        _ImageAttachment(message: message, onRight: onRight),
                        if (message.message.trim().isNotEmpty && message.message.trim() != "(Attachment)")
                          const SizedBox(height: 8),
                      ],
                      if (message.message.trim().isNotEmpty &&
                          !(message.hasAttachment && message.isImageAttachment && message.message.trim() == "(Attachment)"))
                        Text(
                          message.message,
                          style: const TextStyle(fontSize: 15, height: 1.35),
                        ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            _time(message.createdAt),
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          if (isMyMessage) ...[
                            const SizedBox(width: 6),
                            Icon(
                              _statusIcon(message),
                              size: 14,
                              color: message.pending
                                  ? Colors.grey.shade600
                                  : AppColor.primary,
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (onRight) const SizedBox(width: 8),
          if (onRight) _avatar(isDoctor: true, imageUrl: imgUrl),
        ],
      ),
    );
  }

  Widget _avatar({required bool isDoctor, String? imageUrl}) {
    return CircleAvatar(
      radius: 16,
      backgroundColor: isDoctor
          ? Colors.grey.shade200
          : AppColor.primary.withOpacity(0.2),
      backgroundImage: imageUrl != null 
          ? NetworkImage(imageUrl) 
          : null,
      child: imageUrl == null ? Icon(
        isDoctor ? Icons.medical_services_outlined : Icons.person_outline,
        size: 18,
        color: isDoctor ? Colors.grey.shade700 : AppColor.primary,
      ) : null,
    );
  }

  IconData _statusIcon(ChatMessageModel m) {
    if (m.pending) return Icons.schedule;
    if (m.read) return Icons.done_all;
    return Icons.check;
  }

  String _time(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return "$h:$m";
  }
}

class _ImageAttachment extends StatelessWidget {
  final ChatMessageModel message;
  final bool onRight;
  const _ImageAttachment({required this.message, required this.onRight});

  @override
  Widget build(BuildContext context) {
    final local = message.localAttachmentPath;
    final remoteUrl = message.attachmentUrl;
    final hasLocal = local != null && local.isNotEmpty;

    final radius = BorderRadius.circular(14);

    Widget image;
    if (hasLocal) {
      image = Image.file(
        File(local),
        width: 220,
        height: 220,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _broken(),
      );
    } else if (remoteUrl != null && remoteUrl.isNotEmpty) {
      image = Image.network(
        remoteUrl,
        width: 220,
        height: 220,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return SizedBox(
            width: 220,
            height: 220,
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColor.primary,
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                    : null,
              ),
            ),
          );
        },
        errorBuilder: (_, __, ___) => _broken(),
      );
    } else {
      image = _broken();
    }

    return InkWell(
      onTap: () {
        final url = hasLocal ? null : remoteUrl;
        Get.dialog(
          Dialog(
            insetPadding: const EdgeInsets.all(12),
            backgroundColor: Colors.black,
            child: Stack(
              children: [
                Positioned.fill(
                  child: InteractiveViewer(
                    minScale: 0.8,
                    maxScale: 4.0,
                    child: Center(
                      child: hasLocal
                          ? Image.file(File(local!), fit: BoxFit.contain)
                          : (url != null
                              ? Image.network(Uri.encodeFull(url), fit: BoxFit.contain)
                              : const SizedBox.shrink()),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                )
              ],
            ),
          ),
        );
      },
      child: ClipRRect(
        borderRadius: radius,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(
              color: onRight ? AppColor.primary.withOpacity(0.25) : Colors.grey.shade300,
            ),
          ),
          child: image,
        ),
      ),
    );
  }

  Widget _broken() {
    return Container(
      width: 220,
      height: 220,
      color: Colors.grey.shade200,
      child: Icon(Icons.broken_image_outlined, color: Colors.grey.shade600, size: 34),
    );
  }
}


class _Composer extends StatelessWidget {
  final TextEditingController controller;
  final bool isSending;
  final String? attachedFileName;
  final VoidCallback? onRemoveAttachment;
  final VoidCallback? onAttach;
  final VoidCallback onSend;

  const _Composer({
    required this.controller,
    required this.isSending,
    this.attachedFileName,
    this.onRemoveAttachment,
    this.onAttach,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          border: Border(top: BorderSide(color: Colors.grey.shade300)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (attachedFileName != null && attachedFileName!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(Icons.attach_file, size: 20, color: AppColor.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        attachedFileName!,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: onRemoveAttachment,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                    ),
                  ],
                ),
              ),
            Row(
              children: [
                if (onAttach != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: SizedBox(
                      height: 46,
                      width: 46,
                      child: IconButton(
                        onPressed: isSending ? null : onAttach,
                        icon: Icon(Icons.add_circle_outline, color: AppColor.primary),
                        style: IconButton.styleFrom(
                          backgroundColor: AppColor.primary.withOpacity(0.08),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ),
                Expanded(
                  child: TextField(
                    controller: controller,
                    minLines: 1,
                    maxLines: 4,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => isSending ? null : onSend(),
                    decoration: InputDecoration(
                      hintText: "Type a message...",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  height: 46,
                  width: 46,
                  child: ElevatedButton(
                    onPressed: isSending ? null : onSend,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      backgroundColor: AppColor.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: isSending
                        ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                        : const Icon(Icons.send),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingOverlay extends StatelessWidget {
  const _LoadingOverlay();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: AppColor.textColor.withOpacity(0.15),
        child: const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class _StateView extends StatelessWidget {
  final String title;
  final VoidCallback onRetry;
  const _StateView({required this.title, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onRetry,
                child: const Text("Retry"),
              ),
            )
          ],
        ),
      ),
    );
  }
}
