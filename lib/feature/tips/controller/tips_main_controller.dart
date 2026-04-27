import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/class/status_request.dart';
import '../data/tips_data.dart';
import '../model/tips.dart';

class TipsMainController extends GetxController {
  final TipsData tipsData = TipsData(Get.find());

  final Rx<StatusRequest> statusRequest = StatusRequest.loading.obs;
  final RxList<TipCategory> categories = <TipCategory>[].obs;

  bool _isFetching = false;

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    if (_isFetching) return;
    _isFetching = true;
    statusRequest.value = StatusRequest.loading;

    try {
      final res = await tipsData.fetchTips(page: 1);

      res.fold((l) {
        statusRequest.value = l;
      }, (r) {
        final code = r["_statusCode"] is int ? (r["_statusCode"] as int) : int.tryParse("${r["_statusCode"]}") ?? 200;
        if (code != 200 && code != 201) {
          debugPrint("[TipsMain] fetchCategories failed: status=$code body=${r["message"] ?? r}");
          statusRequest.value = StatusRequest.serverFailure;
          return;
        }
        try {
          categories.clear();
          final dataRoot = r["data"];
          final List list = (dataRoot is Map)
              ? ((dataRoot["data"] is List) ? (dataRoot["data"] as List) : const <dynamic>[])
              : (dataRoot is List ? dataRoot : const <dynamic>[]);
          final seenIds = <int>{};
          final tempList = <TipCategory>[];

          for (final e in list) {
            if (e is! Map) continue;
            final cat = e["category"];
            if (cat is Map) {
              try {
                final tipCat = TipCategory.fromJson(Map<String, dynamic>.from(cat));
                if (!seenIds.contains(tipCat.id)) {
                  seenIds.add(tipCat.id);
                  tempList.add(tipCat);
                }
              } catch (_) {}
            }
          }

          tempList.sort((a, b) => a.id.compareTo(b.id));
          categories.addAll(tempList);
          statusRequest.value = StatusRequest.success;
        } catch (e, st) {
          print("TipsMainController parse error: $e $st");
          statusRequest.value = StatusRequest.serverFailure;
        }
      });
    } finally {
      _isFetching = false;
    }
  }

  Future<void> refresh() async {
    if (_isFetching) return;
    await fetchCategories();
  }
}
