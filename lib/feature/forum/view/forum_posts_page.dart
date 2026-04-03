import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/class/status_request.dart';
import '../../../core/constant/theme/colors.dart';
import '../../../core/shared/widgets/app_bar.dart';
import '../controller/forum_posts_controller.dart';
import '../model/forum_post_model.dart';

class ForumPostsPage extends GetView<ForumPostsController> {
  const ForumPostsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ForumPostsController>(
      builder: (c) => SafeArea(
        child: Scaffold(
        appBar: CustomAppBar(
          title: c.forumName.isNotEmpty ? c.forumName : "forumPosts".tr,
          showBackButton: true,
          actions: [
            if (!c.hasJoined)
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: TextButton.icon(
                  onPressed: c.joinStatus == StatusRequest.loading
                      ? null
                      : c.joinForum,
                  icon: c.joinStatus == StatusRequest.loading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child:
                              CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.group_add_outlined, size: 18),
                  label: Text(
                    "joinForum".tr,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
          ],
        ),
        body: Column(
          children: [
            Expanded(child: _buildBody(c)),
            if (c.hasJoined)
              _Composer(
                titleController: c.titleController,
                contentController: c.postController,
                isLoading: c.createPostStatus == StatusRequest.loading,
                onSend: c.createPost,
              ),
          ],
        ),
      ),
    ));
  }

  Widget _buildBody(ForumPostsController c) {
    if (c.statusRequest == StatusRequest.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (c.statusRequest == StatusRequest.offlineFailure) {
      return _EmptyState(
        icon: Icons.wifi_off_rounded,
        title: "noInternet".tr,
        buttonText: "retry".tr,
        onRetry: c.fetchFirstPage,
      );
    }

    if (c.statusRequest == StatusRequest.serverFailure ||
        c.statusRequest == StatusRequest.failure) {
      return _EmptyState(
        icon: Icons.error_outline_rounded,
        title: "serverError".tr,
        buttonText: "retry".tr,
        onRetry: c.fetchFirstPage,
      );
    }

    if (c.posts.isEmpty) {
      return _EmptyState(
        icon: Icons.article_outlined,
        title: "noPosts".tr,
        buttonText: "refresh".tr,
        onRetry: c.refreshPosts,
      );
    }

    return RefreshIndicator(
      onRefresh: c.refreshPosts,
      child: NotificationListener<ScrollNotification>(
        onNotification: (n) {
          if (n.metrics.pixels >= n.metrics.maxScrollExtent - 200) {
            c.loadMore();
          }
          return false;
        },
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          itemCount: c.posts.length + (c.isLoadingMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index >= c.posts.length) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _PostCard(
                post: c.posts[index],
                isMe: c.posts[index].userId == c.myUserId,
                onLike: () => c.toggleLike(index),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────
// Post Card
// ─────────────────────────────────────────────────────

class _PostCard extends StatelessWidget {
  final ForumPostModel post;
  final bool isMe;
  final VoidCallback onLike;

  const _PostCard({
    required this.post,
    required this.isMe,
    required this.onLike,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isMe ? AppColor.primary.withOpacity(0.04) : Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 1,
      shadowColor: const Color(0x1F2A0126),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color:
                isMe ? AppColor.primary.withOpacity(0.25) : Colors.grey.shade200,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header: avatar + name + time ──
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: isMe
                      ? AppColor.primary.withOpacity(0.15)
                      : Colors.grey.shade100,
                  child: Text(
                    _initial(post.userName ?? "U"),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isMe ? AppColor.primary : Colors.grey.shade600,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.userName ?? "User #${post.userId}",
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      if (post.createdAt != null)
                        Text(
                          _formatDate(post.createdAt!),
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade500,
                          ),
                        ),
                    ],
                  ),
                ),
                if (isMe)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColor.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "you",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColor.primary,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 10),

            // ── Title (if backend returns it) ──
            if (post.title != null && post.title!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  post.title!,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                ),
              ),

            // ── Content ──
            Text(
              post.content,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: Colors.grey.shade800,
              ),
            ),

            const SizedBox(height: 10),

            // ── Like row ──
            Divider(height: 1, color: Colors.grey.shade200),
            const SizedBox(height: 8),
            InkWell(
              onTap: onLike,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      post.isLiked ? Icons.favorite : Icons.favorite_border,
                      size: 20,
                      color: post.isLiked ? Colors.red.shade400 : Colors.grey.shade500,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "${post.likesCount}",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: post.isLiked ? Colors.red.shade400 : Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _initial(String name) {
    return name.isNotEmpty ? name[0].toUpperCase() : "?";
  }

  String _formatDate(String dateStr) {
    final dt = DateTime.tryParse(dateStr);
    if (dt == null) return dateStr;
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return "now";
    if (diff.inMinutes < 60) return "${diff.inMinutes}m";
    if (diff.inHours < 24) return "${diff.inHours}h";
    if (diff.inDays < 7) return "${diff.inDays}d";
    return "${dt.day}/${dt.month}/${dt.year}";
  }
}

// ─────────────────────────────────────────────────────
// Composer — title + content (backend requires both)
// ─────────────────────────────────────────────────────

class _Composer extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController contentController;
  final bool isLoading;
  final VoidCallback onSend;

  const _Composer({
    required this.titleController,
    required this.contentController,
    required this.isLoading,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          border: Border(top: BorderSide(color: Colors.grey.shade200)),
          boxShadow: [
            BoxShadow(
              color: AppColor.textColor.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              textInputAction: TextInputAction.next,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                hintText: "postTitle".tr,
                hintStyle: TextStyle(
                    fontWeight: FontWeight.w400, color: Colors.grey.shade500),
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                isDense: true,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: TextField(
                    controller: contentController,
                    minLines: 1,
                    maxLines: 4,
                    textInputAction: TextInputAction.newline,
                    style: const TextStyle(fontSize: 14),
                    decoration: InputDecoration(
                      hintText: "writePost".tr,
                      hintStyle: TextStyle(color: Colors.grey.shade500),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  height: 46,
                  width: 46,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : onSend,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      backgroundColor: AppColor.primary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.send_rounded, size: 20),
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

// ─────────────────────────────────────────────────────
// Empty / Error state
// ─────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String buttonText;
  final VoidCallback onRetry;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.buttonText,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(icon, size: 32, color: Colors.grey.shade500),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(buttonText),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
