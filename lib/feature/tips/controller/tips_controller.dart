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
      statusRequest = handelData(r);

      final List data = (r["data"] ?? []) as List;
      tips.addAll(data.map((e) => TipModel.fromJson(e as Map<String, dynamic>)));

      hasNextPage = r["next_page_url"] != null;
      statusRequest = StatusRequest.success;
      update();
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
      final List data = (r["data"] ?? []) as List;
      tips.addAll(data.map((e) => TipModel.fromJson(e as Map<String, dynamic>)));

      currentPage = nextPage;
      hasNextPage = r["next_page_url"] != null;

      isLoadingMore = false;
      update();
    });
  }
}
