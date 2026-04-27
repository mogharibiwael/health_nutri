import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nutri_guide/core/constant/api_link.dart';
import 'package:nutri_guide/core/class/crud.dart';

class MyServices extends GetxService {
  late SharedPreferences sharedPreferences;

  Future<MyServices> init() async {
    sharedPreferences = await SharedPreferences.getInstance();
    return this;
  }

  Future<void> saveSession({
    required String token,
    required String type, // user / doctor / admin ...
    Map<String, dynamic>? user,
  }) async {
    await sharedPreferences.setString("token", token);
    await sharedPreferences.setString("type", type);
    if (user != null) {
      await sharedPreferences.setString("user", jsonEncode(user));
    }
  }

  String? get token => sharedPreferences.getString("token");

  /// User type: "doctor", "user", "admin". Falls back to user["type"] or "doctor" if user has doctor object.
  String? get type {
    final stored = sharedPreferences.getString("type");
    if (stored != null && stored.trim().isNotEmpty) return stored;
    final u = user;
    if (u == null) return null;
    final t = (u["type"] ?? "").toString().trim().toLowerCase();
    if (t.isNotEmpty) return t;
    if (u["doctor"] != null || u["doctor_profile"] != null || u["doctorProfile"] != null) return "doctor";
    return "user";
  }

  bool get isLoggedIn => token != null && token!.trim().isNotEmpty;

  Map<String, dynamic>? get user {
    final s = sharedPreferences.getString("user");
    if (s == null || s.trim().isEmpty) return null;
    try {
      return jsonDecode(s) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  /// Backend shape helpers
  bool get hasDoctorProfile {
    final u = user;
    if (u == null) return false;
    final doc = u["doctor_profile"] ?? u["doctorProfile"] ?? u["doctor"];
    return doc is Map;
  }

  bool get hasPatientProfile {
    final u = user;
    if (u == null) return false;
    final pat = u["patient_profile"] ?? u["patientProfile"];
    return pat is Map;
  }

  int? get userId {
    final u = user;
    if (u == null) return null;
    final id = u["id"];
    if (id is int) return id;
    return int.tryParse(id?.toString() ?? "");
  }

  /// Global profile image URL logic
  String? get profileImageUrl {
    final u = user;
    if (u == null) return null;
    
    // Check patient's profile image
    final pat = u["patient_profile"] ?? u["patientProfile"] ?? u["patient"];
    if (pat is Map && pat["image"] != null && pat["image"].toString().isNotEmpty) {
      return "${ApiLinks.storageBase}/${pat["image"]}";
    }

    // Check doctor's profile image
    final doc = u["doctor_profile"] ?? u["doctorProfile"] ?? u["doctor"];
    if (doc is Map && doc["profile_image"] != null && doc["profile_image"].toString().isNotEmpty) {
      return "${ApiLinks.storageBase}/${doc["profile_image"]}";
    }
    
    return null;
  }

  /// Doctor's record id (from doctors table). Required for diet-plans API.
  /// Backend expects doctor_id, not user_id. Read from user["doctor_id"] or user["doctor"]["id"].
  int? get doctorId {
    final u = user;
    if (u == null) return null;
    final did = u["doctor_id"];
    if (did != null) {
      if (did is int) return did;
      final parsed = int.tryParse(did.toString());
      if (parsed != null) return parsed;
    }
    final doctor = u["doctor"] ?? u["doctor_profile"] ?? u["doctorProfile"];
    if (doctor is Map) {
      final id = doctor["id"];
      if (id is int) return id;
      return int.tryParse(id?.toString() ?? "");
    }
    return null;
  }

  // -------------------------------
  // ✅ Subscriptions cache
  static const String _subsKey = "subscribed_doctor_ids";
  static const String _subsAcceptedKey = "accepted_subscribed_doctor_ids";

  Set<int> get subscribedDoctorIds {
    final list = sharedPreferences.getStringList(_subsKey) ?? <String>[];
    return list.map((e) => int.tryParse(e)).whereType<int>().toSet();
  }

  Set<int> get acceptedSubscribedDoctorIds {
    final list = sharedPreferences.getStringList(_subsAcceptedKey) ?? <String>[];
    return list.map((e) => int.tryParse(e)).whereType<int>().toSet();
  }

  int? get currentDoctorIdFromPatientProfile {
    final u = user;
    if (u == null) return null;
    final p = u["patient_profile"] ?? u["patientProfile"];
    if (p is! Map) return null;
    final v = p["current_doctor_id"];
    if (v is int) return v;
    return int.tryParse(v?.toString() ?? "");
  }

  bool get isSubscribedFromPatientProfile {
    final u = user;
    if (u == null) return false;
    final p = u["patient_profile"] ?? u["patientProfile"];
    if (p is! Map) return false;
    return p["is_subscribed"] == true;
  }

  bool isSubscribedToDoctor(int doctorId) {
    if (subscribedDoctorIds.contains(doctorId)) return true;
    return isApprovedToDoctor(doctorId);
  }

  bool isApprovedToDoctor(int doctorId) {
    return acceptedSubscribedDoctorIds.contains(doctorId);
  }

  Future<void> markSubscribedDoctor(int doctorId) async {
    final ids = subscribedDoctorIds;
    ids.add(doctorId);
    await sharedPreferences.setStringList(
      _subsKey,
      ids.map((e) => e.toString()).toList(),
    );
  }

  /// True when a patient has a subscription that is approved by admin.
  /// Determined via GET /api/users-subscribed where status == accepted.
  bool get isSubscriptionApproved => isPatient && acceptedSubscribedDoctorIds.isNotEmpty;

  /// True when a patient has requested a subscription (uploaded invoice) but not yet approved.
  bool get hasPendingSubscription =>
      isPatient &&
      subscribedDoctorIds.isNotEmpty &&
      subscribedDoctorIds.difference(acceptedSubscribedDoctorIds).isNotEmpty;

  Future<void> setSubscribedDoctorIds(Set<int> ids) async {
    await sharedPreferences.setStringList(
      _subsKey,
      ids.map((e) => e.toString()).toList(),
    );
  }

  Future<void> setAcceptedSubscribedDoctorIds(Set<int> ids) async {
    await sharedPreferences.setStringList(
      _subsAcceptedKey,
      ids.map((e) => e.toString()).toList(),
    );
  }

  /// Refresh subscription status from backend.
  /// Uses GET /api/users-subscribed and treats (active/accepted/approved) as approved.
  Future<void> syncSubscribedDoctorsFromBackend() async {
    if (!isLoggedIn) return;
    if (!isPatient) return;

    try {
      final crud = Get.find<Crud>();
      final res = await crud.getData(ApiLinks.usersSubscribed, token: token);
      await res.fold((_) async {}, (r) async {
        final code = r["_statusCode"] is int ? (r["_statusCode"] as int) : int.tryParse("${r["_statusCode"]}") ?? 200;
        if (code != 200 && code != 201) return;

        final raw = r["data"] ?? r["subscriptions"] ?? r["doctors"] ?? r;
        final list = raw is List ? raw : <dynamic>[];

        final ids = <int>{};
        final acceptedIds = <int>{};

        for (final e in list) {
          if (e is Map) {
            final did = e["id"] ?? e["doctor_id"] ?? e["doctorId"] ?? e["user_id"];
            final id = did is int ? did : int.tryParse(did?.toString() ?? "");
            if (id != null && id > 0) ids.add(id);

            final status = (e["status"] ?? e["subscription_status"] ?? e["subscriptionStatus"] ?? "")
                .toString()
                .trim()
                .toLowerCase();
            if (status == "accepted" || status == "active" || status == "approved" || status == "approve") {
              if (id != null && id > 0) acceptedIds.add(id);
            }
            continue;
          }
          if (e is int) ids.add(e);
          if (e is String) {
            final id = int.tryParse(e);
            if (id != null && id > 0) ids.add(id);
          }
        }

        await setSubscribedDoctorIds(ids);
        await setAcceptedSubscribedDoctorIds(acceptedIds);
      });
    } catch (_) {}
  }

  Future<void> clearSession() async {
    await sharedPreferences.remove("token");
    await sharedPreferences.remove("type");
    await sharedPreferences.remove("user");
    await sharedPreferences.remove(_subsKey );
    await sharedPreferences.remove(_subsAcceptedKey);
  }

  // ─────────────────────────────────────────────────────
  // Role helpers
  // ─────────────────────────────────────────────────────

  /// Check if user is patient (type: "patient" or "payed" or "user")
  bool get isPatient {
    if (!isLoggedIn) return false;
    final type = (this.type ?? "").toLowerCase();
    return type == "patient" || type == "payed" || type == "user";
  }

  /// Check if user is doctor
  bool get isDoctor {
    if (!isLoggedIn) return false;
    return (type ?? "").toLowerCase() == "doctor";
  }

  /// True when doctor's account is approved by admin (application_status == "approved" or is_verified == true).
  /// Used to show "My clinic" and doctor home access.
  bool get isDoctorApproved {
    if (!isDoctor) return false;
    // Backend can return doctor info under: user["doctor"], user["doctor_profile"], or user["doctor"]["..."]
    final u = user;
    final dynamic doc = u?["doctor"] ?? u?["doctor_profile"] ?? u?["doctorProfile"];
    if (doc is! Map) return false;
    final status = (doc["application_status"] ?? "").toString().toLowerCase();
    if (status == "approved") return true;
    if (doc["is_verified"] == true) return true;
    return false;
  }

  /// Check if user is admin
  bool get isAdmin {
    if (!isLoggedIn) return false;
    return (type ?? "").toLowerCase() == "admin";
  }
}

Future<void> initialServices() async {
  await Get.putAsync(() => MyServices().init());
}
