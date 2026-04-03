import 'package:dartz/dartz.dart';
import '../../../core/class/crud.dart';
import '../../../core/class/status_request.dart';
import '../../../core/constant/api_link.dart';

class ForumsData {
  final Crud crud;
  ForumsData(this.crud);

  /// GET /forums. When [doctorId] is set, request only that doctor's forums so new ones appear.
  Future<Either<StatusRequest, Map<String, dynamic>>> fetchForums({
    int page = 1,
    int? doctorId,
    String? token,
  }) async {
    var url = "${ApiLinks.forumsBase}?page=$page";
    if (doctorId != null && doctorId! > 0) {
      url += "&doctor_id=$doctorId";
    }
    return await crud.getData(url, token: token);
  }

  /// POST /api/forums - Create forum (doctor). Body: name, optional description, optional doctor_id (if backend expects it).
  Future<Either<StatusRequest, Map<String, dynamic>>> createForum({
    required String name,
    String? description,
    int? doctorId,
    String? token,
  }) async {
    final body = <String, dynamic>{"name": name};
    if (description != null && description.trim().isNotEmpty) {
      body["description"] = description.trim();
    }
    if (doctorId != null && doctorId > 0) {
      body["doctor_id"] = doctorId;
    }
    return await crud.postData(ApiLinks.forumsBase, body, token: token);
  }

  /// GET /forums/{id}/posts (per API doc)
  Future<Either<StatusRequest, Map<String, dynamic>>> fetchPosts({
    required int forumId,
    int page = 1,
    String? token,
  }) async {
    final url = "${ApiLinks.forumsBase}/$forumId/posts?page=$page";
    return await crud.getData(url, token: token);
  }

  /// POST /forums/{id}/join (per API doc)
  Future<Either<StatusRequest, Map<String, dynamic>>> joinForum({
    required int forumId,
    String? token,
  }) async {
    final url = "${ApiLinks.forumsBase}/$forumId/join";
    return await crud.postData(url, {}, token: token);
  }

  /// POST /forums/{id}/posts - body: title + content (backend requires both)
  Future<Either<StatusRequest, Map<String, dynamic>>> createPost({
    required int forumId,
    required String title,
    required String content,
    String? token,
  }) async {
    final url = "${ApiLinks.forumsBase}/$forumId/posts";
    return await crud.postData(url, {"title": title, "content": content}, token: token);
  }

  /// POST /posts/{id}/like (per API doc)
  Future<Either<StatusRequest, Map<String, dynamic>>> likePost({
    required int postId,
    String? token,
  }) async {
    final url = "${ApiLinks.postsBase}/$postId/like";
    return await crud.postData(url, {}, token: token);
  }

  /// POST /posts/{id}/unlike (per API doc)
  Future<Either<StatusRequest, Map<String, dynamic>>> unlikePost({
    required int postId,
    String? token,
  }) async {
    final url = "${ApiLinks.postsBase}/$postId/unlike";
    return await crud.postData(url, {}, token: token);
  }
}
