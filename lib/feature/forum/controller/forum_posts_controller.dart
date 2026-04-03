import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dartz/dartz.dart';
import '../../../core/class/status_request.dart';
import '../../../core/function/handel_data.dart';
import '../../../core/service/serviecs.dart';
import '../data/forums_data.dart';
import '../model/forum_post_model.dart';

class ForumPostsController extends GetxController {
  final ForumsData forumsData = ForumsData(Get.find());
  final MyServices myServices = Get.find();

  late int forumId;
  String forumName = "";

  StatusRequest statusRequest = StatusRequest.loading;
  StatusRequest joinStatus = StatusRequest.success;
  StatusRequest createPostStatus = StatusRequest.success;

  final List<ForumPostModel> posts = [];

  int currentPage = 1;
  bool hasNextPage = false;
  bool isLoadingMore = false;

  bool hasJoined = false;

  final TextEditingController titleController = TextEditingController();
  final TextEditingController postController = TextEditingController();

  String? get token => myServices.token;
  int get myUserId => myServices.userId ?? 0;

  @override
  void onInit() {
    super.onInit();

    final args = (Get.arguments as Map?) ?? {};
    forumId = (args["forum_id"] is int)
        ? args["forum_id"]
        : int.tryParse("${args["forum_id"]}") ?? 0;
    forumName = (args["forum_name"] ?? "").toString();
    if (args["is_joined"] == true) {
      hasJoined = true;
    }

    fetchFirstPage();
  }

  Future<void> fetchFirstPage() async {
    currentPage = 1;
    posts.clear();
    statusRequest = StatusRequest.loading;
    update();

    final Either<StatusRequest, Map<String, dynamic>> res =
        await forumsData.fetchPosts(forumId: forumId, page: currentPage, token: token);

    res.fold((l) {
      statusRequest = l;
      update();
    }, (r) {
      // Handle both paginated {data: [...]} and direct list responses (per API doc)
      List rawList = [];
      bool foundNextPage = false;

      if (r["data"] is List) {
        rawList = r["data"] as List;
        foundNextPage = r["next_page_url"] != null;
      } else if (r["data"] is Map) {
        final inner = r["data"] as Map;
        rawList = (inner["data"] is List) ? inner["data"] as List : [];
        foundNextPage = inner["next_page_url"] != null;
      } else if (r["posts"] is Map) {
        final postsMap = r["posts"] as Map;
        rawList = (postsMap["data"] is List) ? postsMap["data"] as List : [];
        foundNextPage = postsMap["next_page_url"] != null;
      } else if (r["posts"] is List) {
        rawList = r["posts"] as List;
      }

      posts.addAll(
        rawList
            .whereType<Map>()
            .map((e) => ForumPostModel.fromJson(Map<String, dynamic>.from(e))),
      );

      // Update joined state from API only when the API sends it (don't overwrite true with false)
      if (r["has_joined"] is bool) {
        hasJoined = r["has_joined"] as bool;
      } else if (r["is_member"] is bool) {
        hasJoined = r["is_member"] as bool;
      } else if (r["is_joined"] is bool) {
        hasJoined = r["is_joined"] as bool;
      }

      hasNextPage = foundNextPage;
      statusRequest = StatusRequest.success;
      update();
    });
  }

  Future<void> refreshPosts() async {
    await fetchFirstPage();
  }

  Future<void> loadMore() async {
    if (!hasNextPage || isLoadingMore || statusRequest == StatusRequest.loading) return;

    isLoadingMore = true;
    update();

    final nextPage = currentPage + 1;
    final res = await forumsData.fetchPosts(forumId: forumId, page: nextPage, token: token);

    res.fold((l) {
      isLoadingMore = false;
      update();
    }, (r) {
      List rawList = [];
      bool foundNextPage = false;

      if (r["data"] is List) {
        rawList = r["data"] as List;
        foundNextPage = r["next_page_url"] != null;
      } else if (r["data"] is Map) {
        final inner = r["data"] as Map;
        rawList = (inner["data"] is List) ? inner["data"] as List : [];
        foundNextPage = inner["next_page_url"] != null;
      } else if (r["posts"] is Map) {
        final postsMap = r["posts"] as Map;
        rawList = (postsMap["data"] is List) ? postsMap["data"] as List : [];
        foundNextPage = postsMap["next_page_url"] != null;
      } else if (r["posts"] is List) {
        rawList = r["posts"] as List;
      }

      posts.addAll(
        rawList
            .whereType<Map>()
            .map((e) => ForumPostModel.fromJson(Map<String, dynamic>.from(e))),
      );

      currentPage = nextPage;
      hasNextPage = foundNextPage;
      isLoadingMore = false;
      update();
    });
  }

  // ── Join Forum (POST /forums/{id}/join per API doc) ──
  Future<void> joinForum() async {
    joinStatus = StatusRequest.loading;
    update();

    final res = await forumsData.joinForum(forumId: forumId, token: token);

    res.fold((l) {
      joinStatus = StatusRequest.failure;
      update();
      Get.snackbar("error".tr, "serverError".tr);
    }, (r) {
      if (r.containsKey("errors")) {
        joinStatus = StatusRequest.failure;
        update();
        final errors = r["errors"] as Map?;
        final firstError = errors?.values.first;
        final msg = (firstError is List && firstError.isNotEmpty)
            ? firstError.first.toString()
            : r["message"]?.toString() ?? "serverError".tr;
        Get.snackbar("error".tr, msg);
        return;
      }

      // "Already a member of this forum" = success
      final msg = r["message"]?.toString() ?? "";
      if (msg.toLowerCase().contains("already") && msg.toLowerCase().contains("member")) {
        hasJoined = true;
      }

      joinStatus = StatusRequest.success;
      hasJoined = true;
      update();
      Get.snackbar("success".tr, r["message"]?.toString() ?? "Joined!");
    });
  }

  // ── Create Post (backend requires title + content) ──
  Future<void> createPost() async {
    final title = titleController.text.trim();
    final content = postController.text.trim();

    if (title.isEmpty || content.isEmpty) {
      Get.snackbar("error".tr, "fillPostFields".tr);
      return;
    }

    createPostStatus = StatusRequest.loading;
    update();

    final res = await forumsData.createPost(
      forumId: forumId,
      title: title,
      content: content,
      token: token,
    );

    res.fold((l) {
      createPostStatus = StatusRequest.failure;
      update();
      Get.snackbar("error".tr, "serverError".tr);
    }, (r) {
      if (r.containsKey("errors")) {
        createPostStatus = StatusRequest.failure;
        update();
        final errors = r["errors"] as Map?;
        final firstError = errors?.values.first;
        final msg = (firstError is List && firstError.isNotEmpty)
            ? firstError.first.toString()
            : r["message"]?.toString() ?? "serverError".tr;
        Get.snackbar("error".tr, msg);
        return;
      }

      createPostStatus = StatusRequest.success;
      titleController.clear();
      postController.clear();
      update();
      refreshPosts();
    });
  }

  // ── Toggle Like/Unlike (POST /posts/{id}/like or /posts/{id}/unlike per API doc) ──
  Future<void> toggleLike(int index) async {
    if (index < 0 || index >= posts.length) return;

    final post = posts[index];

    posts[index] = post.copyWith(
      isLiked: !post.isLiked,
      likesCount: post.isLiked ? post.likesCount - 1 : post.likesCount + 1,
    );
    update();

    final res = post.isLiked
        ? await forumsData.unlikePost(postId: post.id, token: token)
        : await forumsData.likePost(postId: post.id, token: token);

    res.fold((l) {
      posts[index] = post;
      update();
    }, (r) {});
  }

  @override
  void onClose() {
    titleController.dispose();
    postController.dispose();
    super.onClose();
  }
}
