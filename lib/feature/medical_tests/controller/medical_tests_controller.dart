import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/class/crud.dart';
import '../../../core/class/status_request.dart';
import '../../../core/permissions/permissions.dart';
import '../../../core/service/serviecs.dart';

import '../../../doctorApp/feature/home/data/doctor_patients_data.dart';
import '../../../doctorApp/feature/home/model/patient_model.dart';
import '../data/medical_tests_data.dart';
import '../model/medical_test_model.dart';

class MedicalTestsController extends GetxController {
  final MedicalTestsData data = MedicalTestsData(Get.find<Crud>());
  final MyServices myServices = Get.find();
  DoctorPatientsData? get doctorPatientsData =>
      Get.isRegistered<Crud>() ? DoctorPatientsData(Get.find<Crud>()) : null;

  final statusRequest = Rx<StatusRequest>(StatusRequest.loading);
  final RxList<MedicalTestModel> tests = <MedicalTestModel>[].obs;

  int? selectedPatientUserId;
  String selectedPatientName = "";
  final RxList<PatientModel> patients = <PatientModel>[].obs;
  final patientsLoaded = false.obs;
  bool _loadingPatients = false;
  bool _refreshing = false;
  DateTime? _lastRateLimitAt;

  bool get isDoctor =>
      Permissions(myServices).isDoctor || Permissions(myServices).isAdmin;
  String? get token => myServices.token;

  @override
  void onInit() {
    super.onInit();
    final args = (Get.arguments as Map?) ?? {};
    selectedPatientUserId = args["user_id"] is int
        ? args["user_id"] as int
        : (args["user_id"] != null
            ? int.tryParse("${args["user_id"]}")
            : null);
    selectedPatientName = (args["patient_name"] ?? "").toString();

    if (isDoctor && selectedPatientUserId == null) {
      _loadPatients();
    } else {
      loadTests(first: true);
    }
  }

  Future<void> _loadPatients() async {
    if (doctorPatientsData == null) {
      statusRequest.value = StatusRequest.success;
      patientsLoaded.value = true;
      return;
    }
    if (_loadingPatients) return;
    if (_lastRateLimitAt != null) {
      final elapsed = DateTime.now().difference(_lastRateLimitAt!);
      if (elapsed.inSeconds < 60) {
        statusRequest.value = StatusRequest.rateLimit;
        patientsLoaded.value = true;
        return;
      }
    }
    _loadingPatients = true;
    final res = await doctorPatientsData!.getPatients(page: 1, token: token);
    _loadingPatients = false;
    res.fold(
      (l) {
        if (l == StatusRequest.rateLimit) _lastRateLimitAt = DateTime.now();
        statusRequest.value = l;
        patientsLoaded.value = true;
      },
      (r) {
        _lastRateLimitAt = null;
        try {
          final raw = r["data"] ?? r["patients"] ?? r;
          final list = raw is List ? raw : <dynamic>[];
          final parsed = <PatientModel>[];
          for (final e in list) {
            if (e is! Map) continue;
            try {
              parsed.add(
                  PatientModel.fromJson(Map<String, dynamic>.from(e)));
            } catch (_) {}
          }
          patients.value = parsed;
          statusRequest.value = StatusRequest.success;
        } catch (_) {
          statusRequest.value = StatusRequest.failure;
        }
        patientsLoaded.value = true;
      },
    );
  }

  void selectPatient(PatientModel patient) {
    selectedPatientUserId = patient.userId;
    selectedPatientName = patient.fullname;
    loadTests(first: true);
    update();
  }

  Future<void> loadTests({bool first = false}) async {
    if (first) {
      tests.clear();
      statusRequest.value = StatusRequest.loading;
    }

    int? userId;

    if (isDoctor) {
      userId = selectedPatientUserId;
      if (userId == null || userId <= 0) {
        statusRequest.value = StatusRequest.success;
        update();
        return;
      }
    } else {
      final u = myServices.user;
      final id = u?["id"];
      userId = id is int ? id : int.tryParse(id?.toString() ?? "");
    }

    final res =
        await data.getMedicalTests(userId: userId, token: token, page: 1);

    res.fold(
      (l) {
        statusRequest.value = l;
      },
      (r) {
        final list = (r["data"] as List?) ?? [];
        tests.value = list
            .whereType<Map>()
            .map((e) => MedicalTestModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
        statusRequest.value = StatusRequest.success;
      },
    );
    update();
  }

  Future<void> refresh() async {
    if (_refreshing) return;
    _refreshing = true;
    try {
      if (isDoctor && selectedPatientUserId == null) {
        if (_lastRateLimitAt != null) {
          final elapsed = DateTime.now().difference(_lastRateLimitAt!);
          if (elapsed.inSeconds < 60) return;
        }
        await _loadPatients();
      } else {
        await loadTests(first: true);
      }
    } finally {
      _refreshing = false;
    }
  }

  // ─── Download ─────────────────────────────────────────────────────────────

  bool _isJsonBytes(List<int> bytes) {
    if (bytes.isEmpty) return true;
    int i = 0;
    while (i < bytes.length &&
        (bytes[i] == 32 || bytes[i] == 9 || bytes[i] == 10 || bytes[i] == 13)) {
      i++;
    }
    if (i >= bytes.length) return true;
    final b = bytes[i];
    return b == 0x7b || b == 0x5b; // '{' or '['
  }

  Future<void> downloadAndShow(MedicalTestModel test) async {
    debugPrint('[MedicalTests] ─── downloadAndShow ───');
    debugPrint('[MedicalTests] test.id=${test.id}  test.image=${test.image}');
    debugPrint('[MedicalTests] urls to try: ${test.downloadUrls}');

    try {
      final dir = await getApplicationDocumentsDirectory();
      final downloadsDir = Directory('${dir.path}/downloads');
      if (!await downloadsDir.exists()) {
        await downloadsDir.create(recursive: true);
      }

      // Derive extension from image path first, fallback to pdf
      String ext = 'pdf';
      final img = test.image;
      if (img != null && img.contains('.')) {
        ext = img.split('.').last.split('?').first.toLowerCase();
      }
      final safeName =
          test.name.replaceAll(RegExp(r'[^\w\-.]'), '_').replaceAll(' ', '_');
      final savePath = '${downloadsDir.path}/${safeName}_${test.id}.$ext';

      final authHeaders = <String, String>{
        'Accept': 'application/octet-stream,*/*',
        if (token != null && token!.isNotEmpty) 'Authorization': 'Bearer $token',
      };
      final noAuthHeaders = <String, String>{
        'Accept': 'application/octet-stream,*/*',
      };

      List<int>? goodBytes;

      outer:
      for (final rawUrl in test.downloadUrls) {
        final safeUrl = Uri.encodeFull(rawUrl);
        final uri = Uri.tryParse(safeUrl);
        if (uri == null) {
          debugPrint('[MedicalTests] Skipping invalid URI: $safeUrl');
          continue;
        }

        for (final headers in [authHeaders, noAuthHeaders]) {
          final useAuth = headers.containsKey('Authorization');
          try {
            debugPrint(
                '[MedicalTests] GET  auth=$useAuth  => $safeUrl');
            final response = await http
                .get(uri, headers: headers)
                .timeout(const Duration(seconds: 30));

            debugPrint(
                '[MedicalTests] RESP status=${response.statusCode}  bytes=${response.bodyBytes.length}  url=$safeUrl');

            if (response.statusCode == 200 || response.statusCode == 201) {
              final bytes = response.bodyBytes;
              if (bytes.isNotEmpty && !_isJsonBytes(bytes)) {
                goodBytes = bytes;
                debugPrint(
                    '[MedicalTests] ✓ Got real file bytes (${bytes.length} bytes) from $safeUrl');
                break outer;
              }
              // Got 200 but it's JSON / HTML — log it
              final preview =
                  utf8.decode(bytes, allowMalformed: true);
              debugPrint(
                  '[MedicalTests] 200 but NOT a file. Preview: '
                  '${preview.length > 300 ? preview.substring(0, 300) : preview}');
            } else {
              final preview = response.body;
              debugPrint(
                  '[MedicalTests] ${response.statusCode} body: '
                  '${preview.length > 300 ? preview.substring(0, 300) : preview}');
            }
          } catch (e) {
            debugPrint('[MedicalTests] Exception  url=$safeUrl  err=$e');
          }
        }
      }

      if (goodBytes == null || goodBytes.isEmpty) {
        debugPrint(
            '[MedicalTests] ✗ All URLs failed. '
            'Showing fallback dialog. urls=${test.downloadUrls}');
        _showFallback(test);
        return;
      }

      await File(savePath).writeAsBytes(goodBytes);
      debugPrint('[MedicalTests] Saved to $savePath');

      final result = await OpenFilex.open(savePath);
      if (result.type == ResultType.done) {
        Get.snackbar("success".tr, "downloadSuccess".tr);
      } else {
        // File saved but opener didn't find an app — still tell the user where it is
        Get.dialog(
          AlertDialog(
            title: Text("downloadSuccess".tr),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("fileDownloadedTo".tr),
                const SizedBox(height: 8),
                SelectableText(
                  savePath,
                  style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: Text("close".tr),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      debugPrint('[MedicalTests] Unexpected exception: $e');
      Get.snackbar("error".tr, "downloadFailed".tr);
    }
  }

  void _showFallback(MedicalTestModel test) {
    Get.dialog(
      AlertDialog(
        title: Text("downloadFailed".tr),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("downloadFailedTryBrowser".tr),
            const SizedBox(height: 12),
            ...test.downloadUrls.take(3).map(
                  (url) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: InkWell(
                      onTap: () async {
                        try {
                          final uri = Uri.parse(Uri.encodeFull(url));
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri,
                                mode: LaunchMode.externalApplication);
                          }
                        } catch (_) {}
                      },
                      child: Text(
                        url,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text("close".tr),
          ),
        ],
      ),
    );
  }
}
