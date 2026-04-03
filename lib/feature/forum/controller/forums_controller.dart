import 'package:get/get.dart';
import 'package:dartz/dartz.dart';
import '../../../core/class/status_request.dart';
import '../../../core/function/handel_data.dart';
import '../../../core/permissions/permissions.dart';
import '../../../core/service/serviecs.dart';
import '../../../core/routes/app_route.dart';
import '../data/forums_data.dart';
import '../model/forum_model.dart';

class ForumsController extends GetxController {
  final ForumsData forumsData = ForumsData(Get.find());
  final MyServices myServices = Get.find();
  late final Permissions permissions;

  StatusRequest statusRequest = StatusRequest.loading;
  StatusRequest createStatus = StatusRequest.success;
  final List<ForumModel> forums = [];

  int currentPage = 1;
  bool hasNextPage = false;
  bool isLoadingMore = false;

  /// Optional filter: when opened from a specific doctor, show only that doctor's forums.
  int? doctorIdFilter;
  String? doctorName;

  String? get token => myServices.token;

  bool get canCreateForum => permissions.canCreateForum;

  @override
  void onInit() {
    super.onInit();
    permissions = Permissions(myServices);
    // Read optional doctor context from navigation arguments
    final args = Get.arguments;
    if (args is Map) {
      final did = args["doctor_id"] ?? args["doctorId"];
      if (did != null) {
        if (did is int) {
          doctorIdFilter = did;
        } else {
          doctorIdFilter = int.tryParse(did.toString());
        }
      }
      final dn = args["doctor_name"] ?? args["doctorName"];
      if (dn != null) {
        doctorName = dn.toString();
      }
    }
    fetchFirstPage();
  }

  Future<void> fetchFirstPage() async {
    currentPage = 1;
    forums.clear();
    statusRequest = StatusRequest.loading;
    update();

    final Either<StatusRequest, Map<String, dynamic>> res =
        await forumsData.fetchForums(
      page: currentPage,
      doctorId: doctorIdFilter,
      token: token,
    );

    res.fold((l) {
      statusRequest = l;
      update();
    }, (r) {
      statusRequest = handelData(r);

      final List<Map<String, dynamic>> rawList = _extractForumsList(r);
      final myUserId = myServices.userId;
      final mapped = rawList
          .map((e) => ForumModel.fromJson(e, myUserId: myUserId))
          .toList();

      if (doctorIdFilter != null) {
        forums.addAll(mapped.where((f) => f.doctorId == doctorIdFilter));
      } else {
        forums.addAll(mapped);
      }

      hasNextPage = _hasNextPage(r);
      currentPage = 1;

      if (doctorIdFilter != null && hasNextPage) {
        statusRequest = StatusRequest.loading;
        _fetchAllRemainingPagesForDoctor();
      } else {
        statusRequest = StatusRequest.success;
        update();
      }
    });
  }

  /// When viewing a doctor's forums, fetch all remaining pages so the full list shows on open.
  Future<void> _fetchAllRemainingPagesForDoctor() async {
    int page = currentPage;
    final myUserId = myServices.userId;

    while (hasNextPage) {
      page++;
      final res = await forumsData.fetchForums(
        page: page,
        doctorId: doctorIdFilter,
        token: token,
      );

      res.fold((l) {
        hasNextPage = false;
      }, (r) {
        final rawList = _extractForumsList(r);
        final mapped = rawList
            .map((e) => ForumModel.fromJson(e, myUserId: myUserId))
            .toList();

        if (doctorIdFilter != null) {
          forums.addAll(mapped.where((f) => f.doctorId == doctorIdFilter));
        } else {
          forums.addAll(mapped);
        }
        currentPage = page;
        hasNextPage = _hasNextPage(r);
      });
    }

    statusRequest = StatusRequest.success;
    update();
  }

  bool _hasNextPage(Map<String, dynamic> r) {
    if (r["next_page_url"] != null) return true;
    final links = r["links"];
    if (links is Map && links["next"] != null) return true;
    final meta = r["meta"];
    if (meta is Map) {
      final cur = meta["current_page"];
      final last = meta["last_page"];
      if (cur != null && last != null && cur is num && last is num) {
        return cur < last;
      }
    }
    return false;
  }

  /// Extract forums list from API response. Handles: data as List, data as single Map, or nested data/forums.
  List<Map<String, dynamic>> _extractForumsList(Map<String, dynamic> r) {
    final dynamic data = r["data"];
    if (data is List) {
      return data
          .whereType<Map<String, dynamic>>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    if (data is Map) {
      final map = Map<String, dynamic>.from(data);
      if (map["id"] != null || map["name"] != null) {
        return [map];
      }
      final inner = map["data"] ?? map["forums"];
      if (inner is List) {
        return inner
            .whereType<Map<String, dynamic>>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }
    }
    return [];
  }

  Future<void> refreshForums() async {
    await fetchFirstPage();
  }

  Future<void> loadMore() async {
    if (!hasNextPage || isLoadingMore || statusRequest == StatusRequest.loading) return;

    isLoadingMore = true;
    update();

    final nextPage = currentPage + 1;

    final res = await forumsData.fetchForums(
      page: nextPage,
      doctorId: doctorIdFilter,
      token: token,
    );

    res.fold((l) {
      isLoadingMore = false;
      update();
    }, (r) {
      final List<Map<String, dynamic>> rawList = _extractForumsList(r);
      final myUserId = myServices.userId;
      final mapped = rawList
          .map((e) => ForumModel.fromJson(e, myUserId: myUserId))
          .toList();

      if (doctorIdFilter != null) {
        forums.addAll(mapped.where((f) => f.doctorId == doctorIdFilter));
      } else {
        forums.addAll(mapped);
      }

      currentPage = nextPage;
      hasNextPage = _hasNextPage(r);
      isLoadingMore = false;
      update();
    });
  }

  void openForum(ForumModel forum) {
    Get.toNamed(AppRoute.forumPosts, arguments: {
      "forum_id": forum.id,
      "forum_name": forum.name,
      "is_joined": forum.isJoined,
    });
  }

  /// Create forum (POST /api/forums). Doctor only.
  Future<void> createForum({required String name, String? description}) async {
    if (!canCreateForum) return;
    createStatus = StatusRequest.loading;
    update();

    final res = await forumsData.createForum(
      name: name.trim(),
      description: description?.trim(),
      doctorId: myServices.doctorId,
      token: token,
    );

    res.fold((l) {
      createStatus = l;
      update();
      Get.snackbar("error".tr, "serverError".tr);
    }, (r) {
      createStatus = StatusRequest.success;
      update();
      if (r["data"] is Map) {
        forums.insert(
            0,
            ForumModel.fromJson(r["data"] as Map<String, dynamic>,
                myUserId: myServices.userId));
      }
      Get.snackbar("success".tr, r["message"]?.toString() ?? "forumCreated".tr);
      refreshForums();
    });
  }
}
