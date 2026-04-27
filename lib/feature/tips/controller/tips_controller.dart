import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dartz/dartz.dart';
import '../../../core/class/status_request.dart';
import '../../../core/function/handel_data.dart';
import '../../../core/service/serviecs.dart';
import '../data/tips_data.dart';
import '../model/tips.dart';

class TipsController extends GetxController {
  final TipsData tipsData = TipsData(Get.find());
  final MyServices myServices = Get.find();

  StatusRequest statusRequest = StatusRequest.loading;

  final List<TipModel> tips = [];

  int currentPage = 1;
  bool hasNextPage = false;
  bool isLoadingMore = false;
  int? categoryId;

  String? get token => myServices.sharedPreferences.getString("token");

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map?;
    categoryId = args?["categoryId"] as int?;
    fetchFirstPage();
  }

  Future<void> fetchFirstPage() async {
    currentPage = 1;
    tips.clear();
    statusRequest = StatusRequest.loading;
    update();

    final Either<StatusRequest, Map<String, dynamic>> res =
        await tipsData.fetchTips(page: currentPage, token: token, categoryId: categoryId);

    res.fold((l) {
      statusRequest = l;
      update();
    }, (r) {
      final code = r["_statusCode"] is int ? (r["_statusCode"] as int) : int.tryParse("${r["_statusCode"]}") ?? 200;
      if (code != 200 && code != 201) {
        debugPrint("[Tips] fetchFirstPage failed: status=$code body=${r["message"] ?? r}");
        statusRequest = StatusRequest.serverFailure;
        update();
        return;
      }

      try {
        // Laravel paginator may come as:
        // { data: [..], next_page_url: ... }
        // or wrapped: { data: { data: [..], next_page_url: ... } }
        final dataRoot = r["data"];
        final List list = (dataRoot is Map)
            ? ((dataRoot["data"] is List) ? (dataRoot["data"] as List) : const <dynamic>[])
            : (dataRoot is List ? dataRoot : const <dynamic>[]);

        tips.addAll(list.whereType<Map>().map((e) => TipModel.fromJson(Map<String, dynamic>.from(e))));

        final nextUrl = (dataRoot is Map) ? dataRoot["next_page_url"] : r["next_page_url"];
        hasNextPage = nextUrl != null && nextUrl.toString().trim().isNotEmpty;

        statusRequest = StatusRequest.success;
        update();
      } catch (e, st) {
        debugPrint("[Tips] parse error: $e\n$st");
        statusRequest = StatusRequest.serverFailure;
        update();
      }
    });
  }

  Future<void> refreshTips() async {
    await fetchFirstPage();
  }

  Future<void> loadMore() async {
    if (!hasNextPage || isLoadingMore || statusRequest == StatusRequest.loading) return;

    isLoadingMore = true;
    update();

    final nextPage = currentPage + 1;

    final res = await tipsData.fetchTips(page: nextPage, token: token, categoryId: categoryId);

    res.fold((l) {
      // keep current list, only stop load-more
      isLoadingMore = false;
      update();
    }, (r) {
      final code = r["_statusCode"] is int ? (r["_statusCode"] as int) : int.tryParse("${r["_statusCode"]}") ?? 200;
      if (code != 200 && code != 201) {
        debugPrint("[Tips] loadMore failed: status=$code body=${r["message"] ?? r}");
        isLoadingMore = false;
        update();
        return;
      }

      try {
        final dataRoot = r["data"];
        final List list = (dataRoot is Map)
            ? ((dataRoot["data"] is List) ? (dataRoot["data"] as List) : const <dynamic>[])
            : (dataRoot is List ? dataRoot : const <dynamic>[]);

        tips.addAll(list.whereType<Map>().map((e) => TipModel.fromJson(Map<String, dynamic>.from(e))));

        currentPage = nextPage;
        final nextUrl = (dataRoot is Map) ? dataRoot["next_page_url"] : r["next_page_url"];
        hasNextPage = nextUrl != null && nextUrl.toString().trim().isNotEmpty;
      } catch (e, st) {
        debugPrint("[Tips] loadMore parse error: $e\n$st");
      } finally {
        isLoadingMore = false;
        update();
      }
    });
  }
}
