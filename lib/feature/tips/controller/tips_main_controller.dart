import 'package:get/get.dart';
import 'package:dartz/dartz.dart';
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
        try {
          categories.clear();
          final data = r["data"];
          final List list = data is List ? data : [];
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
