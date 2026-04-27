import 'dart:convert';
import 'package:get/get.dart';
import 'package:nutri_guide/core/constant/api_link.dart';
import 'package:nutri_guide/core/service/serviecs.dart';
import 'package:nutri_guide/core/permissions/permissions.dart';
import 'package:nutri_guide/core/class/status_request.dart';
import 'package:nutri_guide/core/function/handel_data.dart';
import 'package:nutri_guide/feature/ads/data/ads_data.dart';
import 'package:nutri_guide/feature/ads/model/ad_model.dart';

import '../../../core/routes/app_route.dart';

class HomeController extends GetxController {
  final MyServices myServices = Get.find();
  late final Permissions permissions;
  final AdsData adsData = AdsData(Get.find());

  Map<String, dynamic>? user;

  /// Ads for top carousel (public/ads)
  final List<AdModel> ads = [];
  StatusRequest adsStatus = StatusRequest.success;

  @override
  void onInit() {
    super.onInit();
    permissions = Permissions(myServices);
    loadUser();
    _refreshSubscriptionStatus();
    fetchAds();
  }

  Future<void> _refreshSubscriptionStatus() async {
    if (!myServices.isPatient) return;
    await myServices.syncSubscribedDoctorsFromBackend();
    update();
  }

  Future<void> fetchAds() async {
    adsStatus = StatusRequest.loading;
    update();

    final res = await adsData.fetchAds();
    res.fold((l) {
      adsStatus = l;
      update();
    }, (r) {
      final code = r["_statusCode"] is int ? (r["_statusCode"] as int) : int.tryParse("${r["_statusCode"]}") ?? 200;
      if (code != 200 && code != 201) {
        print("[Ads] fetchAds failed: status=$code body=${r["message"] ?? r}");
        adsStatus = StatusRequest.serverFailure;
        update();
        return;
      }
      adsStatus = StatusRequest.success;
      List rawList = [];
      if (r["data"] is List) {
        rawList = r["data"] as List;
      } else if (r["ads"] is List) {
        rawList = r["ads"] as List;
      } else if (r["advertisements"] is List) {
        rawList = r["advertisements"] as List;
      } else if (r["data"] is Map && (r["data"] as Map)["data"] is List) {
        rawList = (r["data"] as Map)["data"] as List;
      }
      final storageBase = ApiLinks.storageBase;
      ads.clear();
      for (final e in rawList) {
        if (e is Map<String, dynamic>) {
          try {
            final ad = AdModel.fromJson(e, storageBase: storageBase);
            print("[Ads] parsed id=${ad.id} active=${ad.isActive} imageUrl=${ad.imageUrl}");
            if (ad.imageUrl != null && ad.imageUrl!.isNotEmpty) ads.add(ad);
          } catch (_) {}
        } else if (e is Map) {
          try {
            final ad = AdModel.fromJson(Map<String, dynamic>.from(e), storageBase: storageBase);
            print("[Ads] parsed id=${ad.id} active=${ad.isActive} imageUrl=${ad.imageUrl}");
            if (ad.imageUrl != null && ad.imageUrl!.isNotEmpty) ads.add(ad);
          } catch (_) {}
        }
      }
      update();
    });
  }

  void loadUser() {
    final userStr = myServices.sharedPreferences.getString("user");
    if (userStr == null || userStr.isEmpty) {
      user = null;
      update();
      return;
    }
    try {
      user = jsonDecode(userStr) as Map<String, dynamic>;
      print(myServices.sharedPreferences.getString("token"));
      print(user);
    } catch (_) {
      user = null;
    }
    update();
  }

  String get userName => (user?["name"] ?? "Guest").toString();
  String get userEmail => (user?["email"] ?? "-").toString();
  String get userPhone => (user?["phone"] ?? "-").toString();
  String get userRole  => (user?["role"] ?? "-").toString();

  /// Returns the name of the doctor the patient is subscribed to (if available in profile).
  String get subscribedDoctorName {
    final p = user?["patient_profile"] ?? user?["patientProfile"];
    if (p is Map) {
      final doc = p["doctor"];
      if (doc is Map && doc["name"] != null) return doc["name"].toString();
    }
    return "";
  }

  /// True when the patient has subscribed to at least one doctor.
  bool get isSubscribed => myServices.subscribedDoctorIds.isNotEmpty;

  /// True when the patient's subscription is approved by admin.
  bool get isSubscribedApproved => myServices.isSubscriptionApproved;

  /// True when subscription is submitted but waiting for admin approval.
  bool get isSubscriptionPending => myServices.hasPendingSubscription && !myServices.isSubscriptionApproved;

  bool get isDoctor => permissions.isDoctor || permissions.isAdmin;
  /// True when doctor is approved by admin (can see "My clinic" and enter doctor home).
  bool get isDoctorApproved => myServices.isDoctorApproved;

  void goToDoctorHome() => Get.offAllNamed(AppRoute.doctorWelcome);

  void goDoctors() => Get.toNamed("/doctors");
  void goTips() => Get.toNamed("/tips");
  void goBmi() => Get.toNamed("/bmi");
  void goForums() => Get.toNamed(AppRoute.forums);
  void goConsultations() => Get.toNamed(AppRoute.consultations);
  void goDiet() => Get.toNamed(AppRoute.diet);

  void goStepCounter() => Get.toNamed("/step-counter");
  void goSpiritualNutrition() => Get.toNamed("/spiritual-nutrition");
  void goSettings() => Get.toNamed("/settings");


  Future<void> logout() async {
    await myServices.clearSession();
    Get.offAllNamed(AppRoute.login);
  }
}
