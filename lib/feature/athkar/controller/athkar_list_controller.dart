import 'package:get/get.dart';
import '../../../core/class/status_request.dart';
import '../data/athkar_data.dart';
import '../model/athkar_model.dart';

class AthkarListController extends GetxController {
  final AthkarData athkarData = AthkarData(Get.find());

  final Rx<StatusRequest> statusRequest = StatusRequest.loading.obs;
  final RxList<AthkarModel> athkarList = <AthkarModel>[].obs;
  final RxMap<int, int> currentCounts = <int, int>{}.obs;


  String? _category;
  String get pageTitle => (Get.arguments as Map?)?["titleKey"]?.toString().tr ?? "athkar".tr;

  bool _isFetching = false;

  @override
  void onInit() {
    super.onInit();
    _category = (Get.arguments as Map?)?["category"]?.toString();
    fetchAthkar();
  }

  Future<void> fetchAthkar() async {
    if (_isFetching) return;
    _isFetching = true;
    statusRequest.value = StatusRequest.loading;

    try {
      final res = await athkarData.fetchAthkar(page: 1, category: _category);

      res.fold((l) {
        statusRequest.value = l;
      }, (r) {
        try {
          final data = r["data"];
          final List list = data is List ? data : [];
          final List<AthkarModel> loadedAthkar = [];
          
          for (final e in list) {
            if (e is Map) {
              try {
                loadedAthkar.add(AthkarModel.fromJson(Map<String, dynamic>.from(e)));
              } catch (_) {}
            }
          }

          // Filter by category (API may return all; we filter client-side)
          Iterable<AthkarModel> filtered = loadedAthkar;
          if (_category != null && _category!.isNotEmpty) {
            final lowerCat = _category!.toLowerCase();
            if (lowerCat.contains("صباح") || lowerCat.contains("morning")) {
              filtered = loadedAthkar.where((a) => a.isMorning);
            } else if (lowerCat.contains("مساء") || lowerCat.contains("evening")) {
              filtered = loadedAthkar.where((a) => a.isEvening);
            }
          }
          
          athkarList.assignAll(filtered);
          
          // Initialize counts
          currentCounts.clear();
          for (int i = 0; i < athkarList.length; i++) {
            currentCounts[i] = athkarList[i].repetition;
          }
          
          statusRequest.value = StatusRequest.success;

        } catch (e, st) {
          print("AthkarListController parse error: $e $st");
          statusRequest.value = StatusRequest.serverFailure;
        }
      });

    } finally {
      _isFetching = false;
    }
  }

  Future<void> refresh() async {
    if (_isFetching) return;
    await fetchAthkar();
  }

  void decrement(int index) {
    final current = currentCounts[index] ?? 0;
    if (current > 0) {
      currentCounts[index] = current - 1;
    }
  }

  void reset(int index) {
    if (index >= 0 && index < athkarList.length) {
      currentCounts[index] = athkarList[index].repetition;
    }
  }
}

